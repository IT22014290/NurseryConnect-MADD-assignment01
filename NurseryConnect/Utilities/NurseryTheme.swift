import SwiftUI

// MARK: - NurseryConnect Design System
// Professional childcare colour palette — warm but authoritative

struct NurseryTheme {

    // MARK: - Brand Colours
    static let primary      = Color(hex: "2A9D8F")   // Teal — trust, care
    static let primaryLight = Color(hex: "52B8AC")
    static let primaryDark  = Color(hex: "1E7268")

    static let accent       = Color(hex: "E9C46A")   // Warm amber — nurturing
    static let accentDeep   = Color(hex: "F4A261")   // Deeper amber

    static let danger       = Color(hex: "E76F51")   // Alert — safeguarding
    static let dangerLight  = Color(hex: "F4A394")

    // MARK: - Surface Colours
    static let background   = Color(hex: "F8F9FA")
    static let cardSurface  = Color.white
    static let cardBorder   = Color(hex: "E2E8F0")

    // MARK: - Text
    static let textPrimary   = Color(hex: "1A202C")
    static let textSecondary = Color(hex: "718096")
    static let textMuted     = Color(hex: "A0AEC0")

    // MARK: - Status Colours
    static let statusGreen  = Color(hex: "38A169")
    static let statusOrange = Color(hex: "DD6B20")
    static let statusBlue   = Color(hex: "3182CE")
    static let statusGray   = Color(hex: "718096")

    // MARK: - Entry Type Colours
    static let entryGreen   = Color(hex: "38A169")
    static let entryBlue    = Color(hex: "4299E1")
    static let entryPurple  = Color(hex: "805AD5")
    static let entryOrange  = Color(hex: "ED8936")
    static let entryTeal    = Color(hex: "319795")
    static let entryPink    = Color(hex: "D53F8C")
    static let entryYellow  = Color(hex: "D69E2E")
    static let entryGray    = Color(hex: "718096")

    // MARK: - Typography helpers
    static let headlineLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineMedium = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let label = Font.system(size: 13, weight: .medium)

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat  = 8
    static let spacingM: CGFloat  = 12
    static let spacingL: CGFloat  = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // MARK: - Corner Radius
    static let cornerS: CGFloat  = 8
    static let cornerM: CGFloat  = 12
    static let cornerL: CGFloat  = 16
    static let cornerXL: CGFloat = 24
}

// MARK: - Color Hex Initialiser
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - DiaryEntryType colour helper
extension DiaryEntryType {
    var themeColor: Color {
        switch self {
        case .checkIn:    return NurseryTheme.entryGreen
        case .activity:   return NurseryTheme.entryBlue
        case .sleep:      return NurseryTheme.entryPurple
        case .meal:       return NurseryTheme.entryOrange
        case .nappy:      return NurseryTheme.entryTeal
        case .wellbeing:  return NurseryTheme.entryPink
        case .milestone:  return NurseryTheme.entryYellow
        case .checkOut:   return NurseryTheme.entryGray
        }
    }
}

extension IncidentCategory {
    var themeColor: Color {
        switch self {
        case .minorAccident:        return NurseryTheme.entryOrange
        case .requiresFirstAid:     return NurseryTheme.accentDeep
        case .safeguardingConcern:  return NurseryTheme.danger
        case .nearMiss:             return NurseryTheme.entryYellow
        case .allergicReaction:     return NurseryTheme.danger
        case .medicalIncident:      return NurseryTheme.danger
        }
    }
}

extension IncidentStatus {
    var themeColor: Color {
        switch self {
        case .draft:          return NurseryTheme.statusGray
        case .pendingReview:  return NurseryTheme.statusOrange
        case .approved:       return NurseryTheme.statusBlue
        case .acknowledged:   return NurseryTheme.statusGreen
        }
    }
}
