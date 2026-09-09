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
                return data.listProductsVM
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
    func items(_ category: WatchCategory, locations: [WatchLocation]) -> [(location: WatchLocation, product: Product)] {
        var result: [(WatchLocation, Product)] = []
        for location in locations {
            if case .loaded(let products) = state(WatchTab(category: category, location: location)) {
                result.append(contentsOf: products.map { (location, $0) })
            }
        }
        return result.sorted { $0.1.minPrice < $1.1.minPrice }
    }
}
