import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatcherViewModel()
    @State private var selectedCategory: WatchCategory = WatchCategories.all[0]

    private static let categoryIcons: [String: String] = [
        "may-xay-sinh-to": "drop.fill",
        "may-ep-trai-cay": "carrot.fill",
        "may-danh-trung": "fork.knife",
        "may-vat-cam": "circle.grid.2x2.fill",
        "binh-thuy-dien-panasonic": "flame.fill",
        "binh-dun-sieu-toc": "bolt.fill",
        "may-loc-nuoc": "cylinder.fill",
    ]

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                sidebar
                Divider()
                rightPane
            }
            .navigationTitle("Máy đổi trả DMX")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var sidebar: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(WatchCategories.all) { category in
                    let isSelected = category.id == selectedCategory.id
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(isSelected ? Color.accentColor : Color.clear)
                                .frame(width: 3)
                            Image(systemName: Self.categoryIcons[category.id] ?? "shippingbox.fill")
                                .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                                .frame(width: 16)
                            Text(category.displayName)
                                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 12)
                                .padding(.trailing, 6)
                        }
                        .frame(minHeight: 48)
                        .background(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 108)
        .background(Color(.secondarySystemGroupedBackground))
    }

    @ViewBuilder
    private var rightPane: some View {
        let items = viewModel.items(selectedCategory)
        let errors = viewModel.errors(selectedCategory)

        Group {
            if items.isEmpty && viewModel.isLoading(selectedCategory) {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray").font(.system(size: 28)).foregroundStyle(.secondary)
                    Text("Không có sản phẩm nào phù hợp").font(.caption).foregroundStyle(.secondary)
                    if !errors.isEmpty {
                        Text("Lỗi tải \(errors.count) khu vực").font(.caption2).foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    if !errors.isEmpty {
                        Section {
                            Text("Lỗi tải: \(errors.map(\.location.displayName).joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    Section {
                        ForEach(items, id: \.product.id) { item in
                            ProductRowView(product: item.product, category: selectedCategory, locationName: item.location.displayName)
                        }
                    } header: {
                        Text("\(items.count) máy · 3 khu vực")
                    }
                }
                .listStyle(.plain)
            }
        }
        .refreshable {
            await viewModel.reloadCategory(selectedCategory)
        }
        .task(id: selectedCategory.id) {
            await viewModel.loadCategoryIfNeeded(selectedCategory)
        }
    }
}

#Preview {
    ContentView()
}
