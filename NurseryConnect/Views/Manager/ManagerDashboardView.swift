import SwiftUI
import SwiftData

struct ManagerDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query private var allChildren: [Child]
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var allIncidents: [IncidentReport]
    @Query private var allMessages: [Message]
    @Query private var transportRuns: [TransportRun]

    var checkedInCount: Int  { allChildren.filter { $0.isCheckedIn }.count }
    var pendingIncidentCount: Int { allIncidents.filter { $0.status == "pending" }.count }
    var unreadMessageCount: Int  { allMessages.filter { !$0.isRead }.count }
    var activeTransport: TransportRun? { transportRuns.first { $0.isActive } }

    var body: some View {
        NavigationStack {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    managerHeader

                    VStack(spacing: 20) {
                        // Stats grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: "Children In",   value: "\(checkedInCount)/\(allChildren.count)",
                                     icon: "person.fill.checkmark", color: .green)
                            StatCard(title: "Pending Incidents", value: "\(pendingIncidentCount)",
                                     icon: "exclamationmark.triangle.fill", color: pendingIncidentCount > 0 ? .red : .green)
                            StatCard(title: "Unread Messages", value: "\(unreadMessageCount)",
                                     icon: "message.fill", color: NurseryTheme.primary)
                            StatCard(title: "Total Children", value: "\(allChildren.count)",
                                     icon: "person.3.fill", color: NurseryTheme.teal)
                        }
                        .padding(.horizontal, 16)

                        // Transport status
                        if let run = activeTransport {
                            activeTransportCard(run: run)
                        }

                        // Pending incidents
                        if pendingIncidentCount > 0 {
                            pendingIncidentsSection
                        }

                        // Rooms overview
                        roomsSection

                        // Staff ratios
                        staffRatioCard

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
        } // NavigationStack
    }

    var managerHeader: some View {
        ZStack {
            NurseryTheme.gradient(NurseryTheme.primary).ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manager Dashboard")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Little Stars · \(Date().dayMonthString)")
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

    func activeTransportCard(run: TransportRun) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Transport Run Active", systemImage: "bus.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.teal)
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Driver: \(run.driverName)").font(.system(size: 13, weight: .semibold))
                    Text("\(run.boardedList.count)/\(run.manifestList.count) children boarded · ETA \(run.estimatedArrival)")
                        .font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                }
                Spacer()
                StatusPill(label: "Live", color: NurseryTheme.teal)
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    var pendingIncidentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Requires Attention")
            ForEach(allIncidents.filter { $0.status == "pending" }.prefix(3)) { incident in
                NavigationLink(destination: IncidentDetailView(incident: incident)) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8).fill(incident.severityColor.opacity(0.12)).frame(width: 38, height: 38)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(incident.severityColor).font(.system(size: 14))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(incident.categoryDisplay).font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(incident.severityColor)
                            Text(incident.childName).font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                        StatusPill(label: incident.status.capitalized, color: incident.statusColor)
                    }
                    .cardStyle(padding: 12)
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    var roomsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Rooms Today")
            let rooms = Dictionary(grouping: allChildren, by: \.room)
            ForEach(Array(rooms.keys.sorted()), id: \.self) { room in
                let children = rooms[room] ?? []
                let inRoom = children.filter { $0.isCheckedIn }.count
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(room).font(.system(size: 14, weight: .semibold))
                        Text("\(children.count) registered").font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Text("\(inRoom) in").font(.system(size: 13, weight: .bold)).foregroundStyle(.green)
                        Text("·").foregroundStyle(NurseryTheme.textSecondary)
                        Text("\(children.count - inRoom) out").font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
                    }
                }
                .cardStyle(padding: 12)
                .padding(.horizontal, 16)
            }
        }
    }

    var staffRatioCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("EYFS Staff Ratios", systemImage: "person.badge.shield.checkmark.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
            VStack(spacing: 6) {
                ratioRow(room: "Babies Room (0-2)", ratio: "1:3", compliant: true)
                ratioRow(room: "Toddlers Room (2-3)", ratio: "1:4", compliant: true)
                ratioRow(room: "Pre-School (3-5)", ratio: "1:8", compliant: checkedInCount <= 16)
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func ratioRow(room: String, ratio: String, compliant: Bool) -> some View {
        HStack {
            Text(room).font(.system(size: 12))
            Spacer()
            Text(ratio).font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
            Image(systemName: compliant ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(compliant ? .green : .red).font(.system(size: 13))
        }
    }
}
