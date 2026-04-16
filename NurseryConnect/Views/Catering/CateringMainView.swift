import SwiftUI
import SwiftData

struct CateringMainView: View {
    @Environment(AppState.self) private var appState
    @Query(filter: #Predicate<StockItem> { $0.currentLevel <= $0.minimumLevel }) private var lowStock: [StockItem]

    var body: some View {
        TabView {
            CateringDashboardView()
                .tabItem { Label("Dashboard", systemImage: "fork.knife") }

            MealPlanView()
                .tabItem { Label("Meal Plan", systemImage: "calendar") }

            AllergenAlertsView()
                .tabItem { Label("Allergens", systemImage: "exclamationmark.triangle.fill") }

            StockManagementView()
                .tabItem { Label("Stock", systemImage: "shippingbox.fill") }
                .badge(lowStock.count)
        }
        .tint(NurseryTheme.red)
    }
}
