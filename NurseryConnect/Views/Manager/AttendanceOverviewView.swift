import SwiftUI
import SwiftData

struct AttendanceOverviewView: View {
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @Query(sort: \AttendanceRecord.date, order: .reverse) private var allRecords: [AttendanceRecord]
    @State private var selectedRoom = "All"

    var rooms: [String] { ["All"] + Array(Set(allChildren.map { $0.room })).sorted() }

    var displayedChildren: [Child] {
        selectedRoom == "All" ? allChildren : allChildren.filter { $0.room == selectedRoom }
    }

    var checkedIn: [Child]  { displayedChildren.filter { $0.isCheckedIn } }
    var notCheckedIn: [Child] { displayedChildren.filter { !$0.isCheckedIn } }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.primary).ignoresSafeArea(edges: .top)
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Label("Attendance Overview", systemImage: "person.3.fill")
                                    .font(.system(size: 20, weight: .bold)).foregroundStyle(.white)
                                Text("\(checkedIn.count) / \(displayedChildren.count) children in · \(Date().dayMonthString)")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        // Room filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(rooms, id: \.self) { room in
                                    Button { selectedRoom = room } label: {
                                        Text(room)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(selectedRoom == room ? NurseryTheme.primary : .white)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(selectedRoom == room ? .white : .white.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8).padding(.bottom, 14)
                }
                .frame(height: 120)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Summary cards
                        HStack(spacing: 10) {
                            miniStatCard(value: "\(checkedIn.count)", label: "Checked In", color: .green)
                            miniStatCard(value: "\(notCheckedIn.count)", label: "Not Arrived", color: .orange)
                            miniStatCard(value: "\(displayedChildren.filter { $0.isTransportChild }.count)",
                                         label: "Transport", color: NurseryTheme.teal)
                        }
                        .padding(.horizontal, 16)

                        // Checked in section
                        if !checkedIn.isEmpty {
                            attendanceSection(title: "Present (\(checkedIn.count))", children: checkedIn, color: .green)
                        }

                        // Not checked in section
                        if !notCheckedIn.isEmpty {
                            attendanceSection(title: "Not Arrived (\(notCheckedIn.count))", children: notCheckedIn, color: .orange)
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 16)
                }
            }
        }
    }

    func miniStatCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .bold)).foregroundStyle(color)
            Text(label).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(NurseryTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    func attendanceSection(title: String, children: [Child], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
            }
            .padding(.horizontal, 16)

            ForEach(children) { child in
                attendanceRow(child: child)
            }
        }
    }

    func attendanceRow(child: Child) -> some View {
        HStack(spacing: 12) {
            ChildAvatarView(initials: child.initials, size: 38, color: NurseryTheme.primary, isCheckedIn: child.isCheckedIn)
            VStack(alignment: .leading, spacing: 2) {
                Text(child.fullName).font(.system(size: 13, weight: .semibold))
                HStack(spacing: 4) {
                    Text(child.room).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    if child.isTransportChild {
                        Text("· Transport").font(.system(size: 11)).foregroundStyle(NurseryTheme.teal)
                    }
                }
            }
            Spacer()
            if child.isCheckedIn, let t = child.checkInTime {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("In").font(.system(size: 11, weight: .bold)).foregroundStyle(.green)
                    Text(t.shortTimeString).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                }
            } else {
                Text("Not in").font(.system(size: 11, weight: .semibold)).foregroundStyle(.orange)
            }
        }
        .cardStyle(padding: 12)
        .padding(.horizontal, 16)
    }
}
