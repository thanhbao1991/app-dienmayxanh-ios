import Foundation

struct WatchCategory: Identifiable, Hashable {
    let id: String
    let displayName: String
    let g: String
    let m: String
    let curl: String

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

    /// Chuỗi hiển thị ngắn gọn điều kiện đang lọc — không hiện "g="/"m=" thô, chỉ hiện đủ để
    /// biết đây là bộ lọc gì (đối chiếu bằng link webURL bên trên là chính xác nhất).
    var filterSummary: String {
        var parts: [String] = []
        if !g.isEmpty { parts.append(g) }
        if !m.isEmpty { parts.append("mã: \(m)") }
        return parts.isEmpty ? "(không lọc thêm)" : parts.joined(separator: " · ")
    }
}

enum WatchCategories {
    static let all: [WatchCategory] = [
        WatchCategory(id: "may-xay-sinh-to", displayName: "Máy xay sinh tố", g: "nhua", m: "813,2225,23741,869", curl: "may-xay-sinh-to"),
        WatchCategory(id: "may-ep-trai-cay", displayName: "Máy ép trái cây", g: "may-ep-trai-cay", m: "23733,1694,871,847", curl: "may-ep-trai-cay"),
        WatchCategory(id: "may-danh-trung", displayName: "Máy đánh trứng", g: "", m: "27005,2307,2313", curl: "may-danh-trung"),
        WatchCategory(id: "may-vat-cam", displayName: "Máy vắt cam", g: "", m: "26988,34555,40326", curl: "may-vat-cam"),
        WatchCategory(id: "binh-thuy-dien-panasonic", displayName: "Bình thủy điện", g: "", m: "671,31402", curl: "binh-thuy-dien-panasonic"),
        WatchCategory(id: "binh-dun-sieu-toc", displayName: "Bình đun siêu tốc", g: "hien-thi-nhiet-do-co-the-cai-dat-nhiet-do-soi-cua-nuoc", m: "", curl: "binh-dun-sieu-toc"),
        WatchCategory(id: "may-loc-nuoc", displayName: "Máy lọc nước", g: "", m: "", curl: "may-loc-nuoc"),
        WatchCategory(id: "tu-dong", displayName: "Tủ đông", g: "", m: "", curl: "tu-dong"),
    ]
}
