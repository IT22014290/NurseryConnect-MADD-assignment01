import Foundation
import SwiftData

// MARK: - Diary Entry Types
// FR13–FR18: Daily diary logging as required by EYFS statutory framework.

enum DiaryEntryType: String, Codable, CaseIterable {
    case checkIn     = "Check-In"
    case activity    = "Activity"
    case sleep       = "Sleep / Nap"
    case meal        = "Meal"
    case nappy       = "Nappy"
    case wellbeing   = "Wellbeing"
    case milestone   = "Milestone"
    case checkOut    = "Check-Out"

    var systemImage: String {
        switch self {
        case .checkIn:    return "arrow.right.circle.fill"
        case .activity:   return "figure.play"
        case .sleep:      return "moon.zzz.fill"
        case .meal:       return "fork.knife"
        case .nappy:      return "drop.fill"
        case .wellbeing:  return "heart.fill"
        case .milestone:  return "star.fill"
        case .checkOut:   return "arrow.left.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .checkIn:    return "EntryGreen"
        case .activity:   return "EntryBlue"
        case .sleep:      return "EntryPurple"
        case .meal:       return "EntryOrange"
        case .nappy:      return "EntryTeal"
        case .wellbeing:  return "EntryPink"
        case .milestone:  return "EntryYellow"
        case .checkOut:   return "EntryGray"
        }
    }
}

// EYFS: mood/wellbeing monitoring at arrival, midday, departure
enum MoodRating: String, Codable, CaseIterable {
    case happy     = "Happy"
    case content   = "Content"
    case unsettled = "Unsettled"
    case upset     = "Upset"
    case poorly    = "Poorly"

    var emoji: String {
        switch self {
        case .happy:     return "😊"
        case .content:   return "🙂"
        case .unsettled: return "😐"
        case .upset:     return "😢"
        case .poorly:    return "🤒"
        }
    }
}

// FR30: Portion scale for meal consumption logging
enum MealConsumption: String, Codable, CaseIterable {
    case all     = "All"
    case most    = "Most"
    case half    = "Half"
    case little  = "Little"
    case none    = "None"
    case refused = "Refused"

    var icon: String {
        switch self {
        case .all:     return "circle.fill"
        case .most:    return "circle.lefthalf.filled"
        case .half:    return "circle.bottomhalf.filled"
        case .little:  return "circle.dotted"
        case .none:    return "circle"
        case .refused: return "xmark.circle"
        }
    }
}

// EYFS 2024: Seven Areas of Learning
enum EYFSArea: String, Codable, CaseIterable {
    case personalSocial       = "Personal, Social & Emotional"
    case communication        = "Communication & Language"
    case physical             = "Physical Development"
    case literacy             = "Literacy"
    case mathematics          = "Mathematics"
    case understandingWorld   = "Understanding the World"
    case expressiveArts       = "Expressive Arts & Design"
    case none                 = "General / Not Specified"
}

// MARK: - DiaryEntry Model

@Model
final class DiaryEntry {
    var id: UUID
    var timestamp: Date
    var entryType: DiaryEntryType
    var notes: String

    // Activity fields
    var activityTitle: String
    var eyfsArea: EYFSArea

    // Sleep/Nap fields (FR14)
    var sleepStartTime: Date?
    var sleepEndTime: Date?
    var sleepPosition: String      // "Back", "Side" — SIDS guidance for under-1s

    // Meal fields (FR30, FR31)
    var mealType: String           // Breakfast, Snack, Lunch, Dinner
    var foodOffered: String
    var foodConsumed: MealConsumption
    var fluidType: String          // Water, Milk, Juice
    var fluidAmountMl: Int

    // Nappy fields (FR15)
    var nappyType: String          // Wet, Dirty, Both, None
    var nappyConcerns: String
    var creamApplied: Bool

    // Wellbeing fields (FR16)
    var moodRating: MoodRating
    var wellbeingNotes: String

    // Milestone fields
    var milestoneTitle: String
    var milestoneEYFSArea: EYFSArea
    var milestoneNextSteps: String

    // Check-In / Check-Out
    var collectedBy: String
    var collectedByRelationship: String

    var child: Child?

    init(
        timestamp: Date = Date(),
        entryType: DiaryEntryType,
        notes: String = ""
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.entryType = entryType
        self.notes = notes

        self.activityTitle = ""
        self.eyfsArea = .none

        self.sleepStartTime = nil
        self.sleepEndTime = nil
        self.sleepPosition = "Back"

        self.mealType = "Lunch"
        self.foodOffered = ""
        self.foodConsumed = .all
        self.fluidType = "Water"
        self.fluidAmountMl = 150

        self.nappyType = "Wet"
        self.nappyConcerns = ""
        self.creamApplied = false

        self.moodRating = .happy
        self.wellbeingNotes = ""

        self.milestoneTitle = ""
        self.milestoneEYFSArea = .none
        self.milestoneNextSteps = ""

        self.collectedBy = ""
        self.collectedByRelationship = ""
    }

    // MARK: - Computed Properties

    var sleepDurationFormatted: String {
        guard let start = sleepStartTime, let end = sleepEndTime else { return "—" }
        let diff = end.timeIntervalSince(start)
        guard diff > 0 else { return "—" }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var summarySentence: String {
        switch entryType {
        case .checkIn:
            return "Arrived at nursery"
        case .activity:
            return activityTitle.isEmpty ? notes : activityTitle
        case .sleep:
            if let s = sleepStartTime, let e = sleepEndTime {
                let fmt = DateFormatter()
                fmt.timeStyle = .short
                return "Slept \(sleepDurationFormatted) (\(fmt.string(from: s))–\(fmt.string(from: e)))"
            }
            return notes
        case .meal:
            return "\(mealType): \(foodOffered.isEmpty ? "—" : foodOffered) — Ate \(foodConsumed.rawValue)"
        case .nappy:
            return "\(nappyType) nappy\(nappyConcerns.isEmpty ? "" : " — Note: \(nappyConcerns)")"
        case .wellbeing:
            return "\(moodRating.emoji) \(moodRating.rawValue)\(wellbeingNotes.isEmpty ? "" : " — \(wellbeingNotes)")"
        case .milestone:
            return milestoneTitle.isEmpty ? notes : milestoneTitle
        case .checkOut:
            let by = collectedBy.isEmpty ? "Parent/Guardian" : collectedBy
            return "Collected by \(by)"
        }
    }
}
