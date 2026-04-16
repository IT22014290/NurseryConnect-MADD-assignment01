import SwiftUI
import SwiftData

struct MealLogView: View {
    let child: Child
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \MealRecord.date, order: .reverse) private var allMealRecords: [MealRecord]

    @State private var mealType = "lunch"
    @State private var foodOffered = ""
    @State private var foodConsumed = "most"
    @State private var fluidType = "water"
    @State private var fluidAmount = 150
    @State private var notes = ""
    @State private var isSaved = false

    var todayMeals: [MealRecord] { allMealRecords.filter { $0.childId == child.id && $0.date.isToday } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Child header
                    HStack(spacing: 14) {
                        ChildAvatarView(initials: child.initials, size: 46, color: NurseryTheme.primary)
                        VStack(alignment: .leading) {
                            Text(child.fullName).font(.system(size: 16, weight: .semibold))
                            Text("Meal Log · \(Date().shortDateString)")
                                .font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    // Allergen alert
                    if child.hasAllergens {
                        AllergenBanner(allergens: child.allergens, severity: child.allergenSeverity)
                            .padding(.horizontal, 16)
                    }

                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Meal Type").font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                            Picker("Meal Type", selection: $mealType) {
                                Text("Breakfast").tag("breakfast")
                                Text("AM Snack").tag("morning_snack")
                                Text("Lunch").tag("lunch")
                                Text("PM Snack").tag("afternoon_snack")
                            }
                            .pickerStyle(.segmented)
                        }
                        NurseryTextField(title: "Food Offered", text: $foodOffered, placeholder: "e.g. Pasta bolognese")
                        ConsumptionSelector(selection: $foodConsumed)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Drink Type").font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                            Picker("Fluid", selection: $fluidType) {
                                Text("Water").tag("water")
                                Text("Milk").tag("milk")
                                Text("Dairy-Free Milk").tag("dairy-free milk")
                                Text("Diluted Juice").tag("juice (diluted)")
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(NurseryTheme.background)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Stepper("Amount: \(fluidAmount)ml", value: $fluidAmount, in: 0...500, step: 10)
                            .font(.system(size: 14))
                        NurseryTextField(title: "Notes (optional)", text: $notes, placeholder: "Any preferences or concerns...")
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    if isSaved {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text("Meal logged successfully!").font(.system(size: 14, weight: .semibold)).foregroundStyle(.green)
                        }
                        .padding(12).background(Color.green.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                    }

                    Button { save() } label: {
                        Label("Log Meal", systemImage: "fork.knife")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: NurseryTheme.primary))
                    .padding(.horizontal, 16)

                    // Today's meal history
                    if !todayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "Today's Meals")
                            ForEach(todayMeals) { record in
                                MealRecordRow(record: record)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
            .background(NurseryTheme.background)
            .navigationTitle("Meal Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let record = MealRecord(childId: child.id, childName: child.fullName, mealType: mealType)
        record.foodOffered    = foodOffered
        record.foodConsumed   = foodConsumed
        record.fluidType      = fluidType
        record.fluidAmount    = fluidAmount
        record.notes          = notes
        record.keyworkerName  = appState.currentUserName
        modelContext.insert(record)

        let entry = DiaryEntry(childId: child.id, childName: child.fullName,
                               entryType: "meal",
                               description: "Meal: \(foodOffered.isEmpty ? mealType : foodOffered). Consumed: \(foodConsumed). \(fluidType) \(fluidAmount)ml.",
                               keyworkerName: appState.currentUserName)
        entry.mealType     = mealType
        entry.foodConsumed = foodConsumed
        entry.fluidType    = fluidType
        entry.fluidAmount  = fluidAmount
        modelContext.insert(entry)
        try? modelContext.save()

        withAnimation { isSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isSaved = false }
        foodOffered = ""; notes = ""; foodConsumed = "most"; fluidAmount = 150
    }
}

// MARK: - Meal Record Row

struct MealRecordRow: View {
    let record: MealRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(NurseryTheme.primary.opacity(0.10))
                    .frame(width: 38, height: 38)
                Image(systemName: "fork.knife")
                    .foregroundStyle(NurseryTheme.primary)
                    .font(.system(size: 15))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(record.mealType.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 13, weight: .semibold))
                if !record.foodOffered.isEmpty {
                    Text(record.foodOffered)
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(record.foodConsumed.capitalized)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(record.consumptionColor)
                Text("\(record.fluidType) \(record.fluidAmount)ml")
                    .font(.system(size: 10))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
        }
        .cardStyle(padding: 12)
    }
}
