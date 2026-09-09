import Foundation

struct Product: Identifiable, Decodable, Hashable {
    let productId: Int
    let name: String
    let thumbnail: String
    let url: String
    let productUrl: String
    let manufacture: Manufacture?
    let minPrice: Double
    let percentDiscount: Int
    let sumQuantity: Int
    let extendInfo: ExtendInfo?

    var id: Int { productId }

    struct Manufacture: Decodable, Hashable {
        let name: String
    }

    struct ExtendInfo: Decodable, Hashable {
        let maxOldPrice: Double?
    }

    var oldPrice: Double? {
        let value = extendInfo?.maxOldPrice ?? 0
        return value > minPrice ? value : nil
    }

    /// Link trang "máy đổi trả" (khác hẳn field `url` gốc trong JSON — cái đó trỏ tới trang sản
    /// phẩm mới, không phải trang đổi trả/trưng bày đang xem trong app này).
    func productLink(category: WatchCategory) -> URL? {
        URL(string: "https://www.dienmayxanh.com/may-doi-tra/\(category.curl)/\(productUrl)?pid=\(productId)&isimei=1")
    }

    var inStock: Bool { sumQuantity > 0 }
}

// MARK: - API envelope

struct DmxApiResponse: Decodable {
    let code: Int
    let data: DmxApiData
}

struct DmxApiData: Decodable {
    let total: Int
    let listProductsVM: [Product]
}
