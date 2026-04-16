import SwiftUI
import SwiftData

struct RoomLeaderMainView: View {
    @Environment(AppState.self) private var appState
    @Query(filter: #Predicate<IncidentReport> { $0.status == "pending" }) private var pendingIncidents: [IncidentReport]
    @Query(filter: #Predicate<Message> { !$0.isRead }) private var unread: [Message]

    var body: some View {
        TabView {
            RoomLeaderDashboardView()
                .tabItem { Label("Room", systemImage: "person.badge.shield.checkmark.fill") }

            ChildrenListView()
                .tabItem { Label("Children", systemImage: "person.3.fill") }

            IncidentListView()
                .tabItem { Label("Incidents", systemImage: "exclamationmark.triangle.fill") }
                .badge(pendingIncidents.count)

            AttendanceView()
                .tabItem { Label("Attendance", systemImage: "checkmark.circle.fill") }

            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
                .badge(unread.filter { $0.recipientRole == "Room Leader" }.count)
        }
        .tint(NurseryTheme.purple)
    }
}
