import SwiftUI
import SwiftData

struct IncidentListView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var allIncidents: [IncidentReport]
    @State private var showingNewIncident = false
    @State private var filterStatus = "all"

    var myIncidents: [IncidentReport] {
        let filtered = allIncidents.filter { $0.reportedBy == appState.currentUserName }
        if filterStatus == "all" { return filtered }
        return filtered.filter { $0.status == filterStatus }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        NurseryTheme.red.ignoresSafeArea(edges: .top)
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Incident Reports")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("RIDDOR-aligned digital reporting")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                            Button { showingNewIncident = true } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                    }
                    .frame(height: 90)

                    // Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["all", "pending", "reviewed", "finalised"], id: \.self) { status in
                                Button {
                                    filterStatus = status
                                } label: {
                                    Text(status.capitalized)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(filterStatus == status ? .white : NurseryTheme.textSecondary)
                                        .padding(.horizontal, 14).padding(.vertical, 7)
                                        .background(filterStatus == status ? NurseryTheme.red : NurseryTheme.cardBg)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }

                    if myIncidents.isEmpty {
                        EmptyStateView(icon: "checkmark.shield.fill", title: "No incidents", message: "All clear – no incident reports match your filter.", color: .green)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 10) {
                                ForEach(myIncidents) { incident in
                                    NavigationLink(destination: IncidentDetailView(incident: incident)) {
                                        IncidentCard(incident: incident)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewIncident) {
                NewIncidentView()
            }
        }
    }
}

// MARK: - Incident Card

struct IncidentCard: View {
    let incident: IncidentReport

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(incident.severityColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(incident.severityColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(incident.childName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                Text(incident.categoryDisplay)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(incident.severityColor)
                Text(incident.incidentDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusPill(label: incident.status.capitalized, color: incident.statusColor)
                Text(incident.incidentDate.timeAgoString)
                    .font(.system(size: 10))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
        }
        .cardStyle()
    }
}
