import SwiftUI
import SwiftData

// MARK: - Daily Diary View
// Chronological timeline of all diary entries for a child on a given day.
// FR13–FR18: EYFS statutory requirement — complete record of child's day.

struct DailyDiaryView: View {

    let child: Child

    @State private var selectedDate = Date()
    @State private var selectedEntry: DiaryEntry? = nil

    private var entriesForDate: [DiaryEntry] {
        let calendar = Calendar.current
        return child.diaryEntries
            .filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Date picker strip
                datePicker

                // Wellbeing summary for the day
                if !entriesForDate.isEmpty {
                    wellbeingSummary
                        .padding(.horizontal, NurseryTheme.spacingL)
                        .padding(.top, NurseryTheme.spacingM)
                }

                // Timeline
                if entriesForDate.isEmpty {
                    EmptyStateView(
                        icon: "book.pages",
                        title: isToday ? "No Entries Today" : "No Entries",
                        subtitle: isToday
                            ? "Tap '+ Add Entry' to log \(child.displayName)'s first activity."
                            : "No diary entries recorded for this date."
                    )
                    .padding(.top, NurseryTheme.spacingXXL)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(entriesForDate.enumerated()), id: \.element.id) { index, entry in
                            DiaryEntryRow(
                                entry: entry,
                                isLast: index == entriesForDate.count - 1
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedEntry = selectedEntry?.id == entry.id ? nil : entry
                                }
                            }

                            if selectedEntry?.id == entry.id {
                                DiaryEntryExpandedView(entry: entry)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                        removal: .opacity
                                    ))
                            }
                        }
                    }
                    .padding(.horizontal, NurseryTheme.spacingL)
                    .padding(.top, NurseryTheme.spacingM)
                }

                Spacer().frame(height: 100)
            }
        }
        .background(NurseryTheme.background)
    }

    // MARK: - Date Picker Strip

    private var datePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NurseryTheme.spacingS) {
                ForEach(-6...0, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
                    DateChip(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedDate = date }
                    }
                }
            }
            .padding(.horizontal, NurseryTheme.spacingL)
            .padding(.vertical, NurseryTheme.spacingM)
        }
        .background(NurseryTheme.cardSurface)
    }

    // MARK: - Wellbeing Summary

    private var wellbeingSummary: some View {
        let wellbeingEntries = entriesForDate.filter { $0.entryType == .wellbeing }
        let mealCount = entriesForDate.filter { $0.entryType == .meal }.count
        let sleepEntries = entriesForDate.filter { $0.entryType == .sleep }

        return NurseryCard {
            HStack(spacing: 0) {
                summaryItem(
                    value: wellbeingEntries.last.map { $0.moodRating.emoji } ?? "—",
                    label: "Mood",
                    useText: true
                )
                Divider().frame(height: 36)
                summaryItem(
                    value: "\(mealCount)",
                    label: "Meals",
                    useText: false
                )
                Divider().frame(height: 36)
                summaryItem(
                    value: sleepEntries.first.map { $0.sleepDurationFormatted } ?? "—",
                    label: "Sleep",
                    useText: false
                )
                Divider().frame(height: 36)
                summaryItem(
                    value: "\(entriesForDate.count)",
                    label: "Entries",
                    useText: false
                )
            }
            .padding(.vertical, NurseryTheme.spacingM)
        }
    }

    private func summaryItem(value: String, label: String, useText: Bool) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: useText ? 22 : 18, weight: .bold, design: .rounded))
                .foregroundColor(NurseryTheme.textPrimary)
            Text(label)
                .font(NurseryTheme.caption)
                .foregroundColor(NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Date Chip

private struct DateChip: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    private var dayNum: String { date.formatted(.dateTime.day()) }
    private var dayName: String { date.formatted(.dateTime.weekday(.abbreviated)) }
    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(dayName)
                    .font(NurseryTheme.caption)
                    .foregroundColor(isSelected ? .white : NurseryTheme.textSecondary)
                Text(dayNum)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : (isToday ? NurseryTheme.primary : NurseryTheme.textPrimary))
                if isToday {
                    Circle()
                        .fill(isSelected ? .white : NurseryTheme.primary)
                        .frame(width: 4, height: 4)
                } else {
                    Spacer().frame(height: 4)
                }
            }
            .frame(width: 44)
            .padding(.vertical, NurseryTheme.spacingS)
            .background(isSelected ? NurseryTheme.primary : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerS))
        }
    }
}

// MARK: - Diary Entry Row (Timeline style)

struct DiaryEntryRow: View {

