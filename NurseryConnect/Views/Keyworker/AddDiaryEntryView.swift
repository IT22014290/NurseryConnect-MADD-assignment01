import SwiftUI
import SwiftData

struct AddDiaryEntryView: View {
    let child: Child
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var entryType = "activity"
    @State private var description = ""
    @State private var mood = "happy"
    @State private var eyfsArea = ""
    @State private var duration = 30

    // Sleep
    @State private var sleepStart = Date().addingTimeInterval(-3600)
    @State private var sleepEnd = Date()
    @State private var sleepPosition = "back"

    // Nappy
    @State private var nappyType = "wet"
    @State private var creamApplied = false

    // Meal
    @State private var mealType = "lunch"
    @State private var foodOffered = ""
    @State private var foodConsumed = "most"
    @State private var fluidType = "water"
    @State private var fluidAmount = 150

    let entryTypes = [
        ("activity",  "Activity",    "figure.play"),
        ("sleep",     "Sleep",       "moon.fill"),
        ("nappy",     "Nappy",       "drop.fill"),
        ("meal",      "Meal",        "fork.knife"),
        ("wellbeing", "Wellbeing",   "heart.fill"),
        ("milestone", "Milestone",   "star.fill"),
    ]
    let eyfsAreas = ["", "Communication & Language", "Physical Development", "Personal, Social & Emotional", "Literacy", "Mathematics", "Understanding the World", "Expressive Arts & Design"]
    let sleepPositions = ["back", "side"]
    let mealTypes = ["breakfast", "morning_snack", "lunch", "afternoon_snack"]
    let fluidTypes = ["water", "milk", "dairy-free milk", "juice (diluted)"]
    let nappyTypes = ["wet", "dirty", "both", "none"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Child Header
                    HStack(spacing: 12) {
                        ChildAvatarView(initials: child.initials, size: 44, color: NurseryTheme.teal, isCheckedIn: child.isCheckedIn)
                        VStack(alignment: .leading) {
                            Text(child.fullName)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Adding diary entry · \(Date().shortTimeString)")
                                .font(.system(size: 12))
                                .foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    // Entry Type Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Entry Type")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(NurseryTheme.textSecondary)
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(entryTypes, id: \.0) { (type, label, icon) in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) { entryType = type }
                                    } label: {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(entryType == type ? NurseryTheme.teal : NurseryTheme.teal.opacity(0.1))
                                                    .frame(width: 46, height: 46)
                                                Image(systemName: icon)
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(entryType == type ? .white : NurseryTheme.teal)
                                            }
                                            Text(label)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(entryType == type ? NurseryTheme.teal : NurseryTheme.textSecondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // Type-specific fields
                    VStack(spacing: 16) {
                        switch entryType {
                        case "sleep":     sleepFields
                        case "nappy":     nappyFields
                        case "meal":      mealFields
                        case "wellbeing": wellbeingFields
                        default:          activityFields
                        }
                    }
                    .padding(.horizontal, 16)

                    // Save Button
                    Button { save() } label: {
                        Label("Save Entry", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle(color: NurseryTheme.teal))
                    .padding(.horizontal, 16)
                    .disabled(description.isEmpty && entryType != "nappy" && entryType != "sleep" && entryType != "wellbeing")

                    Spacer(minLength: 32)
                }
                .padding(.top, 16)
            }
            .background(NurseryTheme.background)
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Type Fields

    var activityFields: some View {
        VStack(spacing: 14) {
            NurseryTextField(title: "Description *", text: $description, placeholder: "Describe the activity or observation...", isMultiline: true)

            if entryType == "milestone" || entryType == "activity" {
                VStack(alignment: .leading, spacing: 6) {
                    Text("EYFS Area (optional)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Picker("EYFS Area", selection: $eyfsArea) {
                        ForEach(eyfsAreas, id: \.self) { Text($0.isEmpty ? "Select area..." : $0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(NurseryTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    var sleepFields: some View {
        VStack(spacing: 14) {
            DatePicker("Sleep Start", selection: $sleepStart, displayedComponents: .hourAndMinute)
            DatePicker("Sleep End",   selection: $sleepEnd,   displayedComponents: .hourAndMinute)

            VStack(alignment: .leading, spacing: 6) {
                Text("Sleep Position").font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                Picker("Position", selection: $sleepPosition) {
                    Text("On Back").tag("back")
                    Text("On Side").tag("side")
                }
                .pickerStyle(.segmented)
            }

            let mins = max(0, Int(sleepEnd.timeIntervalSince(sleepStart) / 60))
            HStack {
                Image(systemName: "moon.stars.fill").foregroundStyle(NurseryTheme.indigo)
                Text("Duration: \(mins) minutes").font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
            }
            .padding(10).background(NurseryTheme.indigo.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 8))

            NurseryTextField(title: "Notes (optional)", text: $description, placeholder: "Any disturbances or observations...", isMultiline: false)
        }
    }

    var nappyFields: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nappy Type").font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                Picker("Type", selection: $nappyType) {
                    ForEach(nappyTypes, id: \.self) { Text($0.capitalized).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Toggle("Cream Applied", isOn: $creamApplied)
                .tint(NurseryTheme.teal)
            NurseryTextField(title: "Observations (optional)", text: $description, placeholder: "Any concerns or observations...", isMultiline: false)
        }
    }

    var mealFields: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Meal Type").font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                Picker("Meal", selection: $mealType) {
                    Text("Breakfast").tag("breakfast")
                    Text("AM Snack").tag("morning_snack")
                    Text("Lunch").tag("lunch")
                    Text("PM Snack").tag("afternoon_snack")
                }
                .pickerStyle(.segmented)
            }
            NurseryTextField(title: "Food Offered", text: $foodOffered, placeholder: "e.g. Pasta bolognese with garlic bread")
            ConsumptionSelector(selection: $foodConsumed)
            VStack(alignment: .leading, spacing: 6) {
                Text("Fluid Type").font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                Picker("Fluid", selection: $fluidType) {
                    ForEach(fluidTypes, id: \.self) { Text($0.capitalized).tag($0) }
                }.pickerStyle(.menu)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(NurseryTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Stepper("Fluid Amount: \(fluidAmount)ml", value: $fluidAmount, in: 0...500, step: 10)
                .font(.system(size: 14))
            if child.hasAllergens {
                AllergenBanner(allergens: child.allergens, severity: child.allergenSeverity)
            }
        }
    }

    var wellbeingFields: some View {
        VStack(spacing: 14) {
            MoodSelector(mood: $mood)
            NurseryTextField(title: "Observation Notes", text: $description, placeholder: "Describe the child's wellbeing, social engagement...", isMultiline: true)
        }
    }

    // MARK: - Save

    private func save() {
        let desc: String
        switch entryType {
        case "nappy":     desc = description.isEmpty ? "Nappy change: \(nappyType)\(creamApplied ? ", cream applied" : "")" : description
        case "wellbeing": desc = description.isEmpty ? "Wellbeing check. Mood: \(mood.capitalized)" : "Mood: \(mood.capitalized). \(description)"
        case "sleep":     desc = description.isEmpty ? "Sleep recorded. Position: \(sleepPosition)" : description
        default:          desc = description
        }

        let entry = DiaryEntry(childId: child.id, childName: child.fullName,
                               entryType: entryType, description: desc,
                               keyworkerName: appState.currentUserName)
        entry.eyfsArea    = eyfsArea
        entry.moodRating  = entryType == "wellbeing" ? mood : ""

        if entryType == "sleep" {
            entry.sleepStart    = sleepStart
            entry.sleepEnd      = sleepEnd
            entry.sleepPosition = sleepPosition
        }
        if entryType == "nappy" {
            entry.nappyType    = nappyType
            entry.creamApplied = creamApplied
        }
        if entryType == "meal" {
            entry.mealType    = mealType
            entry.foodConsumed = foodConsumed
            entry.fluidType   = fluidType
            entry.fluidAmount  = fluidAmount
        }

        modelContext.insert(entry)
        try? modelContext.save()
        dismiss()
    }
}
