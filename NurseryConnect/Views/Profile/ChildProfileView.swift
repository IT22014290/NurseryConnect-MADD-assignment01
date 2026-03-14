import SwiftUI

// MARK: - Child Profile View
// Read-only profile view for the keyworker.
// Displays all relevant medical, dietary, and EYFS information.
// UK GDPR Art 9: medical/dietary data shown only to the assigned keyworker.

struct ChildProfileView: View {

    let child: Child

    var body: some View {
        ScrollView {
            LazyVStack(spacing: NurseryTheme.spacingM) {

                // GDPR Compliance Notice
                if !child.photoConsent {
                    OverdueBanner(message: "⚠️  NO PHOTOGRAPHY CONSENT — Do not photograph this child.")
                        .padding(.horizontal, NurseryTheme.spacingL)
                        .padding(.top, NurseryTheme.spacingM)
                }

                // Personal Info card
                profileSection(title: "Personal Information", icon: "person.circle.fill", iconColor: NurseryTheme.primary) {
                    VStack(spacing: 0) {
                        infoRow("Full Name", value: child.fullName)
                        Divider()
                        infoRow("Preferred Name", value: child.preferredName)
                        Divider()
                        infoRow("Date of Birth", value: child.dateOfBirth.formatted(date: .long, time: .omitted))
                        Divider()
                        infoRow("Age", value: child.ageString)
                        Divider()
                        infoRow("Room", value: child.room)
                        Divider()
                        infoRow("Keyworker", value: child.keyworkerName)
                    }
                }

                // Medical & Health card
                profileSection(title: "Medical & Health", icon: "cross.case.fill", iconColor: NurseryTheme.statusBlue) {
                    VStack(spacing: 0) {
                        infoRow("Medical Conditions", value: child.medicalConditions, isMultiline: true)
                        Divider()
                        infoRow("Photo Consent", value: child.photoConsent ? "✓ Granted" : "✗ Withheld")
                    }
                }

                // Dietary & Allergens card
                profileSection(title: "Dietary & Allergens", icon: "fork.knife.circle.fill", iconColor: NurseryTheme.entryOrange) {
                    VStack(spacing: NurseryTheme.spacingM) {
                        // Allergens
                        if child.hasAllergies {
                            VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(NurseryTheme.danger)
                                    Text("ALLERGENS — CHECK ALL DISHES")
                                        .font(NurseryTheme.label)
                                        .fontWeight(.bold)
                                        .foregroundColor(NurseryTheme.danger)
                                }
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                                    ForEach(child.allergies, id: \.self) { a in
                                        AllergyBadge(allergen: a)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding(NurseryTheme.spacingM)
                            .background(NurseryTheme.danger.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerS))

                            Divider()
                        }

                        VStack(spacing: 0) {
                            infoRow("Dietary Requirements", value: child.dietaryRequirements, isMultiline: true)
                        }
                    }
                    .padding(NurseryTheme.spacingM)
                }

                // EYFS Notice
                profileSection(title: "EYFS Information", icon: "graduationcap.fill", iconColor: NurseryTheme.entryPurple) {
                    VStack(spacing: 0) {
                        infoRow("Keyworker", value: child.keyworkerName)
                        Divider()
                        infoRow("Room", value: child.room)
                        Divider()
                        infoRow("Today's Diary Entries", value: "\(child.todayEntries.count)")
                    }
                }

                // Regulatory footer
                regulatoryNote

            }
            .padding(.horizontal, NurseryTheme.spacingL)
            .padding(.bottom, 100)
            .padding(.top, NurseryTheme.spacingM)
        }
        .background(NurseryTheme.background)
    }

    // MARK: - Helpers

    private func profileSection<Content: View>(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) -> some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: NurseryTheme.spacingS) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(NurseryTheme.headlineSmall)
                        .foregroundColor(NurseryTheme.textPrimary)
                }
                .padding(NurseryTheme.spacingM)

                Divider()
                content()
            }
        }
    }

    private func infoRow(_ label: String, value: String, isMultiline: Bool = false) -> some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: NurseryTheme.spacingS) {
            Text(label)
                .font(NurseryTheme.bodyMedium)
                .foregroundColor(NurseryTheme.textSecondary)
                .frame(width: 140, alignment: .leading)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(NurseryTheme.bodyMedium)
                .foregroundColor(NurseryTheme.textPrimary)
                .multilineTextAlignment(isMultiline ? .leading : .trailing)
                .frame(maxWidth: .infinity, alignment: isMultiline ? .leading : .trailing)
        }
        .padding(.horizontal, NurseryTheme.spacingM)
        .padding(.vertical, NurseryTheme.spacingM)
    }

    private var regulatoryNote: some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                Label("Data Protection Notice", systemImage: "lock.shield.fill")
                    .font(NurseryTheme.label)
                    .foregroundColor(NurseryTheme.textSecondary)

                Text("This child's personal information is processed under UK GDPR Article 6(1)(b) and Article 9(2)(a). Access is restricted to authorised keyworkers only, in compliance with the EYFS data minimisation principle and Children Act 1989.")
                    .font(NurseryTheme.caption)
                    .foregroundColor(NurseryTheme.textMuted)
            }
            .padding(NurseryTheme.spacingM)
        }
    }
}
