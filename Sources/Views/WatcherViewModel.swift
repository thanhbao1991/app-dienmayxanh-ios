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
}
