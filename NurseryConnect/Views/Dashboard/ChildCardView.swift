import SwiftUI

// MARK: - Child Card
// Summary card shown on the dashboard for each assigned child.

struct ChildCardView: View {

    let child: Child

    private var todayEntries: [DiaryEntry] { child.todayEntries }

    private var lastEntry: DiaryEntry? {
        todayEntries.last
    }

    private var openIncidentCount: Int { child.openIncidents.count }

    var body: some View {
        NurseryCard {
            VStack(spacing: 0) {
                // Top row: avatar, name, status
                HStack(alignment: .top, spacing: NurseryTheme.spacingM) {
                    ChildAvatar(child: child, size: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(child.displayName)
                                .font(NurseryTheme.headlineSmall)
                                .foregroundColor(NurseryTheme.textPrimary)
                            if child.fullName != child.displayName {
                                Text("(\(child.fullName))")
                                    .font(NurseryTheme.caption)
                                    .foregroundColor(NurseryTheme.textSecondary)
                            }
                        }

                        HStack(spacing: 6) {
                            Text(child.ageString)
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textSecondary)
                            Text("•")
                                .foregroundColor(NurseryTheme.textMuted)
                            Text(child.room)
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textSecondary)
                        }

                        // Badges row
                        HStack(spacing: 6) {
                            StatusBadge(
                                label: child.isPresent ? "Present" : "Absent",
                                color: child.isPresent ? NurseryTheme.statusGreen : NurseryTheme.statusGray,
                                icon: child.isPresent ? "checkmark.circle" : "minus.circle"
                            )

                            if !child.photoConsent {
                                StatusBadge(label: "No Photo", color: NurseryTheme.danger, icon: "camera.slash.fill")
                            }

                            if openIncidentCount > 0 {
                                StatusBadge(
                                    label: "\(openIncidentCount) Incident\(openIncidentCount > 1 ? "s" : "")",
                                    color: NurseryTheme.danger,
                                    icon: "exclamationmark.triangle.fill"
                                )
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(NurseryTheme.textMuted)
                }
                .padding(NurseryTheme.spacingM)

                // Allergy strip (if any)
                if child.hasAllergies {
                    Divider().padding(.horizontal, NurseryTheme.spacingM)
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(NurseryTheme.danger)
                        Text("Allergens:")
                            .font(NurseryTheme.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(NurseryTheme.danger)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(child.allergies, id: \.self) { a in
                                    Text(a)
                                        .font(.system(size: 10, weight: .medium))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(NurseryTheme.danger.opacity(0.1))
                                        .foregroundColor(NurseryTheme.danger)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, NurseryTheme.spacingM)
                    .padding(.vertical, NurseryTheme.spacingS)
                }

                // Today's diary summary
                if !todayEntries.isEmpty {
                    Divider().padding(.horizontal, NurseryTheme.spacingM)
                    HStack(spacing: NurseryTheme.spacingS) {
                        Image(systemName: "book.pages")
                            .font(.system(size: 13))
                            .foregroundColor(NurseryTheme.primary)
                        Text("Today: \(todayEntries.count) entr\(todayEntries.count == 1 ? "y" : "ies")")
                            .font(NurseryTheme.caption)
                            .foregroundColor(NurseryTheme.textSecondary)
                        Spacer()
                        if let last = lastEntry {
                            EntryTypeIcon(entryType: last.entryType, size: 22)
                            Text(last.summarySentence)
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, NurseryTheme.spacingM)
                    .padding(.vertical, NurseryTheme.spacingS)
                }
            }
        }
    }
}
