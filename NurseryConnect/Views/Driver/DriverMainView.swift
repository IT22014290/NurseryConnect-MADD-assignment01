import SwiftUI
import SwiftData

struct DriverMainView: View {
    @Environment(AppState.self) private var appState
    @Query(filter: #Predicate<Message> { !$0.isRead }) private var unread: [Message]

    var body: some View {
        TabView {
            DriverDashboardView()
                .tabItem { Label("Run", systemImage: "bus.fill") }

            DriverManifestView()
                .tabItem { Label("Manifest", systemImage: "list.clipboard.fill") }

            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
                .badge(unread.filter { $0.recipientRole == "Driver" }.count)
        }
        .tint(NurseryTheme.orange)
    }
}
