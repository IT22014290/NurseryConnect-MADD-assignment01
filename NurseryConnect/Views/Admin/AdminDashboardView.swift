import SwiftUI
import SwiftData

struct AdminDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query private var allChildren: [Child]
    @Query private var allMessages: [Message]
    @Query private var allIncidents: [IncidentReport]
    @Query private var allMedia: [MediaPhoto]

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    adminHeader
                    VStack(spacing: 16) {
                        // System stats
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Children",   value: "\(allChildren.count)",  icon: "person.3.fill",       color: NurseryTheme.teal)
                            StatCard(title: "Messages",   value: "\(allMessages.count)",  icon: "message.fill",        color: NurseryTheme.primary)
                            StatCard(title: "Incidents",  value: "\(allIncidents.count)", icon: "exclamationmark.triangle.fill", color: .orange)
                            StatCard(title: "Media Items",value: "\(allMedia.count)",     icon: "photo.stack.fill",    color: NurseryTheme.indigo)
                        }
                        .padding(.horizontal, 16)

                        // System config card
                        systemConfigCard

                        // User roles overview
                        userRolesCard

                        // Data retention
                        dataRetentionCard

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }

    var adminHeader: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#2C3E50"), Color(hex: "#3D5A73")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Administration")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("NurseryConnect · Little Stars")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Button { withAnimation { appState.selectedRole = nil } } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18)).foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
        }
        .frame(height: 90)
    }

    var systemConfigCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("System Configuration", systemImage: "gearshape.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.gray)
            Divider()
            configRow(label: "App Version",         value: "1.0.0")
            configRow(label: "Data Schema",          value: "SwiftData v1")
            configRow(label: "Nursery Name",         value: "Little Stars Nursery & Daycare")
            configRow(label: "Ofsted Number",        value: "EY123456")
            configRow(label: "ICO Registration",     value: "ZA000001")
            configRow(label: "Data Retention Period",value: "31 days (GPS) / 7 years (records)")
            configRow(label: "Encryption",           value: "AES-256 at rest · TLS 1.3 in transit")
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func configRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
            Spacer()
            Text(value).font(.system(size: 12, weight: .semibold)).multilineTextAlignment(.trailing)
        }
    }

    var userRolesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("User Roles", systemImage: "person.badge.shield.checkmark.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.gray)
            Divider()
            ForEach(UserRole.allCases) { role in
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(role.color.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: role.icon)
                            .font(.system(size: 13))
                            .foregroundStyle(role.color)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(role.rawValue).font(.system(size: 13, weight: .semibold))
                        Text(role.description).font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.system(size: 13))
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    var dataRetentionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Data Protection (UK GDPR)", systemImage: "lock.shield.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                retentionRow(category: "GPS/Location Data",     period: "31 days",  basis: "ICO CCTV Code")
                retentionRow(category: "Incident Reports",      period: "7 years",  basis: "RIDDOR / Children Act")
                retentionRow(category: "Child Records",         period: "7 years",  basis: "EYFS 2024")
                retentionRow(category: "CCTV Footage",          period: "31 days",  basis: "ICO Code")
                retentionRow(category: "Financial Records",     period: "6 years",  basis: "HMRC Requirements")
                retentionRow(category: "Safeguarding Records",  period: "Indefinite",basis: "Children Act 1989")
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func retentionRow(category: String, period: String, basis: String) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(category).font(.system(size: 12, weight: .semibold))
                Text(basis).font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
            Text(period).font(.system(size: 12, weight: .bold)).foregroundStyle(NurseryTheme.primary)
        }
    }
}
