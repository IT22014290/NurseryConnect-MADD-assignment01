import SwiftUI
import SwiftData

struct ParentMainView: View {
    @Environment(AppState.self) private var appState
    @Query(filter: #Predicate<Message> { !$0.isRead }) private var unread: [Message]
    @Query(filter: #Predicate<IncidentReport> { !$0.parentAcknowledged && $0.parentNotified }) private var unreadIncidents: [IncidentReport]

    var body: some View {
        TabView {
            ParentDashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            ChildDiaryView()
                .tabItem { Label("Diary", systemImage: "book.fill") }

            GPSTrackingView()
                .tabItem { Label("Van Tracker", systemImage: "location.fill") }

            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
                .badge(unread.filter { $0.recipientName == appState.currentUserName || $0.recipientRole == "Parent" }.count)
        }
        .tint(NurseryTheme.pink)
    }
}
