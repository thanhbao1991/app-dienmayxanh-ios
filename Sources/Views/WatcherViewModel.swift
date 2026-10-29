import Foundation

@MainActor
@Observable
final class WatcherViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded([Product])
        case failed(String)
    }

    private(set) var states: [String: LoadState] = [:]

    /// Các dòng đã vuốt ẩn (LocationProductRow.id = "khuVuc:productId") — lưu UserDefaults để mở
    /// lại app vẫn ẩn. Ẩn theo từng khu vực: cùng mẫu máy ở khu vực khác vẫn hiện.
    private(set) var hiddenRowIds: Set<String> = Set(UserDefaults.standard.stringArray(forKey: hiddenKey) ?? [])
    private static let hiddenKey = "hiddenRowIds"

    func setHidden(_ rowId: String, _ hidden: Bool) {
        if hidden {
            hiddenRowIds.insert(rowId)
        } else {
            hiddenRowIds.remove(rowId)
        }
        UserDefaults.standard.set(Array(hiddenRowIds), forKey: Self.hiddenKey)
    }

    func state(_ tab: WatchTab) -> LoadState {
        states[tab.id] ?? .idle
    }

    /// Chỉ gọi API khi mục đó chưa có dữ liệu (idle/failed) — bấm qua lại giữa các mục không
    /// gọi lại API, muốn làm mới thì kéo refresh.
    func loadIfNeeded(_ tab: WatchTab) async {
        switch state(tab) {
        case .loaded, .loading:
            return
        default:
            await load(tab)
        }
    }

    /// Retry 1 lần khi lỗi — gọi đồng thời nhiều khu vực đôi khi bị WAF của thegioididong.com
    /// chặn nhầm 1-2 request (giống rate-limit), retry ngay sau đó thường qua.
    func load(_ tab: WatchTab) async {
        states[tab.id] = .loading
        if let products = await fetchWithRetry(tab) {
            states[tab.id] = .loaded(products)
        } else {
            states[tab.id] = .failed("network")
        }
    }

    private func fetchWithRetry(_ tab: WatchTab, attempts: Int = 2) async -> [Product]? {
        for attempt in 1...attempts {
            do {
                let data = try await DmxApiClient.fetchProducts(category: tab.category, location: tab.location)
                let brands = Set(tab.category.brandNames.map { $0.lowercased() })
                guard !brands.isEmpty else { return data.listProductsVM }
                return data.listProductsVM.filter { brands.contains($0.manufacture?.name.lowercased() ?? "") }
            } catch {
                if attempt < attempts {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        }
        return nil
    }

    // MARK: - Gộp các khu vực ĐANG CHỌN (checkbox) cho 1 loại máy đang chọn ở sidebar

    /// Chỉ tải các khu vực đang được check (không tải khu vực đã bỏ check, không tải loại máy
    /// khác). Gọi TUẦN TỰ (không song song) — nhiều request đồng thời từng bị WAF chặn nhầm.
    func loadCategoryIfNeeded(_ category: WatchCategory, locations: [WatchLocation]) async {
        for location in locations {
            await loadIfNeeded(WatchTab(category: category, location: location))
        }
    }

    func reloadCategory(_ category: WatchCategory, locations: [WatchLocation]) async {
        for location in locations {
            await load(WatchTab(category: category, location: location))
        }
    }

    func isLoading(_ category: WatchCategory, locations: [WatchLocation]) -> Bool {
        locations.contains { location in
            switch state(WatchTab(category: category, location: location)) {
            case .idle, .loading: return true
            default: return false
            }
        }
    }

    /// Danh sách sản phẩm gộp các khu vực đang chọn, mỗi sản phẩm kèm khu vực để hiển thị ghi
    /// chú dưới tên. Sắp theo giá tăng dần. Khu vực lỗi/hết hàng đều coi như không có sản phẩm.
    ///
    /// Cùng 1 sản phẩm (productId) có thể tồn kho ở nhiều khu vực khác nhau cùng lúc — id của
    /// mỗi dòng PHẢI gồm cả khu vực lẫn productId (LocationProductRow.id), không được chỉ dùng
    /// productId, nếu không SwiftUI List sẽ lẫn dữ liệu/nhãn khu vực giữa các dòng trùng id.
    func items(_ category: WatchCategory, locations: [WatchLocation]) -> [LocationProductRow] {
        var result: [LocationProductRow] = []
        for location in locations {
            if case .loaded(let products) = state(WatchTab(category: category, location: location)) {
                result.append(contentsOf: products.map { LocationProductRow(location: location, product: $0) })
            }
        }
        return result.sorted { $0.product.minPrice < $1.product.minPrice }
    }
}