    let entry: DiaryEntry
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: NurseryTheme.spacingM) {
            // Timeline column
            VStack(spacing: 0) {
                EntryTypeIcon(entryType: entry.entryType, size: 36)
                if !isLast {
                    Rectangle()
                        .fill(NurseryTheme.cardBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 36)

            // Content
            VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                HStack {
                    Text(entry.entryType.rawValue)
                        .font(NurseryTheme.label)
                        .fontWeight(.semibold)
                        .foregroundColor(entry.entryType.themeColor)
                    Spacer()
                    Text(entry.timestamp.formatted(.dateTime.hour().minute()))
                        .font(NurseryTheme.caption)
                        .foregroundColor(NurseryTheme.textSecondary)
                }

                Text(entry.summarySentence)
                    .font(NurseryTheme.bodyMedium)
                    .foregroundColor(NurseryTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if !entry.notes.isEmpty && entry.notes != entry.summarySentence {
                    Text(entry.notes)
                        .font(NurseryTheme.bodyMedium)
                        .foregroundColor(NurseryTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, NurseryTheme.spacingL)
        }
        .padding(.top, NurseryTheme.spacingS)
    }
}

// MARK: - Expanded Entry Detail

struct DiaryEntryExpandedView: View {

    let entry: DiaryEntry

    var body: some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: NurseryTheme.spacingM) {

                HStack {
                    EntryTypeIcon(entryType: entry.entryType, size: 28)
                    Text(entry.entryType.rawValue)
                        .font(NurseryTheme.headlineSmall)
                        .foregroundColor(NurseryTheme.textPrimary)
                    Spacer()
                    Text(entry.timestamp.formatted(.dateTime.hour().minute()))
                        .font(NurseryTheme.caption)
                        .foregroundColor(NurseryTheme.textSecondary)
                }

                Divider()

                switch entry.entryType {
                case .sleep:
                    sleepDetail
                case .meal:
                    mealDetail
                case .nappy:
                    nappyDetail
                case .wellbeing:
                    wellbeingDetail
                case .milestone:
                    milestoneDetail
                default:
                    if !entry.notes.isEmpty {
                        Text(entry.notes)
                            .font(NurseryTheme.bodyMedium)
                            .foregroundColor(NurseryTheme.textPrimary)
                    }
                }
            }
            .padding(NurseryTheme.spacingM)
        }
        .padding(.bottom, NurseryTheme.spacingM)
    }

    private var sleepDetail: some View {
        VStack(spacing: NurseryTheme.spacingS) {
            detailRow("Start", value: entry.sleepStartTime?.formatted(.dateTime.hour().minute()) ?? "—")
            detailRow("End", value: entry.sleepEndTime?.formatted(.dateTime.hour().minute()) ?? "—")
            detailRow("Duration", value: entry.sleepDurationFormatted)
            detailRow("Position", value: entry.sleepPosition)
        }
    }

    private var mealDetail: some View {
        VStack(spacing: NurseryTheme.spacingS) {
            detailRow("Meal Type", value: entry.mealType)
            detailRow("Food Offered", value: entry.foodOffered)
            detailRow("Amount Eaten", value: entry.foodConsumed.rawValue)
            detailRow("Fluid", value: "\(entry.fluidAmountMl)ml \(entry.fluidType)")
        }
    }

    private var nappyDetail: some View {
        VStack(spacing: NurseryTheme.spacingS) {
            detailRow("Type", value: entry.nappyType)
            detailRow("Cream Applied", value: entry.creamApplied ? "Yes" : "No")
            if !entry.nappyConcerns.isEmpty {
                detailRow("Concerns", value: entry.nappyConcerns)
            }
        }
    }

    private var wellbeingDetail: some View {
        VStack(spacing: NurseryTheme.spacingS) {
            HStack {
                Text("Mood")
                    .font(NurseryTheme.bodyMedium)
                    .foregroundColor(NurseryTheme.textSecondary)
                Spacer()
                Text("\(entry.moodRating.emoji) \(entry.moodRating.rawValue)")
                    .font(NurseryTheme.bodyMedium)
                    .foregroundColor(NurseryTheme.textPrimary)
            }
            if !entry.wellbeingNotes.isEmpty {
                detailRow("Observations", value: entry.wellbeingNotes)
            }
        }
    }

    private var milestoneDetail: some View {
        VStack(spacing: NurseryTheme.spacingS) {
            detailRow("Milestone", value: entry.milestoneTitle)
            detailRow("EYFS Area", value: entry.milestoneEYFSArea.rawValue)
            if !entry.milestoneNextSteps.isEmpty {
                detailRow("Next Steps", value: entry.milestoneNextSteps)
            }
        }
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(NurseryTheme.bodyMedium)
                .foregroundColor(NurseryTheme.textSecondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(NurseryTheme.bodyMedium)
                .foregroundColor(NurseryTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }
}
