import SwiftUI
import SwiftData
import MapKit

struct DriverDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var transportRuns: [TransportRun]
    @Query(sort: \Child.fullName) private var allChildren: [Child]

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var showStartConfirm = false
    @State private var showEndConfirm   = false

    var activeRun: TransportRun? { transportRuns.first { $0.isActive } }
    var todayRun:  TransportRun? { transportRuns.first }
    var transportChildren: [Child] { allChildren.filter { $0.isTransportChild } }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    driverHeader

                    VStack(spacing: 16) {
                        // Run status card
                        runStatusCard

                        // Map preview
                        mapPreview

                        // Quick boarding (if active run)
                        if let run = activeRun {
                            boardingSection(run: run)
                        }

                        // Safety checklist
                        safetyChecklistCard

                        Spacer(minLength: 32)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                }
            }
        }
        .confirmationDialog("Start Transport Run", isPresented: $showStartConfirm, titleVisibility: .visible) {
            Button("Start Run") { startRun() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will mark the run as active and notify parents.")
        }
        .confirmationDialog("End Transport Run", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("End Run", role: .destructive) { endRun() }
            Button("Cancel", role: .cancel) {}
        }
    }

    var driverHeader: some View {
        ZStack {
            NurseryTheme.gradient(NurseryTheme.orange).ignoresSafeArea(edges: .top)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Driver Portal")
                        .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text("Hello, \(appState.currentUserName.components(separatedBy: " ").first ?? "")")
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

    var runStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today's Run", systemImage: "bus.fill")
                    .font(.system(size: 15, weight: .bold)).foregroundStyle(NurseryTheme.orange)
                Spacer()
                if let run = activeRun {
                    StatusPill(label: "Active", color: .green)
                } else {
                    StatusPill(label: todayRun != nil ? "Ready" : "No Run", color: .gray)
                }
            }

            if let run = todayRun ?? activeRun {
                Divider()
                InfoRow(label: "Driver", value: run.driverName)
                InfoRow(label: "Children", value: "\(run.manifestList.count) on manifest")
                InfoRow(label: "Boarded", value: "\(run.boardedList.count)/\(run.manifestList.count)")
                InfoRow(label: "ETA", value: run.estimatedArrival)
            } else {
                Text("No transport run scheduled for today.")
                    .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
            }

            if activeRun == nil && todayRun != nil {
                Button { showStartConfirm = true } label: {
                    Label("Start Run", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryButtonStyle(color: NurseryTheme.orange))
            } else if activeRun != nil {
                Button { showEndConfirm = true } label: {
                    Label("End Run", systemImage: "stop.fill")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .cardStyle()
    }

    var mapPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Live Position", systemImage: "location.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.orange)
            Map(position: $cameraPosition) {
                Annotation("Little Stars Nursery",
                            coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)) {
                    ZStack {
                        Circle().fill(NurseryTheme.primary).frame(width: 32, height: 32).shadow(radius: 3)
                        Image(systemName: "star.fill").font(.system(size: 14)).foregroundStyle(.white)
                    }
                }
            }
            .mapStyle(.standard)
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(true)

            Text("GPS broadcasts every 10 seconds when run is active.")
                .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle()
    }

    func boardingSection(run: TransportRun) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Mark Children as Boarded", systemImage: "person.badge.plus")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.orange)
            Divider()
            ForEach(transportChildren.filter { run.manifestList.contains($0.fullName) }) { child in
                let boarded = run.boardedList.contains(child.fullName)
                HStack(spacing: 12) {
                    ChildAvatarView(initials: child.initials, size: 38, color: boarded ? .green : NurseryTheme.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.fullName).font(.system(size: 13, weight: .semibold))
                        Text(child.school.isEmpty ? "Pickup" : child.school)
                            .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    }
                    Spacer()
                    if boarded {
                        Label("Boarded", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.green)
                    } else {
                        Button {
                            boardChild(name: child.fullName)
                        } label: {
                            Text("Board")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(NurseryTheme.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    var safetyChecklistCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Pre-Run Safety Checklist", systemImage: "list.bullet.clipboard.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
            Divider()
            VStack(spacing: 6) {
                checklistItem("Vehicle daily walk-around completed")
                checklistItem("Seatbelts / child restraints checked")
                checklistItem("Emergency contacts accessible")
                checklistItem("First aid kit on board")
                checklistItem("Allergen register reviewed")
                checklistItem("Route confirmed with nursery")
            }
        }
        .cardStyle()
    }

    func checklistItem(_ label: String) -> some View {
        Label(label, systemImage: "checkmark.circle.fill")
            .font(.system(size: 12))
            .foregroundStyle(NurseryTheme.textSecondary)
    }

    private func startRun() {
        guard let run = todayRun else { return }
        run.isActive = true
        run.startTime = Date()
        try? modelContext.save()
    }

    private func endRun() {
        guard let run = activeRun else { return }
        run.isActive   = false
        run.isComplete = true
        run.endTime    = Date()
        try? modelContext.save()
    }

    private func boardChild(name: String) {
        guard let run = activeRun else { return }
        run.boardChild(name)
        try? modelContext.save()
    }
}
