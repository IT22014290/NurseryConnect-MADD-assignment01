import SwiftUI
import SwiftData

// MARK: - Incident List View
// Used both as a standalone tab (all incidents) and embedded in ChildDetailView.
// FR24–FR29: RIDDOR-aligned incident management with workflow status tracking.

struct IncidentListView: View {

    // Optional child filter — when nil, shows all incidents across all children
    var child: Child? = nil

    @Environment(\.modelContext) private var context
    @Query(sort: \IncidentReport.timestamp, order: .reverse) private var allIncidents: [IncidentReport]

    @State private var filterStatus: IncidentStatus? = nil
    @State private var showingNewIncident = false
    @State private var selectedChildForNewIncident: Child? = nil

    private var incidents: [IncidentReport] {
        let base = child != nil
            ? allIncidents.filter { $0.child?.id == child!.id }
            : allIncidents

        if let filter = filterStatus {
            return base.filter { $0.status == filter }
        }
        return base
    }

    private var overdueCount: Int {
        incidents.filter { $0.isSameDayNotificationBreached }.count
    }

    var body: some View {
        Group {
            if child != nil {
                // Embedded in ChildDetailView — no navigation needed
                embeddedContent
            } else {
                // Standalone tab
                NavigationStack {
                    standaloneContent
                        .navigationTitle("Incident Reports")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    showingNewIncident = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(NurseryTheme.primary)
                                }
                            }
                        }
                        .sheet(isPresented: $showingNewIncident) {
                            IncidentFormView(child: nil)
                        }
                }
            }
        }
    }

    // MARK: - Embedded (inside ChildDetailView)

    private var embeddedContent: some View {
        ScrollView {
            LazyVStack(spacing: NurseryTheme.spacingM) {
                if overdueCount > 0 {
                    OverdueBanner(message: "⚠️ \(overdueCount) incident\(overdueCount > 1 ? "s" : "") awaiting parent notification (EYFS obligation)")
                        .padding(.horizontal, NurseryTheme.spacingL)
                        .padding(.top, NurseryTheme.spacingM)
                }

                ForEach(incidents) { incident in
                    NavigationLink(destination: IncidentDetailView(incident: incident)) {
                        IncidentRowCard(incident: incident)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if incidents.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.shield",
                        title: "No Incidents",
                        subtitle: "No incident reports recorded for \(child?.displayName ?? "this child")."
                    )
                }
            }
            .padding(.horizontal, NurseryTheme.spacingL)
            .padding(.bottom, 100)
        }
        .background(NurseryTheme.background)
    }

    // MARK: - Standalone

    private var standaloneContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Summary stats
                incidentStats

                // Overdue banner
                if overdueCount > 0 {
                    OverdueBanner(message: "⚠️ \(overdueCount) incident\(overdueCount > 1 ? "s" : "") require same-day parent notification (EYFS)")
                        .padding(.horizontal, NurseryTheme.spacingL)
                        .padding(.vertical, NurseryTheme.spacingM)
                }

                // Status filter chips
                filterBar
                    .padding(.horizontal, NurseryTheme.spacingL)
                    .padding(.bottom, NurseryTheme.spacingM)

                // Incident list
                LazyVStack(spacing: NurseryTheme.spacingM) {
                    ForEach(incidents) { incident in
                        NavigationLink(destination: IncidentDetailView(incident: incident)) {
                            IncidentRowCard(incident: incident)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    if incidents.isEmpty {
                        EmptyStateView(
                            icon: filterStatus == nil ? "checkmark.shield" : "line.3.horizontal.decrease.circle",
                            title: filterStatus == nil ? "No Incidents" : "No \(filterStatus!.rawValue) Incidents",
                            subtitle: filterStatus == nil
                                ? "All incidents across your assigned children will appear here."
                                : "Try changing the status filter."
                        )
                        .padding(.top, NurseryTheme.spacingXL)
                    }
                }
                .padding(.horizontal, NurseryTheme.spacingL)
                .padding(.bottom, NurseryTheme.spacingXXL)
            }
        }
        .background(NurseryTheme.background)
    }

    // MARK: - Stats

    private var incidentStats: some View {
        HStack(spacing: 0) {
            statItem("\(allIncidents.count)", "Total", NurseryTheme.primary)
            Divider().frame(height: 36)
            statItem("\(allIncidents.filter { $0.status == .pendingReview }.count)", "Pending", NurseryTheme.statusOrange)
            Divider().frame(height: 36)
            statItem("\(allIncidents.filter { $0.status == .acknowledged }.count)", "Closed", NurseryTheme.statusGreen)
        }
        .padding(.vertical, NurseryTheme.spacingM)
        .background(NurseryTheme.cardSurface)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func statItem(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(NurseryTheme.caption)
                .foregroundColor(NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NurseryTheme.spacingS) {
                filterChip(label: "All", isActive: filterStatus == nil) {
                    withAnimation { filterStatus = nil }
                }
                ForEach(IncidentStatus.allCases, id: \.self) { status in
                    filterChip(label: status.rawValue.components(separatedBy: " —").first ?? status.rawValue,
                                isActive: filterStatus == status) {
                        withAnimation { filterStatus = filterStatus == status ? nil : status }
                    }
                }
            }
        }
    }

    private func filterChip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(NurseryTheme.label)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isActive ? NurseryTheme.primary : NurseryTheme.cardSurface)
                .foregroundColor(isActive ? .white : NurseryTheme.textSecondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isActive ? Color.clear : NurseryTheme.cardBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - Incident Row Card

struct IncidentRowCard: View {

    let incident: IncidentReport

    var body: some View {
        NurseryCard {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: NurseryTheme.spacingM) {
                    IncidentCategoryIcon(category: incident.category, size: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(incident.category.rawValue)
                                .font(NurseryTheme.label)
                                .fontWeight(.semibold)
                                .foregroundColor(incident.category.themeColor)
                            Spacer()
                            Text(incident.timeElapsed)
                                .font(NurseryTheme.caption)
                                .foregroundColor(NurseryTheme.textMuted)
                        }

                        if let child = incident.child {
                            HStack(spacing: 4) {
                                ChildAvatar(child: child, size: 18)
                                Text(child.displayName)
                                    .font(NurseryTheme.caption)
                                    .foregroundColor(NurseryTheme.textSecondary)
                            }
                        }

                        Text(incident.incidentDescription)
                            .font(NurseryTheme.bodyMedium)
                            .foregroundColor(NurseryTheme.textPrimary)
                            .lineLimit(2)
                    }
                }
                .padding(NurseryTheme.spacingM)

                Divider().padding(.horizontal, NurseryTheme.spacingM)

                HStack {
                    StatusBadge(
                        label: incident.status.rawValue.components(separatedBy: " —").first ?? incident.status.rawValue,
                        color: incident.status.themeColor,
                        icon: incident.status.systemImage
                    )

                    if incident.isSameDayNotificationBreached {
                        StatusBadge(label: "Overdue Notification", color: NurseryTheme.danger, icon: "clock.badge.exclamationmark")
                    }

                    Spacer()

                    if !incident.location.isEmpty {
                        Label(incident.location, systemImage: "mappin.circle")
                            .font(NurseryTheme.caption)
                            .foregroundColor(NurseryTheme.textSecondary)
                            .lineLimit(1)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundColor(NurseryTheme.textMuted)
                }
                .padding(.horizontal, NurseryTheme.spacingM)
                .padding(.vertical, NurseryTheme.spacingS)
            }
        }
    }
}
