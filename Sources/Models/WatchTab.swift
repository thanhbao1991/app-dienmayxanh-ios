import Foundation

/// 1 mục sidebar = 1 tổ hợp (loại máy × khu vực) — bấm mục nào chỉ tải đúng mục đó, tránh gọi
/// 6 request cùng lúc làm nghẽn mạng khi mở app.
struct WatchTab: Identifiable, Hashable {
    let category: WatchCategory
    let location: WatchLocation

    var id: String { "\(category.id):\(location.id)" }

    static let all: [WatchTab] = WatchCategories.all.flatMap { category in
        WatchLocations.all.map { WatchTab(category: category, location: $0) }
    }
}
