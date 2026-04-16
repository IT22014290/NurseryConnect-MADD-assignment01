import SwiftUI
import SwiftData

struct ManagerMainView: View {
    @Environment(AppState.self) private var appState
    @Query(filter: #Predicate<IncidentReport> { $0.status == "pending" }) private var pendingIncidents: [IncidentReport]
    @Query(filter: #Predicate<Message> { !$0.isRead }) private var unread: [Message]

    var body: some View {
        TabView {
            ManagerDashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }

            IncidentQueueView()
                .tabItem { Label("Incidents", systemImage: "exclamationmark.triangle.fill") }
                .badge(pendingIncidents.count)

            AttendanceOverviewView()
                .tabItem { Label("Attendance", systemImage: "person.3.fill") }

            ReportsView()
                .tabItem { Label("Reports", systemImage: "doc.text.fill") }

            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
                .badge(unread.filter { $0.recipientRole == "Manager" }.count)
        }
        .tint(NurseryTheme.primary)
    }
}
