import SwiftUI
import SwiftData

struct ChildProfileView: View {
    @Bindable var child: Child
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.timestamp, order: .reverse) private var allEntries: [DiaryEntry]
    @State private var selectedTab = 0
    @State private var showingAddEntry = false
    @State private var showingCheckIn = false
    @State private var showingMealLog = false

    var childEntries: [DiaryEntry] {
        allEntries.filter { $0.childId == child.id && $0.timestamp.isToday }
    }

    var avatarColor: Color {
        let colors: [Color] = [NurseryTheme.teal, NurseryTheme.purple, NurseryTheme.primary, NurseryTheme.orange, NurseryTheme.pink]
        return colors[abs(child.fullName.hashValue) % colors.count]
    }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Profile Header
                    ZStack {
                        NurseryTheme.gradient(avatarColor).ignoresSafeArea(edges: .top)
                        VStack(spacing: 10) {
                            ChildAvatarView(initials: child.initials, size: 72, color: avatarColor.opacity(0.6), isCheckedIn: child.isCheckedIn)
                            Text(child.fullName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                            HStack(spacing: 12) {
                                Label(child.displayAge, systemImage: "birthday.cake")
                                Label(child.room, systemImage: "door.right.hand.open")
                            }
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.85))
                            HStack(spacing: 8) {
                                StatusPill(label: child.isCheckedIn ? "Checked In" : "Not In", color: child.isCheckedIn ? .green : .white)
                                if child.hasAllergens {
                                    StatusPill(label: "Allergen Alert", color: .orange)
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                    .frame(height: 200)

                    // Quick Action Buttons
                    HStack(spacing: 10) {
                        QuickActionBtn(icon: "note.text.badge.plus", label: "Log Entry", color: NurseryTheme.teal) { showingAddEntry = true }
                        QuickActionBtn(icon: child.isCheckedIn ? "arrow.left.circle" : "arrow.right.circle", label: child.isCheckedIn ? "Check Out" : "Check In", color: .green) { toggleCheckIn() }
                        QuickActionBtn(icon: "fork.knife", label: "Meal Log", color: NurseryTheme.primary) { showingMealLog = true }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    // Allergen Banner
                    if child.hasAllergens {
                        AllergenBanner(allergens: child.allergens, severity: child.allergenSeverity)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    }

                    // Info Tabs
                    Picker("", selection: $selectedTab) {
                        Text("Info").tag(0)
                        Text("Diary (\(childEntries.count))").tag(1)
                        Text("Health").tag(2)
                        Text("Consent").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    switch selectedTab {
                    case 0: infoTab
                    case 1: diaryTab
                    case 2: healthTab
                    default: consentTab
                    }

                    Spacer(minLength: 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(child.preferredName)
        .sheet(isPresented: $showingAddEntry) {
            AddDiaryEntryView(child: child)
        }
        .sheet(isPresented: $showingMealLog) {
            MealLogView(child: child)
        }
    }

    var infoTab: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Personal").sectionHeaderStyle().padding(.bottom, 4)
                InfoRow(label: "Preferred Name", value: child.preferredName)
                InfoRow(label: "Date of Birth",  value: child.dateOfBirth.mediumDateString)
                InfoRow(label: "Room",            value: child.room)
                InfoRow(label: "Keyworker",       value: child.keyworkerName)
                if !child.secondaryKeyworker.isEmpty {
                    InfoRow(label: "Secondary KW", value: child.secondaryKeyworker)
                }
                InfoRow(label: "Session Times",   value: child.sessionTimes)
            }
            .cardStyle()

            VStack(alignment: .leading, spacing: 4) {
                Text("Family").sectionHeaderStyle().padding(.bottom, 4)
                InfoRow(label: "Parent 1", value: child.parentOneName)
                InfoRow(label: "Phone",    value: child.parentOnePhone)
                InfoRow(label: "Email",    value: child.parentOneEmail)
                if !child.parentTwoName.isEmpty {
                    InfoRow(label: "Parent 2", value: child.parentTwoName)
                    InfoRow(label: "Phone",    value: child.parentTwoPhone)
                }
                Divider()
                InfoRow(label: "Emergency",       value: child.emergencyContactName)
                InfoRow(label: "E/C Relationship",value: child.emergencyContactRelationship)
                InfoRow(label: "E/C Phone",       value: child.emergencyContactPhone)
            }
            .cardStyle()

            if !child.authorisedCollectors.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Authorised Collectors").sectionHeaderStyle().padding(.bottom, 4)
                    ForEach(child.authorisedCollectors.components(separatedBy: ","), id: \.self) { collector in
                        HStack {
                            Image(systemName: "checkmark.shield.fill").foregroundStyle(.green).font(.system(size: 12))
                            Text(collector.trimmingCharacters(in: .whitespaces))
                                .font(.system(size: 13))
                                .foregroundStyle(NurseryTheme.textPrimary)
                        }
                    }
                }
                .cardStyle()
            }
        }
        .padding(.horizontal, 16)
    }

    var diaryTab: some View {
        VStack(spacing: 10) {
            if childEntries.isEmpty {
                EmptyStateView(icon: "note.text", title: "No Entries Today", message: "Tap 'Log Entry' to add the first diary entry.")
            } else {
                ForEach(childEntries) { entry in
                    DiaryEntryDetailCard(entry: entry)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    var healthTab: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Medical Information").sectionHeaderStyle().padding(.bottom, 4)
                if child.hasAllergens {
                    InfoRow(label: "Allergens", value: child.allergenList, valueColor: .orange)
                    InfoRow(label: "Severity",  value: child.allergenSeverity.capitalized, valueColor: child.allergenSeverity == "anaphylactic" ? .red : .orange)
                }
                InfoRow(label: "Dietary Needs", value: child.dietaryRequirements.isEmpty ? "None" : child.dietaryRequirements)
                InfoRow(label: "Medical Conditions", value: child.medicalConditions.isEmpty ? "None" : child.medicalConditions)
                InfoRow(label: "Medications", value: child.medications.isEmpty ? "None" : child.medications)
                InfoRow(label: "GP Name",     value: child.gpName.isEmpty ? "Not provided" : child.gpName)
                InfoRow(label: "GP Phone",    value: child.gpPhone.isEmpty ? "Not provided" : child.gpPhone)
                InfoRow(label: "NHS Number",  value: child.nhsNumber.isEmpty ? "Not provided" : child.nhsNumber)
            }
            .cardStyle()

            if child.sendFlag {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill").foregroundStyle(NurseryTheme.primary)
                    Text("SEND flag on file — refer to EHCP documentation.")
                        .font(.system(size: 13))
                        .foregroundStyle(NurseryTheme.textPrimary)
                }
                .cardStyle()
            }

            GDPRNoticeBanner()
        }
        .padding(.horizontal, 16)
    }

    var consentTab: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Consent Records").sectionHeaderStyle().padding(.bottom, 4)
                ConsentRow(label: "Data Processing",  granted: child.dataProcessingConsent)
                ConsentRow(label: "Photography",       granted: child.photographyConsent)
                ConsentRow(label: "Social Media",      granted: child.socialMediaConsent)
                ConsentRow(label: "Video Recording",   granted: child.videoConsent)
                ConsentRow(label: "GPS Tracking",      granted: child.gpsConsent)
                ConsentRow(label: "Medical Treatment", granted: child.medicalTreatmentConsent)
            }
            .cardStyle()

            GDPRNoticeBanner()
        }
        .padding(.horizontal, 16)
    }

    private func toggleCheckIn() {
        if child.isCheckedIn {
            child.isCheckedIn = false
            child.checkInTime = nil
        } else {
            child.isCheckedIn = true
            child.checkInTime = Date()
            child.checkInBy   = appState.currentUserName

            let entry = DiaryEntry(childId: child.id, childName: child.fullName,
                                   entryType: "checkin",
                                   description: "Checked in by \(appState.currentUserName)",
                                   keyworkerName: appState.currentUserName)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct QuickActionBtn: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ConsentRow: View {
    let label: String
    let granted: Bool

    var body: some View {
        HStack {
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(granted ? .green : .red)
                .font(.system(size: 16))
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(NurseryTheme.textPrimary)
            Spacer()
            Text(granted ? "Granted" : "Withdrawn")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(granted ? .green : .red)
        }
        .padding(.vertical, 2)
    }
}

struct DiaryEntryDetailCard: View {
    let entry: DiaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(entry.entryColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: entry.entryIcon)
                        .foregroundStyle(entry.entryColor)
                        .font(.system(size: 15))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.entryTypeDisplay)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(entry.entryColor)
                    Text(entry.timestamp.shortTimeString)
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                Spacer()
                Text(entry.keyworkerName.components(separatedBy: " ").first ?? "")
                    .font(.system(size: 11))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }

            Text(entry.entryNote)
                .font(.system(size: 13))
                .foregroundStyle(NurseryTheme.textPrimary)

            if entry.entryType == "meal" && !entry.foodConsumed.isEmpty {
                HStack {
                    Text("Consumed: ").font(.system(size: 12, weight: .medium)).foregroundStyle(NurseryTheme.textSecondary)
                    Text(entry.foodConsumed.capitalized).font(.system(size: 12)).foregroundStyle(entry.consumptionColor)
                    if entry.fluidAmount > 0 {
                        Text("· \(entry.fluidType) \(entry.fluidAmount)ml")
                            .font(.system(size: 12))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                }
            }

            if entry.entryType == "sleep", let start = entry.sleepStart, let end = entry.sleepEnd {
                let mins = Int(end.timeIntervalSince(start) / 60)
                HStack {
                    Image(systemName: "moon.fill").foregroundStyle(NurseryTheme.indigo).font(.system(size: 11))
                    Text("\(start.shortTimeString) – \(end.shortTimeString) (\(mins) min)")
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }
        }
        .cardStyle()
    }
}

private extension DiaryEntry {
    var consumptionColor: Color {
        switch foodConsumed {
        case "all", "most": return .green
        case "half": return .orange
        default: return .red
        }
    }
}
