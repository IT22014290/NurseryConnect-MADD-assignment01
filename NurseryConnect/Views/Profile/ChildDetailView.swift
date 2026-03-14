import SwiftUI
import SwiftData

// MARK: - Child Detail View
// Provides tabs for: Today's Diary, Child Profile, Incidents.
// Acts as the hub screen for all keyworker interactions with a child.

struct ChildDetailView: View {

    @Bindable var child: Child
    @Environment(\.modelContext) private var context

    @State private var selectedTab = 0
    @State private var showingAddEntry = false
    @State private var showingNewIncident = false

    var body: some View {
        ZStack(alignment: .bottom) {
            NurseryTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Hero header
                childHeader

                // Tab selector
                tabSelector

                // Tab content
                TabView(selection: $selectedTab) {
                    DailyDiaryView(child: child)
                        .tag(0)
                    ChildProfileView(child: child)
                        .tag(1)
                    IncidentListView(child: child)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }

            // FAB for current tab
            fabButton
                .padding(.bottom, NurseryTheme.spacingL)
                .padding(.trailing, NurseryTheme.spacingL)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddEntry) {
            AddDiaryEntryView(child: child)
        }
        .sheet(isPresented: $showingNewIncident) {
            IncidentFormView(child: child)
        }
    }

    // MARK: - Hero Header

    private var childHeader: some View {
        VStack(spacing: NurseryTheme.spacingS) {
            ChildAvatar(child: child, size: 72)

            VStack(spacing: 4) {
                Text(child.displayName)
                    .font(NurseryTheme.headlineLarge)
                    .foregroundColor(NurseryTheme.textPrimary)
                if child.displayName != child.firstName {
                    Text(child.fullName)
                        .font(NurseryTheme.bodyMedium)
                        .foregroundColor(NurseryTheme.textSecondary)
                }
            }

            HStack(spacing: NurseryTheme.spacingM) {
                Label(child.ageString, systemImage: "birthday.cake")
                Label(child.room, systemImage: "door.left.hand.open")
            }
            .font(NurseryTheme.bodyMedium)
            .foregroundColor(NurseryTheme.textSecondary)

            // Status / consent badges
            HStack(spacing: NurseryTheme.spacingS) {
                StatusBadge(
                    label: child.isPresent ? "Present" : "Absent",
                    color: child.isPresent ? NurseryTheme.statusGreen : NurseryTheme.statusGray,
                    icon: child.isPresent ? "checkmark.circle" : "minus.circle"
                )
                if !child.photoConsent {
                    StatusBadge(label: "No Photo Consent", color: NurseryTheme.danger, icon: "camera.slash.fill")
                }
                if child.hasAllergies {
                    StatusBadge(label: "\(child.allergies.count) Allergen\(child.allergies.count > 1 ? "s" : "")",
                                color: NurseryTheme.danger,
                                icon: "exclamationmark.triangle.fill")
                }
            }
        }
        .padding(NurseryTheme.spacingL)
        .background(NurseryTheme.cardSurface)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Diary", icon: "book.pages", index: 0,
                      badge: child.todayEntries.count)
            tabButton(title: "Profile", icon: "person.circle", index: 1, badge: nil)
            tabButton(title: "Incidents", icon: "exclamationmark.triangle", index: 2,
                      badge: child.openIncidents.isEmpty ? nil : child.openIncidents.count)
        }
        .background(NurseryTheme.cardSurface)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    private func tabButton(title: String, icon: String, index: Int, badge: Int?) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                    if let badge, badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 9, weight: .bold))
                            .padding(3)
                            .background(NurseryTheme.danger)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .offset(x: 8, y: -4)
                    }
                }
                Text(title)
                    .font(NurseryTheme.caption)
                    .fontWeight(selectedTab == index ? .semibold : .regular)
            }
            .foregroundColor(selectedTab == index ? NurseryTheme.primary : NurseryTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, NurseryTheme.spacingM)
            .background(
                selectedTab == index
                    ? NurseryTheme.primary.opacity(0.08)
                    : Color.clear
            )
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(selectedTab == index ? NurseryTheme.primary : .clear),
                alignment: .bottom
            )
        }
    }

    // MARK: - FAB

    @ViewBuilder
    private var fabButton: some View {
        HStack {
            Spacer()
            if selectedTab == 0 {
                Button {
                    showingAddEntry = true
                } label: {
                    HStack(spacing: NurseryTheme.spacingS) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                        Text("Add Entry")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, NurseryTheme.spacingL)
                    .padding(.vertical, NurseryTheme.spacingM)
                    .background(NurseryTheme.primary)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: NurseryTheme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            } else if selectedTab == 2 {
                Button {
                    showingNewIncident = true
                } label: {
                    HStack(spacing: NurseryTheme.spacingS) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                        Text("Report Incident")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, NurseryTheme.spacingL)
                    .padding(.vertical, NurseryTheme.spacingM)
                    .background(NurseryTheme.danger)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: NurseryTheme.danger.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}
