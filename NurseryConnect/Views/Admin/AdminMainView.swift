import SwiftUI
import SwiftData

struct AdminMainView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            AdminDashboardView()
                .tabItem { Label("Dashboard", systemImage: "gearshape.2.fill") }

            AdminChildrenView()
                .tabItem { Label("Children", systemImage: "person.3.fill") }

            AdminComplianceView()
                .tabItem { Label("Compliance", systemImage: "checkmark.shield.fill") }

            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
        }
        .tint(Color.gray)
    }
}
