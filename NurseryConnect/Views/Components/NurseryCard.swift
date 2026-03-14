import SwiftUI

// MARK: - Reusable Card Component

struct NurseryCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(NurseryTheme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerM))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(NurseryTheme.headlineSmall)
                .foregroundColor(NurseryTheme.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(NurseryTheme.bodyMedium)
                    .foregroundColor(NurseryTheme.textSecondary)
            }
        }
    }
}

// MARK: - Allergy Badge

struct AllergyBadge: View {
    let allergen: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            Text(allergen)
                .font(NurseryTheme.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(NurseryTheme.danger.opacity(0.12))
        .foregroundColor(NurseryTheme.danger)
        .clipShape(Capsule())
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let label: String
    let color: Color
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(label)
                .font(NurseryTheme.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

// MARK: - Entry Type Icon View

struct EntryTypeIcon: View {
    let entryType: DiaryEntryType
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(entryType.themeColor.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: entryType.systemImage)
                .font(.system(size: size * 0.42))
                .foregroundColor(entryType.themeColor)
        }
    }
}

// MARK: - Incident Category Icon

struct IncidentCategoryIcon: View {
    let category: IncidentCategory
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(category.themeColor.opacity(0.15))
                .frame(width: size, height: size)
            Image(systemName: category.systemImage)
                .font(.system(size: size * 0.45))
                .foregroundColor(category.themeColor)
        }
    }
}

// MARK: - Child Avatar

struct ChildAvatar: View {
    let child: Child
    var size: CGFloat = 52

    private var initials: String {
        let f = child.firstName.first.map(String.init) ?? ""
        let l = child.lastName.first.map(String.init) ?? ""
        return "\(f)\(l)"
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: child.avatarColorHex).opacity(0.2))
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(size: size * 0.35, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: child.avatarColorHex))
        }
        .overlay(
            Circle()
                .stroke(Color(hex: child.avatarColorHex).opacity(0.35), lineWidth: 1.5)
        )
    }
}

// MARK: - Overdue Warning Banner

struct OverdueBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: NurseryTheme.spacingS) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .font(NurseryTheme.label)
        }
        .foregroundColor(.white)
        .padding(NurseryTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NurseryTheme.danger)
        .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerS))
    }
}

// MARK: - Primary Button

struct NurseryPrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: NurseryTheme.spacingS) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(NurseryTheme.spacingM)
            .background(NurseryTheme.primary)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerM))
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: NurseryTheme.spacingL) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundColor(NurseryTheme.primary.opacity(0.5))
            VStack(spacing: NurseryTheme.spacingS) {
                Text(title)
                    .font(NurseryTheme.headlineSmall)
                    .foregroundColor(NurseryTheme.textPrimary)
                Text(subtitle)
                    .font(NurseryTheme.bodyMedium)
                    .foregroundColor(NurseryTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(NurseryTheme.spacingXXL)
        .frame(maxWidth: .infinity)
    }
}
