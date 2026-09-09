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

    func load(_ tab: WatchTab) async {
        states[tab.id] = .loading
        do {
            let data = try await DmxApiClient.fetchProducts(category: tab.category, location: tab.location)
            states[tab.id] = .loaded(data.listProductsVM)
        } catch {
            states[tab.id] = .failed(error.localizedDescription)
        }
    }

    // MARK: - Gộp 3 khu vực cho 1 loại máy đang chọn ở sidebar

    /// Chỉ tải 3 khu vực của loại máy đang xem (không tải 7 loại x 3 khu vực cùng lúc).
    func loadCategoryIfNeeded(_ category: WatchCategory) async {
        await withTaskGroup(of: Void.self) { group in
            for location in WatchLocations.all {
                group.addTask { await self.loadIfNeeded(WatchTab(category: category, location: location)) }
            }
        }
    }

    func reloadCategory(_ category: WatchCategory) async {
        await withTaskGroup(of: Void.self) { group in
            for location in WatchLocations.all {
                group.addTask { await self.load(WatchTab(category: category, location: location)) }
            }
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

    func errors(_ category: WatchCategory) -> [(location: WatchLocation, message: String)] {
        WatchLocations.all.compactMap { location in
            if case .failed(let message) = state(WatchTab(category: category, location: location)) {
                return (location, message)
            }
            return nil
        }
    }

    /// Danh sách sản phẩm gộp cả 3 khu vực, mỗi sản phẩm kèm khu vực để hiển thị ghi chú dưới tên.
    /// Sắp theo giá tăng dần.
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
