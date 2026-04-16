import SwiftUI
import SwiftData

struct DriverManifestView: View {
    @Query private var transportRuns: [TransportRun]
    @Query(sort: \Child.fullName) private var allChildren: [Child]

    var activeRun: TransportRun? { transportRuns.first { $0.isActive } ?? transportRuns.first }
    var manifestChildren: [Child] {
        guard let run = activeRun else { return [] }
        return allChildren.filter { run.manifestList.contains($0.fullName) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.orange).ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Transport Manifest", systemImage: "list.clipboard.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            if let run = activeRun {
                                Text("\(run.boardedList.count)/\(run.manifestList.count) boarded · \(run.estimatedArrival) ETA")
                                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                            } else {
                                Text("No active run").font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                if manifestChildren.isEmpty {
                    EmptyStateView(icon: "list.clipboard", title: "No Manifest",
                                   message: "No transport run is active or scheduled.", color: NurseryTheme.orange)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(manifestChildren) { child in
                                manifestRow(child: child)
                            }
                            // Safety note
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Safeguarding Reminder", systemImage: "lock.shield.fill")
                                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
                                Text("Never release a child to an unknown adult. Verify ID against authorised collector list. If in doubt, contact the nursery immediately.")
                                    .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                            }
                            .cardStyle()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }

    func manifestRow(child: Child) -> some View {
        let boarded = activeRun?.boardedList.contains(child.fullName) ?? false
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ChildAvatarView(initials: child.initials, size: 44,
                                color: boarded ? .green : NurseryTheme.orange,
                                isCheckedIn: boarded)
                VStack(alignment: .leading, spacing: 3) {
                    Text(child.fullName).font(.system(size: 15, weight: .semibold))
                    if !child.school.isEmpty {
                        Label(child.school, systemImage: "building.columns")
                            .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                    }
                    if child.hasAllergens {
                        Label(child.allergens.joined(separator: ", "), systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 11)).foregroundStyle(.orange)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: boarded ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(boarded ? .green : .gray)
                        .font(.system(size: 22))
                    Text(boarded ? "Boarded" : "Awaiting")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(boarded ? .green : .gray)
                }
            }
            // Authorised collectors
            if !child.authorisedCollectors.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Authorised Collectors")
                        .font(.system(size: 10, weight: .semibold)).foregroundStyle(NurseryTheme.textSecondary)
                    Text(child.authorisedCollectors)
                        .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                }
            }
        }
        .cardStyle()
    }
}
