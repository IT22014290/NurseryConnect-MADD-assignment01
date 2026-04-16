import SwiftUI
import SwiftData

struct ParentDashboardView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @Query(sort: \DiaryEntry.timestamp, order: .reverse) private var allEntries: [DiaryEntry]
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var allIncidents: [IncidentReport]
    @Query private var transportRuns: [TransportRun]
    @State private var showConsentSheet = false

    var myChild: Child? { allChildren.first { $0.parentOneName == appState.currentUserName || $0.preferredName == appState.parentChildName } ?? allChildren.first }

    var todayEntries: [DiaryEntry] {
        guard let child = myChild else { return [] }
        return allEntries.filter { $0.childId == child.id && $0.timestamp.isToday }
    }

    var pendingIncidents: [IncidentReport] {
        guard let child = myChild else { return [] }
        return allIncidents.filter { $0.childId == child.id && !$0.parentAcknowledged && $0.parentNotified }
    }

    var activeRun: TransportRun? { transportRuns.first { $0.isActive } }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    parentHeader
                    VStack(spacing: 20) {
                        // Child Status Card
                        if let child = myChild {
                            childStatusCard(child)
                        }

                        // Incident Alert
                        if !pendingIncidents.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("Incident Report Awaiting Acknowledgement", systemImage: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.red)
                                ForEach(pendingIncidents) { incident in
                                    NavigationLink(destination: IncidentDetailView(incident: incident)) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(incident.categoryDisplay)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundStyle(.red)
                                                Text(incident.incidentDescription)
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(NurseryTheme.textSecondary)
                                                    .lineLimit(2)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundStyle(.red.opacity(0.5))
                                        }
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color.red.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.3), lineWidth: 1.5))
                            .padding(.horizontal, 16)
                        }

                        // Active Transport
                        if let run = activeRun, let child = myChild, child.isTransportChild {
                            transportWidget(run: run)
                        }

                        // Today's Diary Highlights
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Today's Highlights")
                            if todayEntries.isEmpty {
                                Text("No diary entries yet today.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(NurseryTheme.textSecondary)
                                    .padding(.horizontal, 20)
                            } else {
                                ForEach(todayEntries.prefix(5)) { entry in
                                    ParentDiaryEntryRow(entry: entry)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }

                        // Quick Links
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "Quick Links")
                            HStack(spacing: 10) {
                                quickLink(icon: "book.fill",           label: "Full Diary",   color: NurseryTheme.primary)
                                quickLink(icon: "location.fill",       label: "Van Tracker",  color: NurseryTheme.teal)
                                quickLink(icon: "message.fill",        label: "Message",      color: NurseryTheme.pink)
                                quickLink(icon: "lock.shield.fill",    label: "Consent",      color: NurseryTheme.purple) { showConsentSheet = true }
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showConsentSheet) {
            if let child = myChild {
                ConsentManagementView(child: child)
            }
        }
    }

    var parentHeader: some View {
        ZStack {
            NurseryTheme.gradient(NurseryTheme.pink).ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello, \(appState.currentUserName.components(separatedBy: " ").first ?? appState.currentUserName)")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Parent Dashboard · \(Date().dayMonthString)")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Button { withAnimation { appState.selectedRole = nil } } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18)).foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
        }
        .frame(height: 90)
    }

    func childStatusCard(_ child: Child) -> some View {
        HStack(spacing: 16) {
            ChildAvatarView(initials: child.initials, size: 60, color: NurseryTheme.pink, isCheckedIn: child.isCheckedIn)

            VStack(alignment: .leading, spacing: 6) {
                Text(child.fullName)
                    .font(.system(size: 18, weight: .bold))
                HStack(spacing: 8) {
                    StatusPill(label: child.isCheckedIn ? "In Nursery" : "Not Checked In", color: child.isCheckedIn ? .green : .gray)
                }
                if child.isCheckedIn, let t = child.checkInTime {
                    Text("Arrived at \(t.shortTimeString) · \(child.room)")
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                HStack(spacing: 4) {
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text("Keyworker: \(child.keyworkerName)")
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }
            Spacer()
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func transportWidget(run: TransportRun) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Van is on the way", systemImage: "bus.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(NurseryTheme.teal)
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Driver: \(run.driverName)")
                        .font(.system(size: 13, weight: .semibold))
                    Text("ETA: \(run.estimatedArrival)")
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                Spacer()
                StatusPill(label: "Live", color: NurseryTheme.teal)
            }
        }
        .cardStyle()
        .padding(.horizontal, 16)
    }

    func quickLink(icon: String, label: String, color: Color, action: (() -> Void)? = nil) -> some View {
        Button(action: action ?? {}) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Parent Diary Entry Row

struct ParentDiaryEntryRow: View {
    let entry: DiaryEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(entry.entryColor.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: entry.entryIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(entry.entryColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.entryTypeDisplay)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(entry.entryColor)
                Text(entry.entryNote)
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Text(entry.timestamp.shortTimeString)
                .font(.system(size: 10))
                .foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle(padding: 12)
    }
}

// MARK: - Consent Management View

struct ConsentManagementView: View {
    @Bindable var child: Child
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill").font(.system(size: 28)).foregroundStyle(NurseryTheme.primary)
                        VStack(alignment: .leading) {
                            Text("Consent Management")
                                .font(.system(size: 16, weight: .bold))
                            Text("You can update consent at any time. Changes take immediate effect.")
                                .font(.system(size: 11))
                                .foregroundStyle(NurseryTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Photography & Media") {
                    Toggle("Photography Consent",  isOn: $child.photographyConsent)
                    Toggle("Social Media Consent", isOn: $child.socialMediaConsent)
                    Toggle("Video Recording",      isOn: $child.videoConsent)
                }

                Section("Privacy & Safety") {
                    Toggle("Data Processing",      isOn: $child.dataProcessingConsent)
                    Toggle("GPS Tracking",         isOn: $child.gpsConsent)
                    Toggle("Medical Treatment",    isOn: $child.medicalTreatmentConsent)
                }

                Section {
                    GDPRNoticeBanner()
                }
            }
            .navigationTitle("Consent Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
