import SwiftUI
import SwiftData

// MARK: - Incident Form
// FR24–FR26: RIDDOR-aligned digital incident form.
// CRITICAL: timestamp is auto-set and cannot be overridden.
// Keyworker completes form, submits to manager review queue.

struct IncidentFormView: View {

    // child may be nil when accessed from the global incidents tab
    var child: Child?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Child.firstName) private var allChildren: [Child]

    @State private var selectedChild: Child? = nil
    @State private var category: IncidentCategory = .minorAccident
    @State private var location = ""
    @State private var description = ""
    @State private var actionTaken = ""
    @State private var witnessInput = ""
    @State private var witnesses: [String] = []
    @State private var bodyMapLocation: BodyMapLocation = .notApplicable
    @State private var isRIDDOR = false

    @State private var isSaving = false
    @State private var showValidationError = false
    @State private var showSubmitConfirmation = false

    private let incidentTimestamp = Date()  // FR24: auto-set, immutable

    private var isValid: Bool {
        let c = child ?? selectedChild
        return c != nil && !description.isEmpty && !actionTaken.isEmpty && !location.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // CRITICAL: timestamp notice
                Section {
                    HStack(spacing: NurseryTheme.spacingS) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundColor(NurseryTheme.danger)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Incident Time: \(incidentTimestamp.formatted(.dateTime.day().month().year().hour().minute()))")
                                .font(NurseryTheme.label)
                                .fontWeight(.semibold)
                                .foregroundColor(NurseryTheme.textPrimary)
                            Text("Auto-recorded — cannot be modified (EYFS/RIDDOR compliance)")
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Child selector (if not pre-set)
                if child == nil {
                    Section("Affected Child") {
                        Picker("Select Child", selection: $selectedChild) {
                            Text("Select...").tag(Child?.none)
                            ForEach(allChildren) { c in
                                HStack {
                                    Text(c.displayName)
                                    Text("(\(c.room))")
                                        .foregroundColor(NurseryTheme.textSecondary)
                                }
                                .tag(Child?.some(c))
                            }
                        }
                    }
                } else {
                    Section("Affected Child") {
                        HStack(spacing: NurseryTheme.spacingM) {
                            ChildAvatar(child: child!, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(child!.displayName)
                                    .font(NurseryTheme.bodyMedium)
                                    .fontWeight(.semibold)
                                Text(child!.room)
                                    .font(NurseryTheme.caption)
                                    .foregroundColor(NurseryTheme.textSecondary)
                            }
                            if child!.hasAllergies {
                                Spacer()
                                AllergyBadge(allergen: "Has Allergies")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Incident Category
                Section("Incident Category") {
                    ForEach(IncidentCategory.allCases, id: \.self) { cat in
                        Button {
                            withAnimation { category = cat }
                        } label: {
                            HStack(spacing: NurseryTheme.spacingM) {
                                IncidentCategoryIcon(category: cat, size: 32)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cat.rawValue)
                                        .font(NurseryTheme.bodyMedium)
                                        .foregroundColor(NurseryTheme.textPrimary)
                                    Text("Severity: \(cat.severityLabel)")
                                        .font(NurseryTheme.caption)
                                        .foregroundColor(NurseryTheme.textSecondary)
                                }
                                Spacer()
                                if category == cat {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(NurseryTheme.primary)
                                }
                            }
                        }
                    }

                    if category.requiresEscalation {
                        HStack(spacing: NurseryTheme.spacingS) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(NurseryTheme.danger)
                            Text("This category may require Ofsted notification. The manager will review.")
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.danger)
                        }
                        .padding(.top, 4)
                    }
                }

                // Location
                Section("Incident Location") {
                    TextField("e.g. Outdoor play area, Craft room", text: $location)
                }

                // Body Map
                Section("Injury Location (Body Map)") {
                    Picker("Location on Body", selection: $bodyMapLocation) {
                        ForEach(BodyMapLocation.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Description
                Section {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .font(NurseryTheme.bodyMedium)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Describe what happened, when, and any relevant context…")
                                        .font(NurseryTheme.bodyMedium)
                                        .foregroundColor(NurseryTheme.textMuted)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                } header: {
                    Text("Description of Incident")
                } footer: {
                    Text("Include what happened, where the child was, and any relevant observations.")
                        .font(NurseryTheme.caption)
                }

                // Action Taken
                Section {
                    TextEditor(text: $actionTaken)
                        .frame(minHeight: 80)
                        .font(NurseryTheme.bodyMedium)
                        .overlay(
                            Group {
                                if actionTaken.isEmpty {
                                    Text("Describe immediate first aid or action taken…")
                                        .font(NurseryTheme.bodyMedium)
                                        .foregroundColor(NurseryTheme.textMuted)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                            }
                        )
                } header: {
                    Text("Immediate Action Taken")
                } footer: {
                    Text("First aid administered, comfort given, referral made, etc.")
                        .font(NurseryTheme.caption)
                }

                // Witnesses
                Section("Witnesses") {
                    ForEach(witnesses, id: \.self) { witness in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(NurseryTheme.textSecondary)
                                .font(.system(size: 14))
                            Text(witness)
                                .font(NurseryTheme.bodyMedium)
                            Spacer()
                            Button {
                                witnesses.removeAll { $0 == witness }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(NurseryTheme.textMuted)
                            }
                        }
                    }

                    HStack {
                        TextField("Add witness name", text: $witnessInput)
                            .font(NurseryTheme.bodyMedium)
                        Button {
                            let name = witnessInput.trimmingCharacters(in: .whitespaces)
                            if !name.isEmpty && !witnesses.contains(name) {
                                witnesses.append(name)
                                witnessInput = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(NurseryTheme.primary)
                                .font(.system(size: 22))
                        }
                        .disabled(witnessInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                // RIDDOR checkbox
                Section("Reporting") {
                    Toggle(isOn: $isRIDDOR) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RIDDOR Reportable")
                                .font(NurseryTheme.bodyMedium)
                            Text("Tick if this incident requires reporting to the Health & Safety Executive.")
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textSecondary)
                        }
                    }
                }

                // Legal notice
                Section {
                    VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                        Label("EYFS Legal Obligation", systemImage: "info.circle")
                            .font(NurseryTheme.label)
                            .foregroundColor(NurseryTheme.statusBlue)
                        Text("Under the EYFS Statutory Framework, parents must be informed of all accidents and injuries on the same day they occur. This report will be sent to the Setting Manager for review and countersignature before parent notification is sent.")
                            .font(NurseryTheme.caption)
                            .foregroundColor(NurseryTheme.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(NurseryTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if isValid {
                            showSubmitConfirmation = true
                        } else {
                            showValidationError = true
                        }
                    } label: {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Submit")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal, NurseryTheme.spacingM)
                    .padding(.vertical, 6)
                    .background(isValid ? NurseryTheme.danger : NurseryTheme.textMuted)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            .alert("Missing Information", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please complete: child selection, location, description, and action taken.")
            }
            .confirmationDialog("Submit Incident Report?", isPresented: $showSubmitConfirmation, titleVisibility: .visible) {
                Button("Submit to Manager Review", role: .destructive) {
                    saveIncident()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This report will be sent to the Setting Manager for countersignature. The parent will be notified once approved.")
            }
        }
    }

    // MARK: - Save

    private func saveIncident() {
        isSaving = true
        let report = IncidentReport(
            category: category,
            location: location,
            incidentDescription: description,
            actionTaken: actionTaken
        )
        report.witnesses = witnesses
        report.bodyMapLocation = bodyMapLocation
        report.isRIDDORReportable = isRIDDOR
        report.ofstedNotificationRequired = category.requiresEscalation
        report.status = .pendingReview
        report.submittedAt = Date()
        report.child = child ?? selectedChild

        context.insert(report)

        do {
            try context.save()
            dismiss()
        } catch {
            isSaving = false
        }
    }
}
