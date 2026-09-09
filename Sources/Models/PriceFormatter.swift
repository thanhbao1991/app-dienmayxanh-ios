import Foundation

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        f.maximumFractionDigits = 0
        return f
    }()

    static func format(_ value: Double) -> String {
        (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))") + "đ"
    }
}
