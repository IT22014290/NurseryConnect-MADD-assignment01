import SwiftUI
import SwiftData

// MARK: - Incident Detail View
// Shows full incident details and workflow status.
// Keyworker can see status, update, and view compliance information.

struct IncidentDetailView: View {

    @Bindable var incident: IncidentReport
    @Environment(\.modelContext) private var context
    @State private var showAcknowledgeConfirmation = false
    @State private var showApproveConfirmation = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: NurseryTheme.spacingM) {

                // Status timeline
                workflowTimeline

                // Child & Category header
                if let child = incident.child {
                    childSummaryCard(child: child)
                }

                // Overdue warning
                if incident.isSameDayNotificationBreached {
                    OverdueBanner(message: "⚠️ Same-day parent notification overdue — EYFS legal obligation not yet met.")
                        .padding(.horizontal, NurseryTheme.spacingL)
                }

                // Incident Details
                detailCard(title: "Incident Details", icon: "doc.text.fill", iconColor: incident.category.themeColor) {
                    detailRow("Category", value: incident.category.rawValue)
                    divider
                    detailRow("Severity", value: incident.category.severityLabel)
                    divider
                    detailRow("Time", value: incident.formattedTimestamp)
                    divider
                    detailRow("Location", value: incident.location)
                    if incident.bodyMapLocation != .notApplicable {
                        divider
                        detailRow("Injury Location", value: incident.bodyMapLocation.rawValue)
                    }
                }

                // Description
                textCard(title: "Description", icon: "text.alignleft", text: incident.incidentDescription)

                // Action Taken
                textCard(title: "Immediate Action Taken", icon: "cross.case.fill", text: incident.actionTaken)

                // Witnesses
                if !incident.witnesses.isEmpty {
                    detailCard(title: "Witnesses", icon: "person.2.fill", iconColor: NurseryTheme.textSecondary) {
                        VStack(spacing: 0) {
                            ForEach(incident.witnesses, id: \.self) { w in
                                HStack(spacing: NurseryTheme.spacingS) {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(NurseryTheme.textSecondary)
                                    Text(w)
                                        .font(NurseryTheme.bodyMedium)
                                        .foregroundColor(NurseryTheme.textPrimary)
                                }
                                .padding(NurseryTheme.spacingM)
                                if w != incident.witnesses.last { divider }
                            }
                        }
                    }
                }

                // Compliance flags
                complianceCard

                // Action button (if applicable)
                if incident.status == .approved {
                    NurseryPrimaryButton(title: "Mark Parent Acknowledged", icon: "checkmark.seal.fill") {
                        showAcknowledgeConfirmation = true
                    }
                    .padding(.horizontal, NurseryTheme.spacingL)
                }

                if incident.status == .pendingReview {
                    Button {
                        showApproveConfirmation = true
                    } label: {
                        HStack(spacing: NurseryTheme.spacingS) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Approve & Notify Parent (Manager)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(NurseryTheme.spacingM)
                        .background(NurseryTheme.statusBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: NurseryTheme.cornerM))
                    }
                    .padding(.horizontal, NurseryTheme.spacingL)
                }

                Spacer().frame(height: NurseryTheme.spacingXXL)
            }
            .padding(.top, NurseryTheme.spacingM)
        }
        .background(NurseryTheme.background)
        .navigationTitle("Incident Report")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Mark as Acknowledged?", isPresented: $showAcknowledgeConfirmation, titleVisibility: .visible) {
            Button("Confirm Parent Acknowledged") {
                withAnimation {
                    incident.status = .acknowledged
                    incident.parentAcknowledgedAt = Date()
                    try? context.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Confirm that the parent/guardian has acknowledged this incident report.")
        }
        .confirmationDialog("Approve Incident Report?", isPresented: $showApproveConfirmation, titleVisibility: .visible) {
            Button("Approve & Notify Parent", role: .destructive) {
                withAnimation {
                    incident.status = .approved
                    incident.managerSignedAt = Date()
                    incident.parentNotifiedAt = Date()
                    try? context.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Approving this report will notify the parent/guardian. This action is recorded for audit purposes.")
        }
    }

    // MARK: - Workflow Timeline

    private var workflowTimeline: some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: NurseryTheme.spacingM) {
                Text("Report Status")
                    .font(NurseryTheme.headlineSmall)
                    .foregroundColor(NurseryTheme.textPrimary)
                    .padding(.horizontal, NurseryTheme.spacingM)
                    .padding(.top, NurseryTheme.spacingM)

                Divider()

                VStack(spacing: 0) {
                    timelineStep(
                        title: "Incident Occurred",
                        subtitle: incident.formattedTimestamp,
                        isComplete: true,
                        icon: "exclamationmark.triangle.fill",
                        color: incident.category.themeColor
                    )
                    timelineStep(
                        title: "Submitted for Review",
                        subtitle: incident.submittedAt.map { $0.formatted(.dateTime.day().month().hour().minute()) } ?? "Not yet submitted",
                        isComplete: incident.submittedAt != nil,
                        icon: "paperplane.fill",
                        color: NurseryTheme.statusOrange
                    )
                    timelineStep(
                        title: "Manager Countersigned",
                        subtitle: incident.managerSignedAt.map { $0.formatted(.dateTime.day().month().hour().minute()) } ?? "Awaiting manager",
                        isComplete: incident.managerSignedAt != nil,
                        icon: "signature",
                        color: NurseryTheme.statusBlue
                    )
                    timelineStep(
                        title: "Parent Notified",
                        subtitle: incident.parentNotifiedAt.map { $0.formatted(.dateTime.day().month().hour().minute()) } ?? "Not yet notified",
                        isComplete: incident.parentNotifiedAt != nil,
                        icon: "bell.fill",
                        color: NurseryTheme.primary
                    )
                    timelineStep(
                        title: "Parent Acknowledged",
                        subtitle: incident.parentAcknowledgedAt.map { $0.formatted(.dateTime.day().month().hour().minute()) } ?? "Awaiting acknowledgement",
                        isComplete: incident.parentAcknowledgedAt != nil,
                        icon: "checkmark.seal.fill",
                        color: NurseryTheme.statusGreen,
                        isLast: true
                    )
                }
                .padding(.bottom, NurseryTheme.spacingM)
            }
        }
        .padding(.horizontal, NurseryTheme.spacingL)
    }

    private func timelineStep(title: String, subtitle: String, isComplete: Bool, icon: String, color: Color, isLast: Bool = false) -> some View {
        HStack(alignment: .top, spacing: NurseryTheme.spacingM) {
            // Icon + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isComplete ? color.opacity(0.15) : NurseryTheme.background)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(isComplete ? color : NurseryTheme.cardBorder, lineWidth: 1.5))
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundColor(isComplete ? color : NurseryTheme.textMuted)
                }
                if !isLast {
                    Rectangle()
                        .fill(isComplete ? color.opacity(0.3) : NurseryTheme.cardBorder)
                        .frame(width: 2, height: 28)
                }
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NurseryTheme.label)
                    .fontWeight(isComplete ? .semibold : .regular)
                    .foregroundColor(isComplete ? NurseryTheme.textPrimary : NurseryTheme.textSecondary)
                Text(subtitle)
                    .font(NurseryTheme.caption)
                    .foregroundColor(isComplete ? color : NurseryTheme.textMuted)
            }
            .padding(.bottom, isLast ? 0 : NurseryTheme.spacingL)
        }
        .padding(.horizontal, NurseryTheme.spacingM)
    }

    // MARK: - Child Summary

    private func childSummaryCard(child: Child) -> some View {
        NurseryCard {
            HStack(spacing: NurseryTheme.spacingM) {
                ChildAvatar(child: child, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.displayName)
                        .font(NurseryTheme.headlineSmall)
                    Text("\(child.ageString) · \(child.room)")
                        .font(NurseryTheme.caption)
                        .foregroundColor(NurseryTheme.textSecondary)
                }
                Spacer()
                if child.hasAllergies {
                    AllergyBadge(allergen: "⚠ Allergens")
                }
            }
            .padding(NurseryTheme.spacingM)
        }
        .padding(.horizontal, NurseryTheme.spacingL)
    }

    // MARK: - Compliance Card

    private var complianceCard: some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: NurseryTheme.spacingS) {
                Label("Regulatory Compliance", systemImage: "shield.lefthalf.filled")
                    .font(NurseryTheme.label)
                    .foregroundColor(NurseryTheme.statusBlue)
                    .padding(.horizontal, NurseryTheme.spacingM)
                    .padding(.top, NurseryTheme.spacingM)

                Divider()

                VStack(spacing: 0) {
                    complianceRow("RIDDOR Reportable", value: incident.isRIDDORReportable ? "Yes" : "No",
                                  color: incident.isRIDDORReportable ? NurseryTheme.danger : NurseryTheme.statusGreen)
                    divider
                    complianceRow("Ofsted Notification Required", value: incident.ofstedNotificationRequired ? "Yes — Manager to file" : "No",
                                  color: incident.ofstedNotificationRequired ? NurseryTheme.danger : NurseryTheme.statusGreen)
                    divider
                    complianceRow("Same-Day Notification Status",
                                  value: incident.isSameDayNotificationBreached ? "⚠ Overdue" : "On Track",
                                  color: incident.isSameDayNotificationBreached ? NurseryTheme.danger : NurseryTheme.statusGreen)
                }
                .padding(.bottom, NurseryTheme.spacingM)
            }
        }
        .padding(.horizontal, NurseryTheme.spacingL)
    }

    private func complianceRow(_ label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(NurseryTheme.bodyMedium)
                .foregroundColor(NurseryTheme.textSecondary)
            Spacer()
            Text(value)
                .font(NurseryTheme.label)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal, NurseryTheme.spacingM)
        .padding(.vertical, NurseryTheme.spacingM)
    }

    // MARK: - Generic Card helpers

    private var divider: some View { Divider().padding(.horizontal, NurseryTheme.spacingM) }

    private func detailCard<Content: View>(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) -> some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: NurseryTheme.spacingS) {
                    Image(systemName: icon).font(.system(size: 15)).foregroundColor(iconColor)
                    Text(title).font(NurseryTheme.headlineSmall).foregroundColor(NurseryTheme.textPrimary)
                }
                .padding(NurseryTheme.spacingM)
                Divider()
                content()
            }
        }
        .padding(.horizontal, NurseryTheme.spacingL)
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(NurseryTheme.bodyMedium).foregroundColor(NurseryTheme.textSecondary)
                .frame(width: 140, alignment: .leading)
            Spacer()
            Text(value.isEmpty ? "—" : value).font(NurseryTheme.bodyMedium).foregroundColor(NurseryTheme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, NurseryTheme.spacingM)
        .padding(.vertical, NurseryTheme.spacingM)
    }

    private func textCard(title: String, icon: String, text: String) -> some View {
        NurseryCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: NurseryTheme.spacingS) {
                    Image(systemName: icon).font(.system(size: 15)).foregroundColor(NurseryTheme.primary)
                    Text(title).font(NurseryTheme.headlineSmall).foregroundColor(NurseryTheme.textPrimary)
                }
                .padding(NurseryTheme.spacingM)
                Divider()
                Text(text.isEmpty ? "—" : text)
                    .font(NurseryTheme.bodyMedium)
                    .foregroundColor(NurseryTheme.textPrimary)
                    .padding(NurseryTheme.spacingM)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, NurseryTheme.spacingL)
    }
}
