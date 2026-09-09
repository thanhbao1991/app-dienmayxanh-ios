import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatcherViewModel()
    @State private var selectedCategory: WatchCategory = WatchCategories.all[0]
    @State private var selectedLocationIds: Set<String> = Set(WatchLocations.all.map(\.id))

    private static let categoryIcons: [String: String] = [
        "may-xay-sinh-to": "drop.fill",
        "may-ep-trai-cay": "carrot.fill",
        "may-danh-trung": "fork.knife",
        "may-vat-cam": "circle.grid.2x2.fill",
        "binh-thuy-dien-panasonic": "flame.fill",
        "binh-dun-sieu-toc": "bolt.fill",
        "may-loc-nuoc": "cylinder.fill",
        "tu-dong": "cube.fill",
        "lo-vi-song": "square.grid.3x3.fill",
        "may-nuoc-nong": "thermometer.sun.fill",
        "quat": "wind",
        "may-pha-ca-phe": "cup.and.saucer.fill",
        "bep-ga-don": "flame.circle.fill",
        "noi-ap-suat-philips": "gauge.with.dots.needle.67percent",
    ]

    private var selectedLocations: [WatchLocation] {
        WatchLocations.all.filter { selectedLocationIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                sidebar
                Divider()
                VStack(spacing: 0) {
                    filterSummaryBar
                    locationCheckboxes
                    Divider()
                    rightPane
                }
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

    /// Hiện điều kiện đang lọc của tab đang chọn — bấm mở web gốc để đối chiếu.
    private var filterSummaryBar: some View {
        Link(destination: selectedCategory.webURL) {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                Text(selectedCategory.friendlyFilter)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "arrow.up.right.square")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
    }

    /// Checkbox chọn khu vực — bấm khu vực nào thì tải/gỡ đúng khu vực đó, mặc định check cả 3.
    private var locationCheckboxes: some View {
        HStack(spacing: 8) {
            ForEach(WatchLocations.all) { location in
                let isOn = selectedLocationIds.contains(location.id)
                Button {
                    if isOn {
                        selectedLocationIds.remove(location.id)
                    } else {
                        selectedLocationIds.insert(location.id)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isOn ? "checkmark.square.fill" : "square")
                            .foregroundStyle(isOn ? Color.accentColor : .secondary)
                        Text(location.displayName)
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var rightPane: some View {
        let locations = selectedLocations
        let items = viewModel.items(selectedCategory, locations: locations)

        Group {
            if locations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "square.dashed").font(.system(size: 28)).foregroundStyle(.secondary)
                    Text("Chọn ít nhất 1 khu vực").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty && viewModel.isLoading(selectedCategory, locations: locations) {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray").font(.system(size: 28)).foregroundStyle(.secondary)
                    Text("Không có sản phẩm nào phù hợp").font(.caption).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        ForEach(items) { item in
                            ProductRowView(product: item.product, category: selectedCategory, locationName: item.location.displayName)
                        }
                    } header: {
                        Text("\(items.count) máy · \(locations.count) khu vực")
                    }
                }
                .listStyle(.plain)
            }
        }
        .refreshable {
            await viewModel.reloadCategory(selectedCategory, locations: locations)
        }
        .task(id: "\(selectedCategory.id):\(selectedLocationIds.sorted().joined(separator: ","))") {
            await viewModel.loadCategoryIfNeeded(selectedCategory, locations: locations)
        }
    }
}

#Preview {
    ContentView()
}
