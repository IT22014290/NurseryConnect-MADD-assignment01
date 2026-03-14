import SwiftUI
import SwiftData

// MARK: - Add Diary Entry
// Contextual form that adapts based on the selected entry type.
// FR13–FR16: captures all EYFS-required data points per entry type.

struct AddDiaryEntryView: View {

    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var entryType: DiaryEntryType = .activity
    @State private var notes = ""
    @State private var isSaving = false
    @State private var showConfirmation = false

    // Activity
    @State private var activityTitle = ""
    @State private var eyfsArea: EYFSArea = .none

    // Sleep
    @State private var sleepStart = Date().addingTimeInterval(-3600)
    @State private var sleepEnd = Date()
    @State private var sleepPosition = "Back"

    // Meal
    @State private var mealType = "Lunch"
    @State private var foodOffered = ""
    @State private var foodConsumed: MealConsumption = .most
    @State private var fluidType = "Water"
    @State private var fluidAmount = 150

    // Nappy
    @State private var nappyType = "Wet"
    @State private var nappyConcerns = ""
    @State private var creamApplied = false

    // Wellbeing
    @State private var moodRating: MoodRating = .happy
    @State private var wellbeingNotes = ""

    // Milestone
    @State private var milestoneTitle = ""
    @State private var milestoneEYFS: EYFSArea = .none
    @State private var milestoneNextSteps = ""

    // Check-out
    @State private var collectedBy = ""
    @State private var collectedByRelationship = ""

    private let sleepPositions = ["Back", "Side", "Front (Supervised)"]
    private let mealTypes = ["Breakfast", "Morning Snack", "Lunch", "Afternoon Snack", "Tea"]
    private let fluidTypes = ["Water", "Milk", "Milk (Full-Fat)", "Diluted Juice", "Breast Milk", "Formula"]
    private let nappyTypes = ["Wet", "Dirty", "Both", "None — checked only"]

