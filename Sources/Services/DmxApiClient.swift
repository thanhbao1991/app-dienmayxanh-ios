import Foundation

enum DmxApiError: Error {
    case badResponse
    case apiError(String)
}

enum DmxApiClient {
    // WAF của thegioididong.com chặn request không có User-Agent giống trình duyệt (trả 403).
    private static let browserUserAgent =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

    static func fetchProducts(category: WatchCategory, location: WatchLocation) async throws -> DmxApiData {
        var components = URLComponents(string: "https://webapi.thegioididong.com/gateway/usedproduct/category/getbyurl")!
        components.queryItems = [
            URLQueryItem(name: "g", value: category.g),
            URLQueryItem(name: "p", value: ""),
            URLQueryItem(name: "c", value: "0"),
            URLQueryItem(name: "m", value: category.m),
            URLQueryItem(name: "o", value: "2"),
            URLQueryItem(name: "r", value: ""),
            URLQueryItem(name: "ps", value: "0"),
            URLQueryItem(name: "pi", value: "0"),
            URLQueryItem(name: "curl", value: category.curl),
            URLQueryItem(name: "kw", value: ""),
            URLQueryItem(name: "type", value: "-1"),
            URLQueryItem(name: "manuname", value: ""),
            URLQueryItem(name: "isHavePromotion", value: "false"),
            URLQueryItem(name: "provinceId", value: String(location.provinceId)),
            URLQueryItem(name: "districtId", value: String(location.districtId)),
            URLQueryItem(name: "wardId", value: String(location.wardId)),
            URLQueryItem(name: "q", value: ""),
            URLQueryItem(name: "isHasType", value: "false"),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue(browserUserAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("https://www.dienmayxanh.com/", forHTTPHeaderField: "Referer")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw DmxApiError.badResponse
        }

        let decoded = try JSONDecoder().decode(DmxApiResponse.self, from: data)
        guard decoded.code == 0 else {
            throw DmxApiError.apiError("code=\(decoded.code)")
        }
        return decoded.data
    }
}
