import SwiftUI
import SwiftData

struct KeyworkerMainView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0

    @Query(
        filter: #Predicate<IncidentReport> { $0.status == "pending" }
    ) private var pendingIncidents: [IncidentReport]

    @Query(filter: #Predicate<Message> { !$0.isRead }) private var unreadMessages: [Message]

    var body: some View {
        TabView(selection: $selectedTab) {
            KeyworkerDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            ChildrenListView()
                .tabItem {
                    Label("My Children", systemImage: "person.2.fill")
                }
                .tag(1)

            IncidentListView()
                .tabItem {
                    Label("Incidents", systemImage: "exclamationmark.triangle.fill")
                }
                .badge(pendingIncidents.count)
                .tag(2)

            AttendanceView()
                .tabItem {
                    Label("Attendance", systemImage: "checkmark.circle.fill")
                }
                .tag(3)

            MessagingView()
                .tabItem {
                    Label("Messages", systemImage: "message.fill")
                }
                .badge(unreadMessages.filter { $0.recipientName == appState.currentUserName }.count)
                .tag(4)
        }
        .tint(NurseryTheme.teal)
    }
}
