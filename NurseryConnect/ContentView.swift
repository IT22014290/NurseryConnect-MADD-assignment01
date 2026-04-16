import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.selectedRole == nil {
                RoleSelectionView()
            } else {
                roleView(for: appState.selectedRole!)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.selectedRole)
    }

    @ViewBuilder
    private func roleView(for role: UserRole) -> some View {
        switch role {
        case .keyworker:      KeyworkerMainView()
        case .parent:         ParentMainView()
        case .settingManager: ManagerMainView()
        case .roomLeader:     RoomLeaderMainView()
        case .driver:         DriverMainView()
        case .catering:       CateringMainView()
        case .marketing:      MarketingMainView()
        case .administrator:  AdminMainView()
        }
    }
}
