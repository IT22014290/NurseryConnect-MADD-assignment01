import SwiftUI

// MARK: - Top Navigation Bar

struct NurseryNavBar: View {
    let title: String
    let subtitle: String
    var color: Color = NurseryTheme.primary
    var trailingContent: AnyView? = nil
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            color.ignoresSafeArea(edges: .top)
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        trailingContent
                        Button {
                            withAnimation { appState.selectedRole = nil }
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 17))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 14)
            }
        }
        .frame(height: 88)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = NurseryTheme.primary
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }
                Spacer()
            }
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(NurseryTheme.textPrimary)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NurseryTheme.textSecondary)
            if let sub = subtitle {
                Text(sub)
                    .font(.system(size: 10))
                    .foregroundStyle(color)
            }
        }
        .cardStyle()
    }
}

// MARK: - Child Avatar

struct ChildAvatarView: View {
    let initials: String
    let size: CGFloat
    var color: Color = NurseryTheme.primary
    var isCheckedIn: Bool = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(NurseryTheme.gradient(color))
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundStyle(.white)
            if isCheckedIn {
                Circle()
                    .fill(Color.green)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                    .offset(x: 2, y: 2)
            }
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()
            Spacer()
            if let action = action {
                Button(action, action: { onAction?() })
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(NurseryTheme.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}

// MARK: - Badge

struct BadgeView: View {
    let count: Int
    var color: Color = .red

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(color)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let label: String
    var color: Color = NurseryTheme.primary

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var color: Color = NurseryTheme.primary

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 46))
                .foregroundStyle(color.opacity(0.5))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(NurseryTheme.textPrimary)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(NurseryTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Allergen Warning Banner

struct AllergenBanner: View {
    let allergens: [String]
    let severity: String

    var color: Color {
        switch severity {
        case "anaphylactic": return .red
        case "allergy":      return .orange
        default:             return .yellow
        }
    }

    var icon: String {
        severity == "anaphylactic" ? "exclamationmark.triangle.fill" : "allergens"
    }

    var body: some View {
        if !allergens.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(severity == "anaphylactic" ? "ANAPHYLAXIS RISK" : "Allergen Alert")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(color)
                    Text(allergens.joined(separator: " · "))
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textPrimary)
                }
                Spacer()
            }
            .padding(12)
            .background(color.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.4), lineWidth: 1.5))
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = NurseryTheme.textPrimary

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(NurseryTheme.textSecondary)
                .frame(width: 130, alignment: .leading)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 13))
                .foregroundStyle(value.isEmpty ? NurseryTheme.textSecondary : valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Form Field

struct NurseryTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(NurseryTheme.textSecondary)
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .padding(10)
                    .background(NurseryTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    .font(.system(size: 14))
            } else {
                TextField(placeholder.isEmpty ? title : placeholder, text: $text)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(NurseryTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
        }
    }
}

// MARK: - Consumption Selector

struct ConsumptionSelector: View {
    @Binding var selection: String
    let options = ["all", "most", "half", "little", "none", "refused"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount Consumed")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(NurseryTheme.textSecondary)
            HStack(spacing: 6) {
                ForEach(options, id: \.self) { opt in
                    Button {
                        selection = opt
                    } label: {
                        Text(opt.capitalized)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(selection == opt ? .white : colorFor(opt))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(selection == opt ? colorFor(opt) : colorFor(opt).opacity(0.10))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    func colorFor(_ opt: String) -> Color {
        switch opt {
        case "all", "most": return .green
        case "half":        return .orange
        default:            return .red
        }
    }
}

// MARK: - Mood Selector

struct MoodSelector: View {
    @Binding var mood: String

    let moods: [(String, String)] = [
        ("happy", "😊"), ("content", "🙂"), ("unsettled", "😟"), ("poorly", "🤒")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood / Wellbeing")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(NurseryTheme.textSecondary)
            HStack(spacing: 12) {
                ForEach(moods, id: \.0) { (key, emoji) in
                    Button {
                        mood = key
                    } label: {
                        VStack(spacing: 4) {
                            Text(emoji).font(.system(size: 28))
                            Text(key.capitalized)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(mood == key ? NurseryTheme.primary : NurseryTheme.textSecondary)
                        }
                        .padding(8)
                        .background(mood == key ? NurseryTheme.primary.opacity(0.10) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(mood == key ? NurseryTheme.primary : Color.clear, lineWidth: 1.5))
                    }
                }
            }
        }
    }
}

// MARK: - GDPR Notice Banner

struct GDPRNoticeBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(NurseryTheme.primary)
            Text("All data is processed in accordance with UK GDPR and the Data Protection Act 2018.")
                .font(.system(size: 11))
                .foregroundStyle(NurseryTheme.textSecondary)
        }
        .padding(12)
        .background(NurseryTheme.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
