import SwiftUI
import SwiftData

struct RoomLeaderDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @Query(sort: \DiaryEntry.timestamp, order: .reverse) private var allEntries: [DiaryEntry]
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var allIncidents: [IncidentReport]

    var roomChildren: [Child] { allChildren.filter { $0.room == appState.currentRoom } }
    var checkedIn:    [Child] { roomChildren.filter { $0.isCheckedIn } }
    var allergenKids: [Child] { checkedIn.filter { $0.hasAllergens } }

    var recentEntries: [DiaryEntry] {
        let ids = Set(roomChildren.map { $0.id })
        return Array(allEntries.filter { ids.contains($0.childId) }.prefix(5))
    }

    var pendingIncidents: [IncidentReport] {
        let names = Set(roomChildren.map { $0.fullName })
        return allIncidents.filter { names.contains($0.childName) && $0.status == "pending" }
    }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    roomLeaderHeader
                    VStack(spacing: 16) {
                        // Stats
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "In Room",  value: "\(checkedIn.count)/\(roomChildren.count)", icon: "person.fill.checkmark",   color: .green)
                            StatCard(title: "Allergens",value: "\(allergenKids.count)",                    icon: "exclamationmark.triangle", color: allergenKids.isEmpty ? .green : .orange)
                            StatCard(title: "Incidents",value: "\(pendingIncidents.count)",               icon: "exclamationmark.triangle.fill", color: pendingIncidents.isEmpty ? .green : .red)
                            StatCard(title: "Registered",value: "\(roomChildren.count)",                   icon: "person.3.fill",            color: NurseryTheme.purple)
                        }
                        .padding(.horizontal, 16)

                        // Allergen alert
                        if !allergenKids.isEmpty {
                            allergenSection
                        }

                        // Staff ratio check
                        staffRatioCard

                        // Children in room
                        if !checkedIn.isEmpty {
                            roomChildrenSection
                        }

                        // Recent diary entries
                        if !recentEntries.isEmpty {
                            recentEntriesSection
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }

    var roomLeaderHeader: some View {
        ZStack {
            NurseryTheme.gradient(NurseryTheme.purple).ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(appState.currentRoom, systemImage: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Room Leader · \(Date().dayMonthString)")
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

    var allergenSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Allergen Alerts — Children Present", systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 13, weight: .bold)).foregroundStyle(.orange)
            ForEach(allergenKids) { child in
                HStack(spacing: 10) {
                    ChildAvatarView(initials: child.initials, size: 36, color: .orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.fullName).font(.system(size: 13, weight: .semibold))
                        Text(child.allergens.joined(separator: " · "))
                            .font(.system(size: 11)).foregroundStyle(.orange)
                    }
                    Spacer()
                    AllergenSeverityBadge(severity: child.allergenSeverity)
                }
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.3), lineWidth: 1.5))
        .padding(.horizontal, 16)
    }

    var staffRatioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Room Ratio Compliance", systemImage: "person.badge.shield.checkmark.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.purple)
            Divider()
            let count = checkedIn.count
            let requiredStaff = max(1, Int(ceil(Double(count) / 4.0)))
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Children Present").font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                    Text("\(count)").font(.system(size: 22, weight: .bold))
                }
                Spacer()
                VStack(alignment: .center, spacing: 3) {
                    Text("EYFS Ratio").font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                    Text("1:4").font(.system(size: 22, weight: .bold)).foregroundStyle(NurseryTheme.purple)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text("Staff Required").font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                    Text("\(requiredStaff)").font(.system(size: 22, weight: .bold))
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    var roomChildrenSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Present Now (\(checkedIn.count))")
            ForEach(checkedIn) { child in
                HStack(spacing: 12) {
                    ChildAvatarView(initials: child.initials, size: 38, color: NurseryTheme.purple, isCheckedIn: true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.fullName).font(.system(size: 13, weight: .semibold))
                        if let t = child.checkInTime {
                            Text("Arrived \(t.shortTimeString)").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                        }
                    }
                    Spacer()
                    if child.hasAllergens {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange).font(.system(size: 13))
                    }
                }
                .cardStyle(padding: 10)
                .padding(.horizontal, 16)
            }
        }
    }

    var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Recent Diary Entries")
            ForEach(recentEntries) { entry in
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(entry.entryColor.opacity(0.12)).frame(width: 34, height: 34)
                        Image(systemName: entry.entryIcon).font(.system(size: 13)).foregroundStyle(entry.entryColor)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.childName).font(.system(size: 12, weight: .semibold))
                        Text(entry.entryNote).font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.textSecondary).lineLimit(1)
                    }
                    Spacer()
                    Text(entry.timestamp.shortTimeString)
                        .font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
                }
                .cardStyle(padding: 10)
                .padding(.horizontal, 16)
            }
        }
    }
}
