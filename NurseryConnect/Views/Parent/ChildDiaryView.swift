import SwiftUI
import SwiftData

struct ChildDiaryView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @Query(sort: \DiaryEntry.timestamp, order: .reverse) private var allEntries: [DiaryEntry]
    @State private var selectedDate = Date()
    @State private var filterType = "all"

    var myChild: Child? { allChildren.first { $0.preferredName == appState.parentChildName } ?? allChildren.first }

    var filteredEntries: [DiaryEntry] {
        guard let child = myChild else { return [] }
        let cal = Calendar.current
        let dayEntries = allEntries.filter {
            $0.childId == child.id && cal.isDate($0.timestamp, inSameDayAs: selectedDate)
        }
        if filterType == "all" { return dayEntries }
        return dayEntries.filter { $0.entryType == filterType }
    }

    let entryFilters = [
        ("all", "All"),
        ("activity", "Activity"),
        ("meal", "Meals"),
        ("sleep", "Sleep"),
        ("wellbeing", "Wellbeing"),
        ("milestone", "Milestones"),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        NurseryTheme.gradient(NurseryTheme.primary).ignoresSafeArea(edges: .top)
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(myChild?.fullName ?? "Child Diary")
                                        .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                    Text("Daily Diary")
                                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                                }
                                Spacer()
                                if let child = myChild {
                                    ChildAvatarView(initials: child.initials, size: 40, color: .white.opacity(0.3), isCheckedIn: child.isCheckedIn)
                                }
                            }
                            .padding(.horizontal, 20)

                            // Date picker strip
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(-6...0, id: \.self) { offset in
                                        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                                        DateChip(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)) {
                                            selectedDate = date
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8).padding(.bottom, 14)
                    }
                    .frame(height: 130)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entryFilters, id: \.0) { (type, label) in
                                Button {
                                    filterType = type
                                } label: {
                                    Text(label)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(filterType == type ? .white : NurseryTheme.textSecondary)
                                        .padding(.horizontal, 14).padding(.vertical, 7)
                                        .background(filterType == type ? NurseryTheme.primary : NurseryTheme.cardBg)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }

                    // Entries
                    if filteredEntries.isEmpty {
                        EmptyStateView(icon: "book", title: "No entries",
                                       message: filterType == "all" ? "No diary entries for this date." : "No \(filterType) entries for this date.")
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredEntries) { entry in
                                    DiaryEntryDetailCard(entry: entry)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Date Chip

struct DateChip: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? NurseryTheme.primary : .white.opacity(0.65))
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isSelected ? NurseryTheme.primary : .white)
            }
            .frame(width: 42, height: 52)
            .background(isSelected ? .white : .white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
