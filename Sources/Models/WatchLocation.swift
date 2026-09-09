import Foundation

struct WatchLocation: Identifiable, Hashable {
    let id: String
    let displayName: String
    let provinceId: Int
    let districtId: Int
    let wardId: Int
}

enum WatchLocations {
    // g=nhua&m=813,2225,23741,869&o=2 khớp bộ lọc "Máy xay sinh tố Nhựa cũ" trên dienmayxanh.com
    static let all: [WatchLocation] = [
        WatchLocation(id: "buon-ma-thuot", displayName: "Buôn Ma Thuột", provinceId: 1024, districtId: 10024, wardId: 101078),
        WatchLocation(id: "krong-pac", displayName: "Krông Pắc", provinceId: 1024, districtId: 10024, wardId: 101044),
        WatchLocation(id: "tuy-hoa", displayName: "Tuy Hòa", provinceId: 1024, districtId: 10024, wardId: 101011),
    ]
}
