import SwiftUI
import MapKit
import SwiftData

struct GPSTrackingView: View {
    @Environment(AppState.self) private var appState
    @Query private var transportRuns: [TransportRun]
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var vanCoord = CLLocationCoordinate2D(latitude: 51.505, longitude: -0.125)
    @State private var nurseryCoord = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
    @State private var animationTimer: Timer? = nil
    @State private var stepCount = 0

    var myChild: Child? { allChildren.first }
    var activeRun: TransportRun? { transportRuns.first }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.teal.ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Van Tracker", systemImage: "bus.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("Live GPS · Updated every 10 seconds")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                        Circle()
                            .fill(activeRun != nil ? Color.green : Color.gray)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                if let child = myChild, !child.isTransportChild {
                    // No transport
                    EmptyStateView(icon: "bus", title: "Not on transport list",
                                   message: "\(child.preferredName) is not registered for the nursery transport service.",
                                   color: NurseryTheme.teal)
                    Spacer()
                } else {
                    // Map
                    Map(position: $cameraPosition) {
                        // Nursery pin
                        Annotation("Little Stars Nursery", coordinate: nurseryCoord) {
                            ZStack {
                                Circle()
                                    .fill(NurseryTheme.primary)
                                    .frame(width: 36, height: 36)
                                    .shadow(radius: 4)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white)
                            }
                        }

                        // Van pin (animated)
                        Annotation("Nursery Van", coordinate: vanCoord) {
                            ZStack {
                                Circle()
                                    .fill(NurseryTheme.teal)
                                    .frame(width: 44, height: 44)
                                    .shadow(radius: 6)
                                Image(systemName: "bus.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 0))

                    // Status Cards
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            // Run status
                            if let run = activeRun {
                                runStatusCard(run: run)
                            } else {
                                noActiveRunCard
                            }

                            // Child status
                            if let child = myChild {
                                childTransportStatus(child)
                            }

                            // Safety info
                            safetyInfoCard

                            Spacer(minLength: 24)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
        }
        .onAppear { startVanAnimation() }
        .onDisappear { animationTimer?.invalidate() }
    }

    func runStatusCard(run: TransportRun) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Active Transport Run", systemImage: "bus.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(NurseryTheme.teal)
                Spacer()
                StatusPill(label: "Live", color: NurseryTheme.teal)
            }
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Driver").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    Text(run.driverName).font(.system(size: 13, weight: .semibold))
                }
                Spacer()
                VStack(alignment: .center, spacing: 4) {
                    Text("ETA").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    Text(run.estimatedArrival).font(.system(size: 13, weight: .bold)).foregroundStyle(NurseryTheme.teal)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Children").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    Text("\(run.boardedList.count)/\(run.manifestList.count)").font(.system(size: 13, weight: .semibold))
                }
            }
        }
        .cardStyle()
    }

    var noActiveRunCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill").foregroundStyle(.gray).font(.system(size: 20))
            VStack(alignment: .leading, spacing: 3) {
                Text("No Active Transport Run")
                    .font(.system(size: 14, weight: .semibold))
                Text("The van is not currently on a collection run. You will receive a notification when a run starts.")
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
        }
        .cardStyle()
    }

    func childTransportStatus(_ child: Child) -> some View {
        HStack(spacing: 14) {
            ChildAvatarView(initials: child.initials, size: 44, color: NurseryTheme.pink, isCheckedIn: child.isCheckedIn)
            VStack(alignment: .leading, spacing: 3) {
                Text(child.fullName).font(.system(size: 15, weight: .semibold))
                if !child.school.isEmpty {
                    Label(child.school, systemImage: "building.columns")
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
            }
            Spacer()
            StatusPill(label: child.isCheckedIn ? "Arrived" : "Awaiting", color: child.isCheckedIn ? .green : .orange)
        }
        .cardStyle()
    }

    var safetyInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Safety & Privacy", systemImage: "lock.shield.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NurseryTheme.primary)
            VStack(alignment: .leading, spacing: 4) {
                Label("Location shown within 50 metres to protect driver privacy", systemImage: "circle.and.line.horizontal")
                Label("GPS data retained for 31 days (ICO CCTV Code of Practice)", systemImage: "calendar")
                Label("Driver DBS-checked and insured", systemImage: "checkmark.shield")
                Label("All GPS data encrypted in transit (UK GDPR)", systemImage: "lock")
            }
            .font(.system(size: 11))
            .foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle()
    }

    private func startVanAnimation() {
        // Simulate van moving towards nursery
        let startLat = 51.495, startLon = -0.115
        let endLat   = nurseryCoord.latitude
        let endLon   = nurseryCoord.longitude
        let steps    = 30

        animationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            stepCount = (stepCount + 1) % steps
            let t = Double(stepCount) / Double(steps)
            let newLat = startLat + (endLat - startLat) * t + Double.random(in: -0.001...0.001)
            let newLon = startLon + (endLon - startLon) * t + Double.random(in: -0.001...0.001)
            withAnimation(.linear(duration: 2.5)) {
                vanCoord = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
            }
        }
    }
}
