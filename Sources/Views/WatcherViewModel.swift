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

    /// Retry 1 lần khi lỗi — gọi đồng thời 3 khu vực đôi khi bị WAF của thegioididong.com chặn
    /// nhầm 1-2 request (giống rate-limit), retry ngay sau đó thường qua.
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

    // MARK: - Gộp 3 khu vực cho 1 loại máy đang chọn ở sidebar

    /// Chỉ tải 3 khu vực của loại máy đang xem (không tải 7 loại x 3 khu vực cùng lúc). Gọi
    /// TUẦN TỰ (không song song) — 3 request đồng thời từng bị WAF chặn nhầm 1-2 request.
    func loadCategoryIfNeeded(_ category: WatchCategory) async {
        for location in WatchLocations.all {
            await loadIfNeeded(WatchTab(category: category, location: location))
        }
    }

    func reloadCategory(_ category: WatchCategory) async {
        for location in WatchLocations.all {
            await load(WatchTab(category: category, location: location))
        }
    }

    func isLoading(_ category: WatchCategory) -> Bool {
        WatchLocations.all.contains { location in
            switch state(WatchTab(category: category, location: location)) {
            case .idle, .loading: return true
            default: return false
            }
        }
    }

    /// Danh sách sản phẩm gộp cả 3 khu vực, mỗi sản phẩm kèm khu vực để hiển thị ghi chú dưới tên.
    /// Sắp theo giá tăng dần. Khu vực lỗi/hết hàng đều coi như không có sản phẩm — không báo lỗi
    /// riêng, tránh làm phiền vì phần lớn trường hợp chỉ đơn giản là khu vực đó hết hàng.
    func items(_ category: WatchCategory) -> [(location: WatchLocation, product: Product)] {
        var result: [(WatchLocation, Product)] = []
        for location in WatchLocations.all {
            if case .loaded(let products) = state(WatchTab(category: category, location: location)) {
                result.append(contentsOf: products.map { (location, $0) })
            }
        }
        return result.sorted { $0.1.minPrice < $1.1.minPrice }
    }
}
