import SwiftUI

// MARK: - Root Tab Navigation
// Keyworker's two primary workspaces: Children (Diary) and Incidents.

struct ContentView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // Tab 1: My Children & Daily Diary
            DashboardView()
                .tabItem {
                    Label("My Children", systemImage: "person.2.fill")
                }
                .tag(0)

            // Tab 2: Incident Reports (all children)
            IncidentListView(child: nil)
                .tabItem {
                    Label("Incidents", systemImage: "exclamationmark.triangle.fill")
                }
                .tag(1)
        }
        .tint(NurseryTheme.primary)
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
