import SwiftUI
import SwiftData

struct NewIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Child.fullName) private var allChildren: [Child]

    @State private var selectedChildId: UUID? = nil
    @State private var category = "minor_accident"
    @State private var location = ""
    @State private var description = ""
    @State private var immediateAction = ""
    @State private var witnesses = ""
    @State private var injuryBodyLocation = ""
    @State private var isSerious = false
    @State private var showError = false
    @State private var errorText = ""
    @State private var isSaved = false

    let categories = ["minor_accident", "first_aid", "safeguarding", "near_miss", "allergic_reaction", "medical"]

    var myChildren: [Child] { allChildren.filter { $0.keyworkerName == appState.currentUserName } }

    var selectedChild: Child? { myChildren.first { $0.id == selectedChildId } }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.red)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("New Incident Report")
                                .font(.system(size: 16, weight: .bold))
                            Text("Date/time auto-recorded and cannot be overridden.")
                                .font(.system(size: 11))
                                .foregroundStyle(NurseryTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Child") {
                    Picker("Select Child *", selection: $selectedChildId) {
                        Text("Select child...").tag(Optional<UUID>.none)
                        ForEach(myChildren) { child in
                            Text(child.fullName).tag(Optional(child.id))
                        }
                    }
                    if let child = selectedChild, child.hasAllergens {
                        AllergenBanner(allergens: child.allergens, severity: child.allergenSeverity)
                    }
                }

                Section("Incident Details") {
                    Picker("Category *", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text(IncidentReport.categoryLabel($0)).tag($0)
                        }
                    }
                    TextField("Location *", text: $location, prompt: Text("e.g. Bathroom, Outdoor Area"))
                    TextField("Body location (optional)", text: $injuryBodyLocation, prompt: Text("e.g. Right knee, Forehead"))
                    Toggle("Serious Incident (RIDDOR / Ofsted notification)", isOn: $isSerious)
                        .tint(.red)
                }

                Section("Description *") {
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }

                Section("Immediate Action Taken *") {
                    TextEditor(text: $immediateAction)
                        .frame(minHeight: 60)
                }

                Section("Witnesses (optional)") {
                    TextField("Staff member names", text: $witnesses)
                }

                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill").foregroundStyle(NurseryTheme.primary)
                        Text("Under EYFS statutory requirements, parents must be informed of all accidents on the SAME DAY they occur. This report will be sent to your manager for countersignature.")
                            .font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                }

                if showError {
                    Section { Text(errorText).foregroundStyle(.red).font(.system(size: 13)) }
                }
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") { submit() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func submit() {
        guard selectedChildId != nil else {
            errorText = "Please select a child."; showError = true; return
        }
        guard !location.isEmpty else {
            errorText = "Please enter the incident location."; showError = true; return
        }
        guard !description.isEmpty else {
            errorText = "Please describe the incident."; showError = true; return
        }
        guard !immediateAction.isEmpty else {
            errorText = "Please describe the immediate action taken."; showError = true; return
        }

        guard let child = selectedChild else { return }

        let report = IncidentReport(
            childId: child.id,
            childName: child.fullName,
            reportedBy: appState.currentUserName,
            category: category,
            description: description
        )
        report.location          = location
        report.immediateAction   = immediateAction
        report.witnesses         = witnesses
        report.injuryBodyLocation = injuryBodyLocation
        report.isSerious         = isSerious
        report.riddorRequired    = isSerious

        modelContext.insert(report)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Incident Detail View

struct IncidentDetailView: View {
    @Bindable var incident: IncidentReport
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var showingAcknowledge = false

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Status Header
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(incident.severityColor)
                        Text(incident.categoryDisplay)
                            .font(.system(size: 20, weight: .bold))
                        StatusPill(label: incident.status.uppercased(), color: incident.statusColor)
                        if incident.isSerious {
                            StatusPill(label: "SERIOUS — RIDDOR", color: .red)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(incident.severityColor.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)

                    // Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Incident Details").sectionHeaderStyle().padding(.bottom, 4)
                        InfoRow(label: "Child",        value: incident.childName)
                        InfoRow(label: "Date & Time",  value: incident.incidentDate.formatted(date: .long, time: .shortened))
                        InfoRow(label: "Location",     value: incident.location)
                        InfoRow(label: "Category",     value: incident.categoryDisplay)
                        InfoRow(label: "Body Location",value: incident.injuryBodyLocation)
                        InfoRow(label: "Reported By",  value: incident.reportedBy)
                        if !incident.witnesses.isEmpty {
                            InfoRow(label: "Witnesses", value: incident.witnesses)
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description").sectionHeaderStyle()
                        Text(incident.incidentDescription)
                            .font(.system(size: 14))
                            .foregroundStyle(NurseryTheme.textPrimary)
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Immediate Action Taken").sectionHeaderStyle()
                        Text(incident.immediateAction.isEmpty ? "Not recorded" : incident.immediateAction)
                            .font(.system(size: 14))
                            .foregroundStyle(NurseryTheme.textPrimary)
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    // Manager Review
                    if incident.status != "pending" {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Manager Review").sectionHeaderStyle().padding(.bottom, 4)
                            InfoRow(label: "Reviewed By",   value: incident.managerName)
                            if let date = incident.managerReviewDate {
                                InfoRow(label: "Review Date",  value: date.mediumDateString)
                            }
                            if !incident.managerNotes.isEmpty {
                                InfoRow(label: "Notes",        value: incident.managerNotes)
                            }
                            InfoRow(label: "Parent Notified", value: incident.parentNotified ? "Yes" : "Pending")
                        }
                        .cardStyle()
                        .padding(.horizontal, 16)
                    }

                    // Parent Acknowledge (for parent role)
                    if appState.selectedRole == .parent && incident.status == "reviewed" && !incident.parentAcknowledged {
                        Button {
                            incident.parentAcknowledged = true
                            incident.parentAcknowledgeDate = Date()
                            try? modelContext.save()
                        } label: {
                            Label("I Have Read This Incident Report", systemImage: "checkmark.seal.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle(color: .green))
                        .padding(.horizontal, 16)
                    }

                    if incident.parentAcknowledged {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Acknowledged by parent")
                                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(.green)
                                if let d = incident.parentAcknowledgeDate {
                                    Text(d.mediumDateString + " · " + d.shortTimeString)
                                        .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Incident Report")
        .navigationBarTitleDisplayMode(.inline)
    }
}
