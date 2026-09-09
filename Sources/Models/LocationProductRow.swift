import Foundation

/// 1 dòng danh sách = 1 sản phẩm tại 1 khu vực cụ thể. Cùng 1 productId có thể tồn kho ở NHIỀU
/// khu vực khác nhau cùng lúc — id phải gồm cả location lẫn product, dùng riêng product.id sẽ
/// khiến SwiftUI List lẫn dữ liệu giữa các dòng trùng productId.
struct LocationProductRow: Identifiable {
    let location: WatchLocation
    let product: Product

    var id: String { "\(location.id):\(product.id)" }
}
