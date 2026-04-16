import SwiftUI

struct RoleSelectionView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedRole: UserRole? = nil
    @State private var animateIn = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [NurseryTheme.navyBg, NurseryTheme.secondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(NurseryTheme.accent)
                        .scaleEffect(animateIn ? 1 : 0.3)
                        .opacity(animateIn ? 1 : 0)

                    Text("NurseryConnect")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(animateIn ? 1 : 0)

                    Text("Little Stars Nursery & Daycare")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .opacity(animateIn ? 1 : 0)
                }
                .padding(.top, 52)
                .padding(.bottom, 28)

                Text("Select Your Role")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .padding(.bottom, 16)
                    .opacity(animateIn ? 1 : 0)

                // Role Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(UserRole.allCases.enumerated()), id: \.element) { idx, role in
                            RoleCard(role: role, isSelected: selectedRole == role)
                                .onTapGesture { withAnimation(.spring(response: 0.3)) { selectedRole = role } }
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 30)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(idx) * 0.06), value: animateIn)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Continue Button
                VStack(spacing: 12) {
                    if let role = selectedRole {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                appState.selectedRole = role
                                setDefaultUserForRole(role)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: role.icon)
                                Text("Continue as \(role.rawValue)")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(color: role.color))
                        .padding(.horizontal, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Text("GDPR-Compliant · EYFS 2024 · Ofsted Ready")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(.bottom, 8)
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
                .animation(.spring(response: 0.35), value: selectedRole)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateIn = true
            }
        }
    }

    private func setDefaultUserForRole(_ role: UserRole) {
        switch role {
        case .keyworker:      appState.currentUserName = "Sarah Johnson";    appState.currentRoom = "Sunshine Room"
        case .settingManager: appState.currentUserName = "Mrs. Karen White"; appState.currentRoom = "All Rooms"
        case .roomLeader:     appState.currentUserName = "James Carter";     appState.currentRoom = "Rainbow Room"
        case .driver:         appState.currentUserName = "Mike Stevens";     appState.currentRoom = ""
        case .parent:         appState.currentUserName = "Emma Bennett";     appState.parentChildName = "Olivia"
        case .catering:       appState.currentUserName = "Chef Linda";       appState.currentRoom = "Kitchen"
        case .marketing:      appState.currentUserName = "Tom Walsh";        appState.currentRoom = ""
        case .administrator:  appState.currentUserName = "Admin";            appState.currentRoom = "All Rooms"
        }
    }
}

// MARK: - Role Card

private struct RoleCard: View {
    let role: UserRole
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isSelected ? role.color : role.color.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: role.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? .white : role.color)
            }

            Text(role.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(role.description)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? role.color.opacity(0.25) : Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? role.color : Color.white.opacity(0.12), lineWidth: isSelected ? 2 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
    }
}
