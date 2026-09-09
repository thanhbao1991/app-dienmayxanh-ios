import SwiftUI

struct ProductRowView: View {
    let product: Product
    var locationName: String? = nil

    var body: some View {
        Link(destination: product.productLink ?? URL(string: "https://www.dienmayxanh.com")!) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: product.thumbnail)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo").foregroundStyle(.tertiary)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 72, height: 72)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    if let manufacture = product.manufacture?.name {
                        Text(manufacture)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 6) {
                        Text(PriceFormatter.format(product.minPrice))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)

                        if let oldPrice = product.oldPrice {
                            Text(PriceFormatter.format(oldPrice))
                                .font(.caption)
                                .strikethrough()
                                .foregroundStyle(.secondary)
                        }

                        if product.percentDiscount > 0 {
                            Text("-\(product.percentDiscount)%")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 6) {
                        Text(product.inStock ? "Còn \(product.sumQuantity) máy" : "Hết hàng")
                            .foregroundStyle(product.inStock ? .green : .secondary)

                        if let locationName {
                            Text("· 📍 \(locationName)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.caption2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
