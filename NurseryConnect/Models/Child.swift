import Foundation
import SwiftData

// MARK: - Child Model
// Represents a child registered in the nursery assigned to this keyworker.
// Data minimisation principle: keyworkers only see their assigned children (UK GDPR Article 5).

@Model
final class Child {
    var id: UUID
    var firstName: String
    var lastName: String
    var preferredName: String
    var dateOfBirth: Date
    var room: String
    var keyworkerName: String
    var photoConsent: Bool
    var allergies: [String]
    var dietaryRequirements: String
    var medicalConditions: String
    var isPresent: Bool
    var avatarColorHex: String

    // EYFS: each child must have a named keyworker (Section 3.27)
    // UK GDPR Art 9: dietary/medical info is Special Category Data requiring explicit consent

    @Relationship(deleteRule: .cascade)
    var diaryEntries: [DiaryEntry]

    @Relationship(deleteRule: .cascade)
    var incidentReports: [IncidentReport]

    init(
        firstName: String,
        lastName: String,
        preferredName: String = "",
        dateOfBirth: Date,
        room: String = "Sunshine Room",
        keyworkerName: String = "Sarah Mitchell",
        photoConsent: Bool = true,
        allergies: [String] = [],
        dietaryRequirements: String = "None",
        medicalConditions: String = "None",
        avatarColorHex: String = "2A9D8F"
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredName = preferredName.isEmpty ? firstName : preferredName
        self.dateOfBirth = dateOfBirth
        self.room = room
        self.keyworkerName = keyworkerName
        self.photoConsent = photoConsent
        self.allergies = allergies
        self.dietaryRequirements = dietaryRequirements
        self.medicalConditions = medicalConditions
        self.isPresent = true
        self.avatarColorHex = avatarColorHex
        self.diaryEntries = []
        self.incidentReports = []
    }

    // MARK: - Computed Properties

    var displayName: String {
        preferredName.isEmpty ? firstName : preferredName
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var ageString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) yr\(years == 1 ? "" : "s")"
        } else if let months = components.month {
            return "\(months) mo"
        }
        return "Newborn"
    }

    var hasAllergies: Bool {
        !allergies.isEmpty
    }

    var todayEntries: [DiaryEntry] {
        let calendar = Calendar.current
        return diaryEntries
            .filter { calendar.isDateInToday($0.timestamp) }
            .sorted { $0.timestamp < $1.timestamp }
    }

    var openIncidents: [IncidentReport] {
        incidentReports.filter { $0.status != .acknowledged }
    }
}
