import SwiftUI
import SwiftData

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var fullName = ""
    @State private var preferredName = ""
    @State private var dateOfBirth = Date()
    @State private var room = "Sunshine Room"
    @State private var parentOneName = ""
    @State private var parentOnePhone = ""
    @State private var parentOneEmail = ""
    @State private var emergencyName = ""
    @State private var emergencyPhone = ""
    @State private var dietaryRequirements = ""
    @State private var allergenList = ""
    @State private var allergenSeverity = "none"
    @State private var medicalConditions = ""
    @State private var photographyConsent = true
    @State private var socialMediaConsent = false
    @State private var dataProcessingConsent = true
    @State private var medicalConsent = true
    @State private var showError = false
    @State private var errorMessage = ""

    let rooms = ["Sunshine Room", "Rainbow Room", "Starlight Room", "Buttercup Room"]
    let severities = ["none", "intolerance", "allergy", "anaphylactic"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(NurseryTheme.primary.opacity(0.4))
                        Text("New Child Registration")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(NurseryTheme.textSecondary)
                        GDPRNoticeBanner()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section("Personal Information") {
                    TextField("Full Name *", text: $fullName)
                    TextField("Preferred Name (optional)", text: $preferredName)
                    DatePicker("Date of Birth *", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    Picker("Room *", selection: $room) {
                        ForEach(rooms, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Parent / Guardian Details") {
                    TextField("Parent 1 Full Name *", text: $parentOneName)
                    TextField("Phone *", text: $parentOnePhone).keyboardType(.phonePad)
                    TextField("Email *", text: $parentOneEmail).keyboardType(.emailAddress).autocapitalization(.none)
                }

                Section("Emergency Contact") {
                    TextField("Emergency Contact Name *", text: $emergencyName)
                    TextField("Phone *", text: $emergencyPhone).keyboardType(.phonePad)
                }

                Section("Dietary & Allergen Information") {
                    TextField("Dietary Requirements (e.g. Vegetarian, Halal)", text: $dietaryRequirements)
                    TextField("Allergens (comma-separated, e.g. Milk, Eggs)", text: $allergenList)
                    Picker("Allergen Severity", selection: $allergenSeverity) {
                        ForEach(severities, id: \.self) { Text($0.capitalized).tag($0) }
                    }
                }

                Section("Medical Information") {
                    TextField("Medical Conditions (leave blank if none)", text: $medicalConditions)
                }

                Section("GDPR Consent") {
                    Toggle("Data Processing Consent *", isOn: $dataProcessingConsent)
                    Toggle("Photography Consent", isOn: $photographyConsent)
                    Toggle("Social Media Consent", isOn: $socialMediaConsent)
                    Toggle("Medical Treatment Consent *", isOn: $medicalConsent)
                    Text("Consent records are timestamped and stored in accordance with UK GDPR Article 7. Parents may withdraw consent at any time.")
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }

                if showError {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.system(size: 13))
                    }
                }
            }
            .navigationTitle("Register Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Register") { register() }
                        .fontWeight(.semibold)
                        .disabled(!dataProcessingConsent)
                }
            }
        }
    }

    private func register() {
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Full name is required."; showError = true; return
        }
        guard !parentOneName.isEmpty else {
            errorMessage = "Parent/guardian name is required."; showError = true; return
        }
        guard dataProcessingConsent else {
            errorMessage = "Data processing consent is required to register a child."; showError = true; return
        }

        let child = Child(fullName: fullName.trimmingCharacters(in: .whitespaces),
                          preferredName: preferredName.trimmingCharacters(in: .whitespaces),
                          dateOfBirth: dateOfBirth,
                          keyworkerName: appState.currentUserName,
                          room: room)
        child.parentOneName  = parentOneName
        child.parentOnePhone = parentOnePhone
        child.parentOneEmail = parentOneEmail
        child.emergencyContactName  = emergencyName
        child.emergencyContactPhone = emergencyPhone
        child.dietaryRequirements   = dietaryRequirements
        child.allergenList   = allergenList
        child.allergenSeverity = allergenSeverity
        child.medicalConditions = medicalConditions
        child.photographyConsent    = photographyConsent
        child.socialMediaConsent    = socialMediaConsent
        child.dataProcessingConsent = dataProcessingConsent
        child.medicalTreatmentConsent = medicalConsent
        child.registrationDate = Date()

        modelContext.insert(child)
        try? modelContext.save()
        dismiss()
    }
}
