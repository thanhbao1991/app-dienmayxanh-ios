import Foundation

struct WatchCategory: Identifiable, Hashable {
    let id: String
    let displayName: String
    let g: String
    let m: String
    let curl: String
}

enum WatchCategories {
    static let all: [WatchCategory] = [
        WatchCategory(id: "may-xay-sinh-to", displayName: "Máy xay sinh tố", g: "nhua", m: "813,2225,23741,869", curl: "may-xay-sinh-to"),
        WatchCategory(id: "may-ep-trai-cay", displayName: "Máy ép trái cây", g: "may-ep-trai-cay", m: "23733,1694,871,847", curl: "may-ep-trai-cay"),
        WatchCategory(id: "may-danh-trung", displayName: "Máy đánh trứng", g: "", m: "27005,2307,2313", curl: "may-danh-trung"),
    ]
}
