import SwiftUI
import SwiftData

struct KeyworkerDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query private var allChildren: [Child]
    @Query(sort: \DiaryEntry.timestamp, order: .reverse) private var allEntries: [DiaryEntry]
    @Query(filter: #Predicate<IncidentReport> { $0.status == "pending" }) private var pendingIncidents: [IncidentReport]

    var myChildren: [Child] {
        allChildren.filter { $0.keyworkerName == appState.currentUserName }
    }

    var checkedInCount: Int { myChildren.filter(\.isCheckedIn).count }

    var todayEntries: [DiaryEntry] {
        allEntries.filter { $0.keyworkerName == appState.currentUserName && $0.timestamp.isToday }
    }

    var childrenWithAllergens: [Child] {
        myChildren.filter(\.hasAllergens)
    }

    var body: some View {
        NavigationStack {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Header
                    headerView

                    VStack(spacing: 20) {
                        // Stats Row
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Children In",      value: "\(checkedInCount)/\(myChildren.count)", icon: "person.fill.checkmark", color: NurseryTheme.teal, subtitle: "Today")
                            StatCard(title: "Diary Entries",    value: "\(todayEntries.count)",  icon: "note.text",                    color: NurseryTheme.primary, subtitle: "Today")
                            StatCard(title: "Pending Incidents",value: "\(pendingIncidents.count)", icon: "exclamationmark.triangle.fill", color: pendingIncidents.isEmpty ? .green : .orange, subtitle: "Awaiting review")
                            StatCard(title: "Room",             value: appState.currentRoom, icon: "door.right.hand.open",            color: NurseryTheme.purple, subtitle: "Your assignment")
                        }
                        .padding(.horizontal, 16)

                        // Allergen Alert Banner
                        if !childrenWithAllergens.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Allergen Alerts Today", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.orange)

                                ForEach(childrenWithAllergens) { child in
                                    HStack(spacing: 10) {
                                        ChildAvatarView(initials: child.initials, size: 34, color: .orange, isCheckedIn: child.isCheckedIn)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(child.preferredName)
                                                .font(.system(size: 13, weight: .semibold))
                                            Text(child.allergens.joined(separator: " · "))
                                                .font(.system(size: 11))
                                                .foregroundStyle(child.allergenSeverity == "anaphylactic" ? .red : .orange)
                                        }
                                        Spacer()
                                        StatusPill(label: child.allergenSeverity.capitalized, color: child.allergenSeverity == "anaphylactic" ? .red : .orange)
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.3), lineWidth: 1.5))
                            .padding(.horizontal, 16)
                        }

                        // My Children Quick Access
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "My Children — \(appState.currentRoom)")
                            if myChildren.isEmpty {
                                EmptyStateView(icon: "person.2", title: "No children assigned", message: "Contact your manager to be assigned children.")
                            } else {
                                ForEach(myChildren) { child in
                                    NavigationLink(destination: ChildProfileView(child: child)) {
                                        ChildQuickCard(child: child)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }

                        // Recent Diary Entries
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Recent Diary Entries")
                            if todayEntries.isEmpty {
                                Text("No entries logged today.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(NurseryTheme.textSecondary)
                                    .padding(.horizontal, 20)
                            } else {
                                ForEach(todayEntries.prefix(5)) { entry in
                                    DiaryEntryRow(entry: entry)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }

                        // Action Reminders
                        actionRemindersSection

                        Spacer(minLength: 24)
                    }
                    .padding(.top, 20)
                }
            }
        }
        } // NavigationStack
    }

    var headerView: some View {
        ZStack(alignment: .bottom) {
            NurseryTheme.teal.ignoresSafeArea(edges: .top)
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good \(greeting), \(firstName)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Keyworker · \(appState.currentRoom)")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    Button {
                        withAnimation { appState.selectedRole = nil }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Date strip
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.white.opacity(0.7))
                    Text(Date().formatted(date: .complete, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 100)
    }

    var actionRemindersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Action Reminders")
            let reminders = buildReminders()
            if reminders.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text("All up to date!")
                        .font(.system(size: 13))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                .padding(.horizontal, 20)
            } else {
                ForEach(reminders, id: \.0) { (text, icon, color) in
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundStyle(color)
                            .frame(width: 24)
                        Text(text)
                            .font(.system(size: 13))
                            .foregroundStyle(NurseryTheme.textPrimary)
                        Spacer()
                    }
                    .padding(12)
                    .background(color.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "morning" }
        if hour < 17 { return "afternoon" }
        return "evening"
    }

    var firstName: String { appState.currentUserName.components(separatedBy: " ").first ?? appState.currentUserName }

    func buildReminders() -> [(String, String, Color)] {
        var result: [(String, String, Color)] = []
        let noEntryChildren = myChildren.filter { child in
            !todayEntries.contains { $0.childId == child.id }
        }
        if !noEntryChildren.isEmpty {
            result.append(("Diary entries pending for \(noEntryChildren.map(\.preferredName).joined(separator: ", "))", "note.text", .orange))
        }
        if !pendingIncidents.isEmpty {
            result.append(("Incident reports awaiting manager review", "exclamationmark.triangle", .red))
        }
        return result
    }
}

// MARK: - Child Quick Card

struct ChildQuickCard: View {
    let child: Child

    var body: some View {
        HStack(spacing: 14) {
            ChildAvatarView(initials: child.initials, size: 46, color: NurseryTheme.teal, isCheckedIn: child.isCheckedIn)

            VStack(alignment: .leading, spacing: 3) {
                Text(child.fullName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                HStack(spacing: 8) {
                    Text(child.room)
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text("·")
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(child.displayAge)
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                if child.hasAllergens {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                        Text(child.allergens.prefix(2).joined(separator: ", "))
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusPill(
                    label: child.isCheckedIn ? "In" : "Out",
                    color: child.isCheckedIn ? .green : .gray
                )
                if child.isCheckedIn, let t = child.checkInTime {
                    Text("Since \(t.shortTimeString)")
                        .font(.system(size: 10))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(NurseryTheme.textSecondary.opacity(0.5))
        }
        .cardStyle()
    }
}

// MARK: - Diary Entry Row

struct DiaryEntryRow: View {
    let entry: DiaryEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(entry.entryColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.entryIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(entry.entryColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(entry.childName.components(separatedBy: " ").first ?? entry.childName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(NurseryTheme.textPrimary)
                    Text("·")
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(entry.entryTypeDisplay)
                        .font(.system(size: 12))
                        .foregroundStyle(entry.entryColor)
                }
                Text(entry.entryNote)
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
            Text(entry.timestamp.shortTimeString)
                .font(.system(size: 11))
                .foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle(padding: 12)
    }
}
