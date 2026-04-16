import SwiftUI
import SwiftData

struct IncidentQueueView: View {
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var allIncidents: [IncidentReport]
    @State private var statusFilter = "pending"

    let statusOptions = [("pending", "Pending"), ("reviewed", "Reviewed"), ("finalised", "Finalised")]

    var filtered: [IncidentReport] {
        if statusFilter == "all" { return allIncidents }
        return allIncidents.filter { $0.status == statusFilter }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        NurseryTheme.gradient(NurseryTheme.primary).ignoresSafeArea(edges: .top)
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Label("Incident Queue", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                                Text("\(allIncidents.filter { $0.status == "pending" }.count) awaiting review")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                    }
                    .frame(height: 90)

                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach([("all", "All")] + statusOptions, id: \.0) { (val, label) in
                                Button {
                                    statusFilter = val
                                } label: {
                                    let count = val == "all" ? allIncidents.count : allIncidents.filter { $0.status == val }.count
                                    HStack(spacing: 4) {
                                        Text(label)
                                        if count > 0 {
                                            Text("\(count)")
                                                .font(.system(size: 10, weight: .bold))
                                                .padding(.horizontal, 5).padding(.vertical, 2)
                                                .background(statusFilter == val ? .white.opacity(0.3) : NurseryTheme.primary.opacity(0.15))
                                                .clipShape(Capsule())
                                        }
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(statusFilter == val ? .white : NurseryTheme.textSecondary)
                                    .padding(.horizontal, 14).padding(.vertical, 7)
                                    .background(statusFilter == val ? NurseryTheme.primary : NurseryTheme.cardBg)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }

                    if filtered.isEmpty {
                        EmptyStateView(icon: "checkmark.circle", title: "No incidents",
                                       message: "No \(statusFilter == "all" ? "" : statusFilter) incidents found.",
                                       color: .green)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 10) {
                                ForEach(filtered) { incident in
                                    NavigationLink(destination: ManagerIncidentReviewView(incident: incident)) {
                                        ManagerIncidentRow(incident: incident)
                                    }
                                }
                            }
                            .padding(.horizontal, 16).padding(.bottom, 24)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Manager Incident Row

struct ManagerIncidentRow: View {
    let incident: IncidentReport

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(incident.severityColor.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(incident.severityColor)
                    .font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(incident.categoryDisplay)
                        .font(.system(size: 14, weight: .semibold))
                    if incident.isSerious {
                        Text("SERIOUS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
                Text(incident.childName)
                    .font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                Text(incident.incidentDate.shortDateString)
                    .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                StatusPill(label: incident.status.capitalized, color: incident.statusColor)
                if !incident.parentNotified {
                    Text("Parent not notified")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange)
                }
            }
        }
        .cardStyle(padding: 12)
    }
}

// MARK: - Manager Incident Review View

struct ManagerIncidentReviewView: View {
    @Bindable var incident: IncidentReport
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var managerNotes = ""
    @State private var showSaved = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Incident summary
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(incident.categoryDisplay)
                                .font(.system(size: 18, weight: .bold))
                            Text(incident.childName)
                                .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                        StatusPill(label: incident.status.capitalized, color: incident.statusColor)
                    }
                    if incident.isSerious {
                        Label("Serious Incident — Ofsted Notification Required", systemImage: "exclamationmark.octagon.fill")
                            .font(.system(size: 12, weight: .semibold)).foregroundStyle(.red)
                            .padding(8).background(Color.red.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Divider()
                    InfoRow(label: "Date", value: incident.incidentDate.shortDateString)
                    InfoRow(label: "Reported by", value: incident.reportedBy)
                    InfoRow(label: "Location", value: incident.location)
                    InfoRow(label: "Parent notified", value: incident.parentNotified ? "Yes" : "No")
                    InfoRow(label: "Parent acknowledged", value: incident.parentAcknowledged ? "Yes" : "Pending")
                }
                .cardStyle()

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Incident Description")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                    Text(incident.incidentDescription)
                        .font(.system(size: 14))
                }
                .cardStyle()

                // Immediate action
                if !incident.immediateAction.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Immediate Action Taken")
                            .font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                        Text(incident.immediateAction).font(.system(size: 14))
                    }
                    .cardStyle()
                }

                // Manager review
                VStack(alignment: .leading, spacing: 12) {
                    Label("Manager Review", systemImage: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.primary)
                    Divider()
                    NurseryTextField(title: "Manager Notes", text: $managerNotes,
                                     placeholder: "Review findings, actions taken, follow-up required...")

                    // Notify parent toggle
                    Toggle("Mark parent as notified", isOn: $incident.parentNotified)
                        .font(.system(size: 14))

                    Toggle("RIDDOR Reportable", isOn: $incident.riddorRequired)
                        .font(.system(size: 14))

                    // Status actions
                    VStack(spacing: 8) {
                        if incident.status == "pending" {
                            Button { updateStatus("reviewed") } label: {
                                Label("Mark as Reviewed", systemImage: "checkmark.circle.fill")
                            }
                            .buttonStyle(PrimaryButtonStyle(color: NurseryTheme.primary))
                        }
                        if incident.status == "reviewed" {
                            Button { updateStatus("finalised") } label: {
                                Label("Finalise Incident", systemImage: "checkmark.seal.fill")
                            }
                            .buttonStyle(PrimaryButtonStyle(color: .green))
                        }
                    }

                    if showSaved {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text("Saved successfully").font(.system(size: 13, weight: .semibold)).foregroundStyle(.green)
                        }
                    }
                }
                .cardStyle()

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(NurseryTheme.background)
        .navigationTitle("Incident Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { managerNotes = incident.managerNotes }
    }

    private func updateStatus(_ newStatus: String) {
        incident.status = newStatus
        incident.managerNotes = managerNotes
        incident.managerName = appState.currentUserName
        incident.managerReviewDate = Date()
        try? modelContext.save()
        withAnimation { showSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSaved = false }
    }
}
