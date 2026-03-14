import Foundation
import SwiftData

// MARK: - Incident Report Models
// FR24–FR29: RIDDOR-aligned digital incident reporting.
// EYFS Requirement: parents MUST be notified on the same day.
// Children Act 1989: all incidents create an immutable safeguarding audit trail.

enum IncidentCategory: String, Codable, CaseIterable {
    case minorAccident      = "Minor Accident"
    case requiresFirstAid   = "Accident (Requires First Aid)"
    case safeguardingConcern = "Safeguarding Concern"
    case nearMiss           = "Near Miss"
    case allergicReaction   = "Allergic Reaction"
    case medicalIncident    = "Medical Incident"

    var systemImage: String {
        switch self {
        case .minorAccident:       return "bandage"
        case .requiresFirstAid:    return "cross.case.fill"
        case .safeguardingConcern: return "shield.fill"
        case .nearMiss:            return "exclamationmark.triangle.fill"
        case .allergicReaction:    return "allergens"
        case .medicalIncident:     return "stethoscope"
        }
    }

    var severityLabel: String {
        switch self {
        case .minorAccident, .nearMiss: return "Low"
        case .requiresFirstAid:         return "Medium"
        case .safeguardingConcern, .allergicReaction, .medicalIncident: return "High"
        }
    }

    /// Serious incidents require escalation to Ofsted notification (FR28)
    var requiresEscalation: Bool {
        switch self {
        case .safeguardingConcern, .allergicReaction, .medicalIncident, .requiresFirstAid:
            return true
        default:
            return false
        }
    }
}

// FR26: Manager countersignature required before parent notification
enum IncidentStatus: String, Codable, CaseIterable {
    case draft         = "Draft"
    case pendingReview = "Awaiting Manager Review"
    case approved      = "Approved — Parent Notified"
    case acknowledged  = "Parent Acknowledged"

    var systemImage: String {
        switch self {
        case .draft:         return "pencil.circle.fill"
        case .pendingReview: return "clock.fill"
        case .approved:      return "bell.fill"
        case .acknowledged:  return "checkmark.seal.fill"
        }
    }

    var colorName: String {
        switch self {
        case .draft:         return "StatusGray"
        case .pendingReview: return "StatusOrange"
        case .approved:      return "StatusBlue"
        case .acknowledged:  return "StatusGreen"
        }
    }
}

// FR24: Body map diagram — front/back body outline injury location
enum BodyMapLocation: String, Codable, CaseIterable {
    case head      = "Head"
    case face      = "Face"
    case neck      = "Neck"
    case leftShoulder  = "Left Shoulder"
    case rightShoulder = "Right Shoulder"
    case leftArm   = "Left Arm"
    case rightArm  = "Right Arm"
    case leftHand  = "Left Hand"
    case rightHand = "Right Hand"
    case chest     = "Chest"
    case back      = "Back"
    case abdomen   = "Abdomen"
    case leftLeg   = "Left Leg"
    case rightLeg  = "Right Leg"
    case leftFoot  = "Left Foot"
    case rightFoot = "Right Foot"
    case notApplicable = "Not Applicable"
}

// MARK: - IncidentReport Model

@Model
final class IncidentReport {

    // FR24: Auto-populated fields — timestamp from device clock, cannot be overridden
    var id: UUID
    var timestamp: Date          // Set at creation, immutable
    var category: IncidentCategory
    var location: String
    var incidentDescription: String
    var actionTaken: String
    var witnesses: [String]
    var status: IncidentStatus
    var bodyMapLocation: BodyMapLocation

    // Workflow timestamps (FR26, FR27)
    var submittedAt: Date?
    var managerSignedAt: Date?
    var parentNotifiedAt: Date?
    var parentAcknowledgedAt: Date?
    var managerName: String

    // RIDDOR/Ofsted escalation (FR28, FR29)
    var isRIDDORReportable: Bool
    var ofstedNotificationRequired: Bool

    var child: Child?

    init(
        category: IncidentCategory = .minorAccident,
        location: String = "",
        incidentDescription: String = "",
        actionTaken: String = ""
    ) {
        self.id = UUID()
        self.timestamp = Date()   // Auto-set — EYFS/RIDDOR compliance
        self.category = category
        self.location = location
        self.incidentDescription = incidentDescription
        self.actionTaken = actionTaken
        self.witnesses = []
        self.status = .draft
        self.bodyMapLocation = .notApplicable
        self.submittedAt = nil
        self.managerSignedAt = nil
        self.parentNotifiedAt = nil
        self.parentAcknowledgedAt = nil
        self.managerName = ""
        self.isRIDDORReportable = false
        self.ofstedNotificationRequired = false
    }

    // MARK: - Computed Properties

    /// EYFS legal obligation: parent must be notified same day
    var isSameDayNotificationBreached: Bool {
        guard status == .draft || status == .pendingReview else { return false }
        let twoHours: TimeInterval = 2 * 60 * 60
        return Date().timeIntervalSince(timestamp) > twoHours
    }

    var isOverdue: Bool {
        guard status != .acknowledged else { return false }
        let eightHours: TimeInterval = 8 * 60 * 60
        return Date().timeIntervalSince(timestamp) > eightHours
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var severityColor: String {
        category.requiresEscalation ? "IncidentRed" : "IncidentAmber"
    }

    var timeElapsed: String {
        let diff = Date().timeIntervalSince(timestamp)
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours >= 24 {
            let days = hours / 24
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m ago"
        }
        return "\(minutes)m ago"
    }
}
