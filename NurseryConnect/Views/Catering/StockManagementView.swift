import SwiftUI
import SwiftData

struct StockManagementView: View {
    @Query(sort: \StockItem.name) private var stockItems: [StockItem]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddSheet  = false
    @State private var selectedCategory = "All"

    var categories: [String] { ["All"] + Array(Set(stockItems.map { $0.category })).sorted() }
    var filtered: [StockItem] {
        selectedCategory == "All" ? stockItems : stockItems.filter { $0.category == selectedCategory }
    }
    var lowStockItems: [StockItem] { stockItems.filter { $0.isLowStock } }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.red).ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Stock Management", systemImage: "shippingbox.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("\(lowStockItems.count) item\(lowStockItems.count == 1 ? "" : "s") low on stock")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                        Button { showAddSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22)).foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button { selectedCategory = cat } label: {
                                Text(cat)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(selectedCategory == cat ? .white : NurseryTheme.textSecondary)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(selectedCategory == cat ? NurseryTheme.red : NurseryTheme.cardBg)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                }

                if filtered.isEmpty {
                    EmptyStateView(icon: "shippingbox", title: "No Stock Items",
                                   message: "Add items to track your kitchen inventory.", color: NurseryTheme.red)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(filtered) { item in
                                StockItemRow(item: item)
                            }
                            Spacer(minLength: 32)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddStockItemView()
        }
    }
}

// MARK: - Stock Item Row

struct StockItemRow: View {
    @Bindable var item: StockItem
    @Environment(\.modelContext) private var modelContext

    var levelPercent: Double {
        item.minimumLevel > 0 ? min(item.currentLevel / (item.minimumLevel * 3), 1.0) : 0.5
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(item.isLowStock ? Color.red.opacity(0.12) : Color.green.opacity(0.10))
                        .frame(width: 42, height: 42)
                    Image(systemName: item.isLowStock ? "exclamationmark.triangle.fill" : "shippingbox.fill")
                        .foregroundStyle(item.isLowStock ? .red : .green)
                        .font(.system(size: 16))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name).font(.system(size: 14, weight: .semibold))
                    Text(item.category).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(String(format: "%.1f", item.currentLevel)) \(item.unit)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(item.isLowStock ? .red : .primary)
                    Text("Min: \(String(format: "%.1f", item.minimumLevel)) \(item.unit)")
                        .font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
                }
            }
            // Level bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(NurseryTheme.background).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(item.isLowStock ? Color.red : Color.green)
                        .frame(width: geo.size.width * levelPercent, height: 6)
                }
            }
            .frame(height: 6)

            if item.isLowStock {
                Label("Low stock — reorder required", systemImage: "cart.fill")
                    .font(.system(size: 11)).foregroundStyle(.red)
            }

            // Restock stepper
            HStack {
                Text("Restock:").font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                Stepper("", value: $item.currentLevel, in: 0...9999, step: 0.5)
                    .labelsHidden()
                    .onChange(of: item.currentLevel) { _, _ in try? modelContext.save() }
                Text("\(String(format: "%.1f", item.currentLevel)) \(item.unit)")
                    .font(.system(size: 12, weight: .semibold))
            }
        }
        .cardStyle()
    }
}

// MARK: - Add Stock Item

struct AddStockItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name     = ""
    @State private var category = "Dry Goods"
    @State private var current: Double = 0
    @State private var minimum: Double = 0
    @State private var unit    = "kg"

    let categories = ["Dry Goods","Dairy","Produce","Frozen","Beverages","Condiments","Cleaning"]
    let units      = ["kg","g","L","ml","items","packs","boxes"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { Text($0).tag($0) }
                    }
                }
                Section("Stock Levels") {
                    Stepper("Current: \(String(format: "%.1f", current)) \(unit)", value: $current, in: 0...9999, step: 0.5)
                    Stepper("Minimum: \(String(format: "%.1f", minimum)) \(unit)", value: $minimum, in: 0...9999, step: 0.5)
                }
            }
            .navigationTitle("Add Stock Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !name.isEmpty else { return }
                        let item = StockItem(name: name, category: category, currentLevel: current, minimumLevel: minimum, unit: unit)
                        modelContext.insert(item)
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
