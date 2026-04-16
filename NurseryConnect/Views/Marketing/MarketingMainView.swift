import SwiftUI
import SwiftData

struct MarketingMainView: View {
    @Environment(AppState.self) private var appState
    @Query(filter: #Predicate<MediaPhoto> { $0.isApprovedForSocial && !$0.postedToSocial }) private var pendingPost: [MediaPhoto]

    var body: some View {
        TabView {
            MarketingDashboardView()
                .tabItem { Label("Dashboard", systemImage: "megaphone.fill") }

            MediaLibraryView()
                .tabItem { Label("Media", systemImage: "photo.stack.fill") }
                .badge(pendingPost.count)

            ContentCalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }

            MessagingView()
                .tabItem { Label("Messages", systemImage: "message.fill") }
        }
        .tint(NurseryTheme.indigo)
    }
}
