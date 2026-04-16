import SwiftUI
import SwiftData

struct AttendanceView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @Query(sort: \AttendanceRecord.date, order: .reverse) private var allRecords: [AttendanceRecord]
    @State private var showingCheckInSheet = false
    @State private var selectedChild: Child? = nil
    @State private var checkInAction = ""

    var myChildren: [Child] { allChildren.filter { $0.keyworkerName == appState.currentUserName } }
    var checkedIn:  [Child] { myChildren.filter(\.isCheckedIn) }
    var notIn:      [Child] { myChildren.filter { !$0.isCheckedIn } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        NurseryTheme.primary.ignoresSafeArea(edges: .top)
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Attendance")
                                    .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                                Text("\(checkedIn.count)/\(myChildren.count) children in today")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                    }
                    .frame(height: 90)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Stats
                            HStack(spacing: 12) {
                                attendanceStat(count: checkedIn.count, label: "Present",  color: .green, icon: "checkmark.circle.fill")
                                attendanceStat(count: notIn.count,      label: "Expected", color: .orange, icon: "clock.fill")
                                attendanceStat(count: myChildren.count,  label: "Total",    color: NurseryTheme.primary, icon: "person.2.fill")
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                            // Checked In
                            if !checkedIn.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    SectionHeader(title: "In Nursery")
                                    ForEach(checkedIn) { child in
                                        AttendanceRow(child: child, isCheckedIn: true) {
                                            checkOut(child)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }

                            // Not In
                            if !notIn.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    SectionHeader(title: "Expected — Not Yet Arrived")
                                    ForEach(notIn) { child in
                                        AttendanceRow(child: child, isCheckedIn: false) {
                                            checkIn(child)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }

                            // Today's Log
                            let todayRecords = allRecords.filter { Calendar.current.isDateInToday($0.date) }
                            if !todayRecords.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    SectionHeader(title: "Today's Log")
                                    ForEach(todayRecords) { record in
                                        AttendanceRecordRow(record: record)
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }

                            Spacer(minLength: 32)
                        }
                    }
                }
            }
        }
    }

    private func checkIn(_ child: Child) {
        child.isCheckedIn  = true
        child.checkInTime  = Date()
        child.checkInBy    = appState.currentUserName

        let record = AttendanceRecord(childId: child.id, childName: child.fullName)
        record.checkInTime  = Date()
        record.droppedOffBy = "Parent/Guardian"
        modelContext.insert(record)

        let entry = DiaryEntry(childId: child.id, childName: child.fullName,
                               entryType: "checkin",
                               description: "Checked in by \(appState.currentUserName). Arrived \(Date().shortTimeString).",
                               keyworkerName: appState.currentUserName)
        modelContext.insert(entry)
        try? modelContext.save()
    }

    private func checkOut(_ child: Child) {
        child.isCheckedIn = false

        // Update today's attendance record
        let todayRecords = allRecords.filter { Calendar.current.isDateInToday($0.date) && $0.childId == child.id }
        if let record = todayRecords.first {
            record.checkOutTime = Date()
            record.collectedBy  = "Parent/Guardian"
        }

        let entry = DiaryEntry(childId: child.id, childName: child.fullName,
                               entryType: "checkout",
                               description: "Checked out at \(Date().shortTimeString). Collected by parent/guardian.",
                               keyworkerName: appState.currentUserName)
        modelContext.insert(entry)
        try? modelContext.save()
    }

    @ViewBuilder
    private func attendanceStat(count: Int, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon).foregroundStyle(color).font(.system(size: 14))
                Spacer()
            }
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(NurseryTheme.textPrimary)
            Text(label)
                .font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle(padding: 14)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Attendance Row

struct AttendanceRow: View {
    let child: Child
    let isCheckedIn: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ChildAvatarView(initials: child.initials, size: 44, color: isCheckedIn ? NurseryTheme.teal : .gray, isCheckedIn: isCheckedIn)

            VStack(alignment: .leading, spacing: 3) {
                Text(child.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                if isCheckedIn, let t = child.checkInTime {
                    Text("In since \(t.shortTimeString) · \(child.checkInBy)")
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                } else {
                    Text("Expected · \(child.sessionTimes)")
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }

            Spacer()

            Button(action: onTap) {
                Text(isCheckedIn ? "Check Out" : "Check In")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(isCheckedIn ? Color.gray : Color.green)
                    .clipShape(Capsule())
            }
        }
        .cardStyle(padding: 12)
    }
}

// MARK: - Attendance Record Row

struct AttendanceRecordRow: View {
    let record: AttendanceRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.checkOutTime == nil ? "arrow.right.circle.fill" : "arrow.left.circle.fill")
                .foregroundStyle(record.checkOutTime == nil ? .green : .gray)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.childName)
                    .font(.system(size: 13, weight: .semibold))
                HStack {
                    if let t = record.checkInTime {
                        Text("In: \(t.shortTimeString)").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    }
                    if let t = record.checkOutTime {
                        Text("· Out: \(t.shortTimeString)").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    }
                }
            }

            Spacer()

            if record.checkOutTime == nil {
                StatusPill(label: "Present", color: .green)
            }
        }
        .cardStyle(padding: 12)
    }
}
