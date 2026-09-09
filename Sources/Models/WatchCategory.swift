import Foundation

struct WatchCategory: Identifiable, Hashable {
    let id: String
    let displayName: String
    let g: String
    let m: String
    let curl: String
    /// Mô tả điều kiện lọc bằng tiếng Việt dễ hiểu (tên hãng/chất liệu...) thay vì hiện thẳng
    /// mã số g/m thô — tra 1 lần từ listManufacture của API rồi ghi cứng ở đây.
    let friendlyFilter: String

    /// Link web gốc khớp đúng điều kiện đang lọc (g/m) — hiện trong app để đối chiếu, bấm mở
    /// được ra Safari xem trực tiếp trên dienmayxanh.com.
    var webURL: URL {
        var components = URLComponents(string: "https://www.dienmayxanh.com/may-doi-tra/\(curl)")!
        var items: [URLQueryItem] = []
        if !g.isEmpty { items.append(URLQueryItem(name: "g", value: g)) }
        if !m.isEmpty { items.append(URLQueryItem(name: "m", value: m)) }
        if !items.isEmpty { components.queryItems = items }
        return components.url!
    }
}

enum WatchCategories {
    static let all: [WatchCategory] = [
        WatchCategory(id: "may-xay-sinh-to", displayName: "Máy xay sinh tố", g: "nhua", m: "813,2225,23741,869", curl: "may-xay-sinh-to", friendlyFilter: "Chất liệu nhựa · Philips, Toshiba, Panasonic, Hafele"),
        WatchCategory(id: "may-ep-trai-cay", displayName: "Máy ép trái cây", g: "may-ep-trai-cay", m: "23733,1694,871,847", curl: "may-ep-trai-cay", friendlyFilter: "Hafele, AVA, Panasonic, Philips"),
        WatchCategory(id: "may-danh-trung", displayName: "Máy đánh trứng", g: "", m: "27005,2307,2313", curl: "may-danh-trung", friendlyFilter: "AVA, Philips, Panasonic"),
        WatchCategory(id: "may-vat-cam", displayName: "Máy vắt cam", g: "", m: "26988,34555,40326", curl: "may-vat-cam", friendlyFilter: "AVA, Philips, Hafele"),
        WatchCategory(id: "binh-thuy-dien-panasonic", displayName: "Bình thủy điện", g: "", m: "671,31402", curl: "binh-thuy-dien-panasonic", friendlyFilter: "Toshiba, AVA"),
        WatchCategory(id: "binh-dun-sieu-toc", displayName: "Bình đun siêu tốc", g: "hien-thi-nhiet-do-co-the-cai-dat-nhiet-do-soi-cua-nuoc", m: "", curl: "binh-dun-sieu-toc", friendlyFilter: "Có hiển thị / cài đặt nhiệt độ sôi"),
        WatchCategory(id: "may-loc-nuoc", displayName: "Máy lọc nước", g: "", m: "", curl: "may-loc-nuoc", friendlyFilter: "Tất cả hãng"),
        WatchCategory(id: "tu-dong", displayName: "Tủ đông", g: "", m: "", curl: "tu-dong", friendlyFilter: "Tất cả hãng"),
        WatchCategory(id: "lo-vi-song", displayName: "Lò vi sóng", g: "", m: "787,25912", curl: "lo-vi-song", friendlyFilter: "Panasonic, Hafele"),
        WatchCategory(id: "may-nuoc-nong", displayName: "Máy nước nóng", g: "", m: "", curl: "may-nuoc-nong", friendlyFilter: "Tất cả hãng"),
        WatchCategory(id: "quat", displayName: "Quạt", g: "", m: "", curl: "quat", friendlyFilter: "Tất cả hãng"),
        WatchCategory(id: "may-pha-ca-phe", displayName: "Máy pha cà phê", g: "", m: "", curl: "may-pha-ca-phe", friendlyFilter: "Tất cả hãng"),
    ]
}
