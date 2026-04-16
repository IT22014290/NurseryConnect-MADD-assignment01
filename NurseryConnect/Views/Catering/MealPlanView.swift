import SwiftUI
import SwiftData

struct MealPlanView: View {
    @Query(sort: \MealPlanItem.dayOfWeek) private var mealPlan: [MealPlanItem]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDay = 0
    @State private var showAddSheet = false

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    let mealTypes = ["breakfast", "morning_snack", "lunch", "afternoon_snack"]

    var dayItems: [MealPlanItem] { mealPlan.filter { $0.dayOfWeek == selectedDay } }

    func itemFor(type: String) -> MealPlanItem? {
        dayItems.first { $0.mealType == type }
    }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.red).ignoresSafeArea(edges: .top)
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Label("Weekly Meal Plan", systemImage: "calendar")
                                    .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                Text("FSA / EYFS Nutrition Guidelines")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                            Button {
                                showAddSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22)).foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Day selector
                        HStack(spacing: 6) {
                            ForEach(0..<5, id: \.self) { idx in
                                Button {
                                    selectedDay = idx
                                } label: {
                                    Text(days[idx])
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(selectedDay == idx ? NurseryTheme.red : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 7)
                                        .background(selectedDay == idx ? .white : .white.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8).padding(.bottom, 14)
                }
                .frame(height: 130)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(mealTypes, id: \.self) { type in
                            mealSlotCard(type: type, item: itemFor(type: type))
                        }
                        nutritionNoticeCard
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddMealPlanItemView(selectedDay: selectedDay)
        }
    }

    func mealSlotCard(type: String, item: MealPlanItem?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(type.replacingOccurrences(of: "_", with: " ").capitalized,
                      systemImage: mealIcon(type))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(NurseryTheme.red)
                Spacer()
                if item != nil {
                    StatusPill(label: "Planned", color: .green)
                } else {
                    StatusPill(label: "Empty", color: .gray)
                }
            }
            Divider()
            if let item = item {
                Text(item.foodItem).font(.system(size: 15, weight: .semibold))
                if !item.allergens.isEmpty {
                    Label("Contains: \(item.allergens)", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 11)).foregroundStyle(.orange)
                }
                if !item.nutritionNotes.isEmpty {
                    Text(item.nutritionNotes).font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            } else {
                Text("No item planned — tap + to add.")
                    .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
            }
        }
        .cardStyle()
    }

    func mealIcon(_ type: String) -> String {
        switch type {
        case "breakfast":       return "sun.horizon.fill"
        case "morning_snack":   return "cup.and.saucer.fill"
        case "lunch":           return "fork.knife"
        case "afternoon_snack": return "cup.and.saucer.fill"
        default:                return "fork.knife"
        }
    }

    var nutritionNoticeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Nutrition Guidelines", systemImage: "list.clipboard.fill")
                .font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
            Text("Meals should include starchy foods, protein, fruit & vegetables, and dairy at each sitting in line with FSA 'Early Years and Childcare: Food and Nutrition' guidance (2023).")
                .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle()
    }
}

// MARK: - Add Meal Plan Item

struct AddMealPlanItemView: View {
    let selectedDay: Int
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var mealType  = "lunch"
    @State private var foodItem  = ""
    @State private var allergens = ""
    @State private var notes     = ""

    let mealTypes = [("breakfast","Breakfast"),("morning_snack","AM Snack"),("lunch","Lunch"),("afternoon_snack","PM Snack")]
    let days = ["Monday","Tuesday","Wednesday","Thursday","Friday"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal Details") {
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(mealTypes, id: \.0) { Text($0.1).tag($0.0) }
                    }
                    TextField("Food Item", text: $foodItem)
                    TextField("Contains Allergens (optional)", text: $allergens)
                    TextField("Nutrition Notes (optional)", text: $notes)
                }
                Section {
                    Text("Adding to: \(days[selectedDay])")
                        .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
                }
            }
            .navigationTitle("Add Meal Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !foodItem.isEmpty else { return }
                        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
                        let item = MealPlanItem(weekStartDate: weekStart, dayOfWeek: selectedDay, mealType: mealType, foodItem: foodItem, allergens: allergens)
                        item.nutritionNotes = notes
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