    var body: some View {
        NavigationStack {
            Form {
                // Entry Type Picker
                Section {
                    VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                        Text("Entry Type")
                            .font(NurseryTheme.label)
                            .foregroundColor(NurseryTheme.textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: NurseryTheme.spacingS) {
                                ForEach(DiaryEntryType.allCases, id: \.self) { type in
                                    entryTypeChip(type)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Child info banner
                Section {
                    HStack(spacing: NurseryTheme.spacingM) {
                        ChildAvatar(child: child, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(child.displayName)
                                .font(NurseryTheme.bodyMedium)
                                .fontWeight(.semibold)
                            Text(child.room)
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textSecondary)
                        }
                        if child.hasAllergies {
                            Spacer()
                            AllergyBadge(allergen: "⚠ Check Allergies")
                        }
                    }
                }

                // Contextual Fields
                contextualFields

                // General Notes
                if entryType != .nappy && entryType != .checkIn && entryType != .checkOut {
                    Section("Observations / Notes") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .font(NurseryTheme.bodyMedium)
                    }
                }
            }
            .navigationTitle("Add \(entryType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(NurseryTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveEntry()
                    } label: {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving || !isValid)
                    .padding(.horizontal, NurseryTheme.spacingM)
                    .padding(.vertical, 6)
                    .background(isValid ? NurseryTheme.primary : NurseryTheme.textMuted)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
        }
        .overlay(
            Group {
                if showConfirmation {
                    VStack {
                        Spacer()
                        HStack(spacing: NurseryTheme.spacingS) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(NurseryTheme.statusGreen)
                            Text("Entry saved for \(child.displayName)")
                                .font(NurseryTheme.bodyMedium)
                                .fontWeight(.medium)
                        }
                        .padding(NurseryTheme.spacingM)
                        .background(NurseryTheme.cardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerM))
                        .shadow(radius: 8)
                        .padding(.bottom, NurseryTheme.spacingXL)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: showConfirmation)
                }
            }
        )
    }

    // MARK: - Contextual Fields

    @ViewBuilder
    private var contextualFields: some View {
        switch entryType {
        case .activity:
            activitySection
        case .sleep:
            sleepSection
        case .meal:
            mealSection
        case .nappy:
            nappySection
        case .wellbeing:
            wellbeingSection
        case .milestone:
            milestoneSection
        case .checkIn:
            checkInSection
        case .checkOut:
            checkOutSection
        }
    }

    // MARK: - Activity Section
    private var activitySection: some View {
        Section("Activity Details") {
            TextField("Activity title (e.g. Outdoor Sand Play)", text: $activityTitle)
            Picker("EYFS Area", selection: $eyfsArea) {
                ForEach(EYFSArea.allCases, id: \.self) { area in
                    Text(area.rawValue).tag(area)
                }
            }
        }
    }

    // MARK: - Sleep Section
    private var sleepSection: some View {
        Section("Sleep Details") {
            DatePicker("Start Time", selection: $sleepStart, displayedComponents: .hourAndMinute)
            DatePicker("End Time", selection: $sleepEnd, in: sleepStart..., displayedComponents: .hourAndMinute)

            HStack {
                Text("Duration")
                    .foregroundColor(NurseryTheme.textSecondary)
                Spacer()
                let diff = sleepEnd.timeIntervalSince(sleepStart)
                if diff > 0 {
                    let h = Int(diff) / 3600
                    let m = (Int(diff) % 3600) / 60
                    Text(h > 0 ? "\(h)h \(m)m" : "\(m)m")
                        .foregroundColor(NurseryTheme.primary)
                        .fontWeight(.semibold)
                } else {
                    Text("—").foregroundColor(NurseryTheme.textMuted)
                }
            }

            Picker("Sleep Position", selection: $sleepPosition) {
                ForEach(sleepPositions, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Meal Section
    private var mealSection: some View {
        Group {
            Section("Meal Details") {
                Picker("Meal Type", selection: $mealType) {
                    ForEach(mealTypes, id: \.self) { Text($0) }
                }
                TextField("Food offered (e.g. Chicken, roasted veg)", text: $foodOffered)
            }

            Section("Consumption") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(MealConsumption.allCases, id: \.self) { option in
                        consumptionButton(option)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Fluid Intake") {
                Picker("Type", selection: $fluidType) {
                    ForEach(fluidTypes, id: \.self) { Text($0) }
                }
                Stepper("\(fluidAmount) ml", value: $fluidAmount, in: 0...500, step: 30)
            }
        }
    }

    private func consumptionButton(_ option: MealConsumption) -> some View {
        Button {
            foodConsumed = option
        } label: {
            VStack(spacing: 4) {
                Image(systemName: option.icon)
                    .font(.system(size: 16))
                Text(option.rawValue)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(foodConsumed == option ? NurseryTheme.primary.opacity(0.15) : NurseryTheme.background)
            .foregroundColor(foodConsumed == option ? NurseryTheme.primary : NurseryTheme.textSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: NurseryTheme.cornerS)
                    .stroke(foodConsumed == option ? NurseryTheme.primary : NurseryTheme.cardBorder, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerS))
        }
    }

    // MARK: - Nappy Section
    private var nappySection: some View {
        Section("Nappy Details") {
            Picker("Type", selection: $nappyType) {
                ForEach(nappyTypes, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)

            Toggle("Cream Applied", isOn: $creamApplied)

            TextField("Any concerns (optional)", text: $nappyConcerns)
        }
    }

    // MARK: - Wellbeing Section
    private var wellbeingSection: some View {
        Section("Wellbeing Check") {
            VStack(alignment: .leading, spacing: NurseryTheme.spacingM) {
                Text("Mood")
                    .font(NurseryTheme.label)
                    .foregroundColor(NurseryTheme.textSecondary)

                HStack(spacing: NurseryTheme.spacingM) {
                    ForEach(MoodRating.allCases, id: \.self) { mood in
                        moodButton(mood)
                    }
                }
            }
            .padding(.vertical, 4)

            TextField("Observations", text: $wellbeingNotes)
        }
    }

    private func moodButton(_ mood: MoodRating) -> some View {
        Button {
            moodRating = mood
        } label: {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                Text(mood.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(moodRating == mood ? NurseryTheme.primary : NurseryTheme.textSecondary)
            }
            .padding(6)
            .background(moodRating == mood ? NurseryTheme.primary.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerS))
        }
    }

    // MARK: - Milestone Section
    private var milestoneSection: some View {
        Group {
            Section("Milestone Details") {
                TextField("Milestone title", text: $milestoneTitle)
                Picker("EYFS Area", selection: $milestoneEYFS) {
                    ForEach(EYFSArea.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
            }
            Section("Next Steps") {
                TextEditor(text: $milestoneNextSteps)
                    .frame(minHeight: 64)
                    .font(NurseryTheme.bodyMedium)
            }
        }
    }

    // MARK: - Check-In Section
    private var checkInSection: some View {
        Section("Arrival Details") {
            TextField("Dropped off by (e.g. Mum — Sarah)", text: $collectedBy)
            moodSection("Mood on Arrival")
        }
    }

    // MARK: - Check-Out Section
    private var checkOutSection: some View {
        Section("Departure Details") {
            TextField("Collected by (name)", text: $collectedBy)
            TextField("Relationship (e.g. Father, Grandparent)", text: $collectedByRelationship)
            moodSection("Mood at Departure")
        }
    }

    private func moodSection(_ label: String) -> some View {
        VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
            Text(label)
                .font(NurseryTheme.label)
                .foregroundColor(NurseryTheme.textSecondary)
            HStack(spacing: NurseryTheme.spacingM) {
                ForEach(MoodRating.allCases, id: \.self) { mood in
                    moodButton(mood)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Entry Type Chip
    private func entryTypeChip(_ type: DiaryEntryType) -> some View {
        Button {
            withAnimation(.spring(response: 0.25)) { entryType = type }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: type.systemImage)
                    .font(.system(size: 13))
                Text(type.rawValue)
                    .font(NurseryTheme.label)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(entryType == type ? type.themeColor : NurseryTheme.background)
            .foregroundColor(entryType == type ? .white : NurseryTheme.textSecondary)
            .overlay(
                Capsule()
                    .stroke(entryType == type ? Color.clear : NurseryTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
    }

    // MARK: - Validation
    private var isValid: Bool {
        switch entryType {
        case .activity:  return !activityTitle.isEmpty
        case .milestone: return !milestoneTitle.isEmpty
        case .meal:      return !foodOffered.isEmpty
        default:         return true
        }
    }

    // MARK: - Save
    private func saveEntry() {
        isSaving = true
        let entry = DiaryEntry(timestamp: Date(), entryType: entryType, notes: notes)

        switch entryType {
        case .activity:
            entry.activityTitle = activityTitle
            entry.eyfsArea = eyfsArea
        case .sleep:
            entry.sleepStartTime = sleepStart
            entry.sleepEndTime = sleepEnd
            entry.sleepPosition = sleepPosition
        case .meal:
            entry.mealType = mealType
            entry.foodOffered = foodOffered
            entry.foodConsumed = foodConsumed
            entry.fluidType = fluidType
            entry.fluidAmountMl = fluidAmount
        case .nappy:
            entry.nappyType = nappyType
            entry.nappyConcerns = nappyConcerns
            entry.creamApplied = creamApplied
        case .wellbeing:
            entry.moodRating = moodRating
            entry.wellbeingNotes = wellbeingNotes
        case .milestone:
            entry.milestoneTitle = milestoneTitle
            entry.milestoneEYFSArea = milestoneEYFS
            entry.milestoneNextSteps = milestoneNextSteps
        case .checkIn, .checkOut:
            entry.collectedBy = collectedBy
            entry.collectedByRelationship = collectedByRelationship
            entry.moodRating = moodRating
        }

        entry.child = child
        context.insert(entry)

        do {
            try context.save()
            withAnimation {
                showConfirmation = true
                isSaving = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            isSaving = false
        }
    }
}
