import SwiftUI
import SwiftData

struct CateringDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query private var allChildren: [Child]
    @Query private var mealPlan: [MealPlanItem]
    @Query private var stockItems: [StockItem]

    var checkedInChildren: [Child] { allChildren.filter { $0.isCheckedIn } }
    var allergenChildren:  [Child] { allChildren.filter { $0.hasAllergens && $0.isCheckedIn } }
    var lowStockCount: Int { stockItems.filter { $0.isLowStock }.count }

    var todayMealPlan: [MealPlanItem] {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let day = max(0, weekday - 2)
        return mealPlan.filter { $0.dayOfWeek == day && $0.isPublished }
    }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    cateringHeader
                    VStack(spacing: 16) {
                        // Stats
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Meals Today",    value: "\(checkedInChildren.count)",   icon: "fork.knife",                  color: NurseryTheme.red)
                            StatCard(title: "Allergen Alerts",value: "\(allergenChildren.count)",    icon: "exclamationmark.triangle.fill",color: allergenChildren.isEmpty ? .green : .red)
                            StatCard(title: "Low Stock",      value: "\(lowStockCount)",             icon: "shippingbox.fill",             color: lowStockCount > 0 ? .orange : .green)
                            StatCard(title: "Plan Published", value: mealPlan.isEmpty ? "No" : "Yes",icon: "calendar",                    color: mealPlan.isEmpty ? .gray : .green)
                        }
                        .padding(.horizontal, 16)

                        // Allergen alert (if any checked-in children)
                        if !allergenChildren.isEmpty {
                            allergenAlertBanner
                        }

                        // Today's menu
                        todayMenuCard

                        // Dietary summary
                        dietarySummaryCard

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }

    var cateringHeader: some View {
        ZStack {
            NurseryTheme.gradient(NurseryTheme.red).ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Catering Dashboard")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Little Stars Kitchen · \(Date().dayMonthString)")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Button { withAnimation { appState.selectedRole = nil } } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18)).foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
        }
        .frame(height: 90)
    }

    var allergenAlertBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("⚠️ Active Allergen Alerts", systemImage: "allergens")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.red)
            Divider()
            ForEach(allergenChildren) { child in
                HStack(spacing: 10) {
                    ChildAvatarView(initials: child.initials, size: 34, color: .red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.fullName).font(.system(size: 13, weight: .semibold))
                        Text(child.allergens.joined(separator: " · "))
                            .font(.system(size: 11)).foregroundStyle(.red.opacity(0.8))
                    }
                    Spacer()
                    AllergenSeverityBadge(severity: child.allergenSeverity)
                }
            }
        }
        .padding(14)
        .background(Color.red.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.3), lineWidth: 1.5))
        .padding(.horizontal, 16)
    }

    var todayMenuCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Today's Menu", systemImage: "list.bullet.rectangle.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.red)
            Divider()
            if todayMealPlan.isEmpty {
                Text("No menu items for today.")
                    .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
            } else {
                ForEach(todayMealPlan) { item in
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6).fill(NurseryTheme.red.opacity(0.1)).frame(width: 30, height: 30)
                            Image(systemName: "fork.knife").font(.system(size: 12)).foregroundStyle(NurseryTheme.red)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.mealType.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.system(size: 10, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                            Text(item.foodItem).font(.system(size: 13, weight: .semibold))
                        }
                        Spacer()
                        if !item.allergens.isEmpty {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange).font(.system(size: 12))
                        }
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    var dietarySummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Dietary Requirements Today", systemImage: "list.bullet.clipboard.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.primary)
            Divider()
            let total = checkedInChildren.count
            let vegetarian = checkedInChildren.filter { $0.dietaryRequirements.lowercased().contains("vegetarian") }.count
            let vegan      = checkedInChildren.filter { $0.dietaryRequirements.lowercased().contains("vegan") }.count
            let halalKosher = checkedInChildren.filter {
                $0.dietaryRequirements.lowercased().contains("halal") || $0.dietaryRequirements.lowercased().contains("kosher")
            }.count
            let dairyFree  = checkedInChildren.filter { $0.dietaryRequirements.lowercased().contains("dairy") }.count
            let glutenFree = checkedInChildren.filter { $0.dietaryRequirements.lowercased().contains("gluten") }.count

            HStack {
                Text("Children In").font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
                Spacer()
                Text("\(total)").font(.system(size: 13, weight: .bold))
            }
            if vegetarian > 0 { dietaryRow("Vegetarian", count: vegetarian) }
            if vegan > 0      { dietaryRow("Vegan", count: vegan) }
            if halalKosher > 0 { dietaryRow("Halal/Kosher", count: halalKosher) }
            if dairyFree > 0  { dietaryRow("Dairy-Free", count: dairyFree) }
            if glutenFree > 0 { dietaryRow("Gluten-Free", count: glutenFree) }
            if vegetarian == 0 && vegan == 0 && halalKosher == 0 && dairyFree == 0 && glutenFree == 0 {
                Text("No special dietary requirements today.").font(.system(size: 13))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func dietaryRow(_ label: String, count: Int) -> some View {
        HStack {
            Label(label, systemImage: "leaf.fill").font(.system(size: 12)).foregroundStyle(.green)
            Spacer()
            Text("\(count) child\(count == 1 ? "" : "ren")")
                .font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
        }
    }
}
