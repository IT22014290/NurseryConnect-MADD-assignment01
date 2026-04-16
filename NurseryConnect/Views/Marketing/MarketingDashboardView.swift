import SwiftUI
import SwiftData

struct MarketingDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query private var photos: [MediaPhoto]

    var pendingApproval: [MediaPhoto] { photos.filter { !$0.isApprovedForSocial && !$0.postedToSocial } }
    var approved:        [MediaPhoto] { photos.filter { $0.isApprovedForSocial && !$0.postedToSocial } }
    var posted:          [MediaPhoto] { photos.filter { $0.postedToSocial } }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    marketingHeader
                    VStack(spacing: 16) {
                        // Stats
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Pending Review",  value: "\(pendingApproval.count)", icon: "photo.badge.checkmark.fill", color: .orange)
                            StatCard(title: "Ready to Post",   value: "\(approved.count)",        icon: "square.and.arrow.up.fill",   color: .green)
                            StatCard(title: "Posted",          value: "\(posted.count)",          icon: "checkmark.circle.fill",      color: NurseryTheme.indigo)
                            StatCard(title: "Total Media",     value: "\(photos.count)",          icon: "photo.stack.fill",           color: NurseryTheme.primary)
                        }
                        .padding(.horizontal, 16)

                        // GDPR notice
                        gdprGuidelinesCard

                        // Pending approval
                        if !pendingApproval.isEmpty {
                            pendingApprovalSection
                        }

                        // Approved ready to post
                        if !approved.isEmpty {
                            readyToPostSection
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }

    var marketingHeader: some View {
        ZStack {
            NurseryTheme.gradient(NurseryTheme.indigo).ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Marketing Hub")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("GDPR-Safe Social Content · Little Stars")
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

    var gdprGuidelinesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("GDPR Compliance Checklist", systemImage: "lock.shield.fill")
                .font(.system(size: 13, weight: .bold)).foregroundStyle(NurseryTheme.indigo)
            Divider()
            gdprRow(label: "Obtain explicit social media consent before publishing", ok: true)
            gdprRow(label: "All children's faces blurred unless consent given", ok: true)
            gdprRow(label: "No names, addresses or identifying details in captions", ok: true)
            gdprRow(label: "Manager approval required before posting", ok: true)
            gdprRow(label: "Right to withdraw consent honoured immediately", ok: true)
            gdprRow(label: "Data minimisation — only necessary images retained", ok: true)
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func gdprRow(label: String, ok: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(ok ? .green : .red).font(.system(size: 13))
            Text(label).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
    }

    var pendingApprovalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Awaiting Manager Approval (\(pendingApproval.count))")
            ForEach(pendingApproval.prefix(3)) { photo in
                photoRow(photo: photo)
            }
        }
        .padding(.horizontal, 16)
    }

    var readyToPostSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Approved — Ready to Post (\(approved.count))")
            ForEach(approved.prefix(3)) { photo in
                photoRow(photo: photo)
            }
        }
        .padding(.horizontal, 16)
    }

    func photoRow(photo: MediaPhoto) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(NurseryTheme.indigo.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: photo.isApprovedForSocial ? "checkmark.seal.fill" : "clock.fill")
                    .foregroundStyle(photo.isApprovedForSocial ? .green : .orange)
                    .font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(photo.caption.isEmpty ? "No caption" : photo.caption)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Label(photo.activityTag, systemImage: "tag.fill")
                    .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(photo.captureDate.shortDateString)
                    .font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
                if photo.isBlurred {
                    Label("Blurred", systemImage: "eye.slash.fill")
                        .font(.system(size: 9)).foregroundStyle(.gray)
                }
            }
        }
        .cardStyle(padding: 12)
    }
}
