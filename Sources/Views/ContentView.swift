import SwiftUI

struct ContentView: View {
    @State private var viewModel = WatcherViewModel()
    @State private var selectedTab: WatchTab = WatchTab.all[0]

    private static let categoryIcons: [String: String] = [
        "may-xay-sinh-to": "drop.fill",
        "may-ep-trai-cay": "carrot.fill",
        "may-danh-trung": "fork.knife",
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
                ForEach(WatchTab.all) { tab in
                    let isSelected = tab.id == selectedTab.id
                    Button {
                        selectedTab = tab
                    } label: {
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(isSelected ? Color.accentColor : Color.clear)
                                .frame(width: 3)
                            Image(systemName: Self.categoryIcons[tab.category.id] ?? "shippingbox.fill")
                                .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                                .frame(width: 16)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tab.category.displayName)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                Text(tab.location.displayName)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                                    .foregroundStyle(isSelected ? Color.accentColor : .primary)
                            }
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
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
        Group {
            switch viewModel.state(selectedTab) {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let message):
                VStack(spacing: 12) {
                    Text("Lỗi tải dữ liệu").font(.subheadline.weight(.semibold))
                    Text(message).font(.caption).foregroundStyle(.secondary)
                    Button("Thử lại") { Task { await viewModel.load(selectedTab) } }
                        .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let products):
                if products.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray").font(.system(size: 28)).foregroundStyle(.secondary)
                        Text("Không có sản phẩm nào phù hợp").font(.caption).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ForEach(products) { product in
                                ProductRowView(product: product)
                            }
                        } header: {
                            Text("\(products.count) máy")
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .refreshable {
            await viewModel.load(selectedTab)
        }
        .task(id: selectedTab.id) {
            await viewModel.loadIfNeeded(selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
