import SwiftUI
import SwiftData

// MARK: - Keyworker Dashboard
// Displays all children assigned to this keyworker (data minimisation — GDPR Art 5).
// Each card shows the child's status, allergy alerts, and quick-access diary actions.

struct DashboardView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \Child.firstName) private var children: [Child]

    @State private var showingAddEntryFor: Child? = nil
    @State private var searchText = ""
    @State private var filterPresent = false

    private var filtered: [Child] {
        let base = filterPresent ? children.filter { $0.isPresent } : children
        if searchText.isEmpty { return base }
        return base.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText) ||
            $0.room.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var presentCount: Int { children.filter { $0.isPresent }.count }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                NurseryTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header stats bar
                        statsBar

                        // Allergy alert banner (if any present child has allergy)
                        let allergyChildren = filtered.filter { $0.isPresent && $0.hasAllergies }
                        if !allergyChildren.isEmpty {
                            allergyAlertSection(children: allergyChildren)
                                .padding(.horizontal, NurseryTheme.spacingL)
                                .padding(.top, NurseryTheme.spacingM)
                        }

                        // Children list
                        LazyVStack(spacing: NurseryTheme.spacingM) {
                            ForEach(filtered) { child in
                                NavigationLink(destination: ChildDetailView(child: child)) {
                                    ChildCardView(child: child)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            if filtered.isEmpty {
                                EmptyStateView(
                                    icon: "person.2.circle",
                                    title: searchText.isEmpty ? "No Children Assigned" : "No Matches",
                                    subtitle: searchText.isEmpty
                                        ? "Children assigned to you will appear here."
                                        : "Try adjusting your search."
                                )
                                .padding(.top, NurseryTheme.spacingXXL)
                            }
                        }
                        .padding(.horizontal, NurseryTheme.spacingL)
                        .padding(.top, NurseryTheme.spacingM)
                        .padding(.bottom, NurseryTheme.spacingXXL)
                    }
                }
            }
            .navigationTitle("My Children")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search by name or room")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { filterPresent.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: filterPresent ? "person.fill.checkmark" : "person.2.fill")
                            Text(filterPresent ? "Present" : "All")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(filterPresent ? NurseryTheme.primary : NurseryTheme.primary.opacity(0.12))
                        .foregroundColor(filterPresent ? .white : NurseryTheme.primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .onAppear {
                SampleData.populate(context: context)
            }
        }
    }

    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem(value: "\(children.count)", label: "Assigned", icon: "person.2.fill", color: NurseryTheme.primary)
            Divider().frame(height: 36)
            statItem(value: "\(presentCount)", label: "Present", icon: "checkmark.circle.fill", color: NurseryTheme.statusGreen)
            Divider().frame(height: 36)
            statItem(
                value: "\(children.filter { $0.hasAllergies && $0.isPresent }.count)",
                label: "Allergy Alert",
                icon: "exclamationmark.triangle.fill",
                color: NurseryTheme.danger
            )
        }
        .padding(.vertical, NurseryTheme.spacingM)
        .background(NurseryTheme.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func statItem(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(NurseryTheme.textPrimary)
            }
            Text(label)
                .font(NurseryTheme.caption)
                .foregroundColor(NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Allergy Alert
    private func allergyAlertSection(children: [Child]) -> some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(NurseryTheme.danger)
                    Text("Mealtime Allergy Alerts")
                        .font(NurseryTheme.label)
                        .foregroundColor(NurseryTheme.danger)
                        .fontWeight(.semibold)
                }

                ForEach(children) { child in
                    HStack {
                        ChildAvatar(child: child, size: 28)
                        Text(child.displayName)
                            .font(NurseryTheme.bodyMedium)
                            .fontWeight(.medium)
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(child.allergies, id: \.self) { a in
                                    AllergyBadge(allergen: a)
                                }
                            }
                        }
                    }
                }
            }
            .padding(NurseryTheme.spacingM)
        }
    }
}
