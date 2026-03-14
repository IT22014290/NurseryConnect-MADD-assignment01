import Foundation
import SwiftData

// MARK: - Sample Data
// Realistic demo data for testing and presentation purposes.

struct SampleData {

    static func populate(context: ModelContext) {
        // Only insert if no children exist yet
        let descriptor = FetchDescriptor<Child>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let children = makeSampleChildren()
        children.forEach { context.insert($0) }

        // Add diary entries for each child
        addDiaryEntries(for: children[0])
        addDiaryEntries(for: children[1])

        // Add incident report
        let incident = IncidentReport(
            category: .minorAccident,
            location: "Outdoor Play Area",
            incidentDescription: "Oliver tripped on uneven paving and grazed his right knee. No bleeding, surface graze only.",
            actionTaken: "Area cleaned with antiseptic wipe. Comfort provided. Child settled quickly and resumed play."
        )
        incident.child = children[0]
        incident.status = .pendingReview
        incident.bodyMapLocation = .rightLeg
        incident.submittedAt = Date().addingTimeInterval(-3600)
        incident.witnesses = ["Emma Clarke", "Tom Bennett"]
        context.insert(incident)

        // Add a second incident (already acknowledged)
        let incident2 = IncidentReport(
            category: .nearMiss,
            location: "Craft Room",
            incidentDescription: "Amara reached for scissors that were left within reach on the table. No injury occurred.",
            actionTaken: "Scissors secured in designated locked storage. All staff reminded of tool safety protocol."
        )
        incident2.child = children[1]
        incident2.status = .acknowledged
        incident2.submittedAt = Date().addingTimeInterval(-86400)
        incident2.managerSignedAt = Date().addingTimeInterval(-82800)
        incident2.parentNotifiedAt = Date().addingTimeInterval(-79200)
        incident2.parentAcknowledgedAt = Date().addingTimeInterval(-75600)
        incident2.managerName = "Jennifer Walters"
        context.insert(incident2)

        try? context.save()
    }

    // MARK: - Private helpers

    private static func makeSampleChildren() -> [Child] {
        let calendar = Calendar.current

        let oliver = Child(
            firstName: "Oliver",
            lastName: "Thompson",
            preferredName: "Ollie",
            dateOfBirth: calendar.date(byAdding: .year, value: -3, to: Date())!,
            room: "Sunshine Room",
            keyworkerName: "Sarah Mitchell",
            photoConsent: true,
            allergies: ["Peanuts", "Tree Nuts"],
            dietaryRequirements: "No nuts. Check all labels.",
            medicalConditions: "Mild eczema — use prescribed cream during nappy changes.",
            avatarColorHex: "3182CE"
        )

        let amara = Child(
            firstName: "Amara",
            lastName: "Osei",
            preferredName: "Amara",
            dateOfBirth: calendar.date(byAdding: .month, value: -22, to: Date())!,
            room: "Rainbow Room",
            keyworkerName: "Sarah Mitchell",
            photoConsent: true,
            allergies: [],
            dietaryRequirements: "Vegetarian",
            medicalConditions: "None",
            avatarColorHex: "D53F8C"
        )

        let jack = Child(
            firstName: "Jack",
            lastName: "Williams",
            preferredName: "Jack",
            dateOfBirth: calendar.date(byAdding: .year, value: -4, to: Date())!,
            room: "Sunshine Room",
            keyworkerName: "Sarah Mitchell",
            photoConsent: false,   // No photo consent — visible red flag
            allergies: ["Eggs", "Dairy"],
            dietaryRequirements: "Dairy-free and egg-free. Full-fat alternatives required.",
            medicalConditions: "Asthma — blue inhaler kept in medical cabinet.",
            avatarColorHex: "805AD5"
        )

        return [oliver, amara, jack]
    }

    private static func addDiaryEntries(for child: Child) {
        let now = Date()
        let calendar = Calendar.current

        // Check-in
        let checkIn = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 8, minute: 15, second: 0, of: now)!,
            entryType: .checkIn,
            notes: "Arrived happy, gave Mum a big wave goodbye."
        )
        checkIn.moodRating = .happy
        checkIn.collectedBy = child.firstName == "Oliver" ? "Sophie Thompson (Mum)" : "David Osei (Dad)"
        checkIn.child = child

        // Wellbeing on arrival
        let wellbeing1 = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 8, minute: 20, second: 0, of: now)!,
            entryType: .wellbeing
        )
        wellbeing1.moodRating = .happy
        wellbeing1.wellbeingNotes = "Settled immediately, went straight to the book corner."
        wellbeing1.child = child

        // Activity
        let activity = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: now)!,
            entryType: .activity
        )
        activity.activityTitle = "Outdoor Sand & Water Play"
        activity.eyfsArea = .physical
        activity.notes = "Fantastic engagement with the sand tray. Experimented with filling and emptying containers."
        activity.child = child

        // Snack
        let snack = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!,
            entryType: .meal
        )
        snack.mealType = "Morning Snack"
        snack.foodOffered = "Apple slices, water"
        snack.foodConsumed = .all
        snack.fluidType = "Water"
        snack.fluidAmountMl = 120
        snack.child = child

        // Nappy (for younger child)
        if child.firstName == "Amara" {
            let nappy = DiaryEntry(
                timestamp: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!,
                entryType: .nappy
            )
            nappy.nappyType = "Wet"
            nappy.creamApplied = true
            nappy.nappyConcerns = ""
            nappy.child = child
        }

        // Sleep
        let sleep = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 12, minute: 30, second: 0, of: now)!,
            entryType: .sleep
        )
        sleep.sleepStartTime = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: now)
        sleep.sleepEndTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)
        sleep.sleepPosition = "Back"
        sleep.notes = "Settled well, uninterrupted nap."
        sleep.child = child

        // Lunch
        let lunch = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 11, minute: 45, second: 0, of: now)!,
            entryType: .meal
        )
        lunch.mealType = "Lunch"
        lunch.foodOffered = child.firstName == "Amara" ? "Vegetable pasta, fruit salad" : "Chicken with roasted vegetables, pear"
        lunch.foodConsumed = .most
        lunch.fluidType = "Water"
        lunch.fluidAmountMl = 180
        lunch.child = child

        // Milestone
        let milestone = DiaryEntry(
            timestamp: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now)!,
            entryType: .milestone
        )
        milestone.milestoneTitle = child.firstName == "Oliver"
            ? "Counted objects to 10 independently"
            : "First independent steps across the room — 6 steps!"
        milestone.milestoneEYFSArea = child.firstName == "Oliver" ? .mathematics : .physical
        milestone.milestoneNextSteps = child.firstName == "Oliver"
            ? "Introduce counting beyond 10 using number cards."
            : "Encourage furniture cruising and supported walking outdoors."
        milestone.notes = "Wonderful moment — capturing for learning journal."
        milestone.child = child
    }
}
