import SwiftUI
import SwiftData

struct ContentCalendarView: View {
    @Query(sort: \MediaPhoto.captureDate, order: .reverse) private var photos: [MediaPhoto]

    let platforms = ["Instagram", "Facebook", "Nursery Website", "Newsletter"]
    let contentIdeas = [
        ("Art & Craft", "paintbrush.pointed.fill"),
        ("Outdoor Adventures", "leaf.fill"),
        ("Story & Literacy", "book.fill"),
        ("Music & Movement", "music.note"),
        ("STEM Discoveries", "lightbulb.fill"),
        ("Celebrations", "star.circle.fill"),
        ("Seasonal Theme", "cloud.snow.fill"),
        ("Community Events", "person.3.fill"),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.indigo).ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Content Calendar", systemImage: "calendar")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("Social media planning · GDPR aware")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Platform overview
                        platformsCard

                        // This week's schedule
                        weeklyScheduleCard

                        // Content ideas
                        contentIdeasCard

                        // Best practices
                        bestPracticesCard

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
    }

    var platformsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Platforms", systemImage: "megaphone.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.indigo)
            Divider()
            HStack(spacing: 10) {
                ForEach(platforms, id: \.self) { platform in
                    VStack(spacing: 4) {
                        Image(systemName: platformIcon(platform))
                            .font(.system(size: 20))
                            .foregroundStyle(NurseryTheme.indigo)
                        Text(platform)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(NurseryTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .cardStyle()
    }

    var weeklyScheduleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("This Week", systemImage: "calendar.badge.clock")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.indigo)
            Divider()
            let approved = photos.filter { $0.isApprovedForSocial && !$0.postedToSocial }
            if approved.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "clock.fill").foregroundStyle(.gray).font(.system(size: 18))
                    Text("No approved posts ready this week. Review pending media in the library.")
                        .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
                }
            } else {
                ForEach(approved.prefix(5)) { photo in
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6).fill(NurseryTheme.indigo.opacity(0.1)).frame(width: 32, height: 32)
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 13)).foregroundStyle(NurseryTheme.indigo)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(photo.caption.isEmpty ? photo.activityTag : photo.caption)
                                .font(.system(size: 13, weight: .semibold)).lineLimit(1)
                            Text("Approved by \(photo.approvedByManager.isEmpty ? "Manager" : photo.approvedByManager)")
                                .font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                        StatusPill(label: "Ready", color: .green)
                    }
                }
            }
        }
        .cardStyle()
    }

    var contentIdeasCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Content Ideas", systemImage: "lightbulb.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.indigo)
            Divider()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(contentIdeas, id: \.0) { (idea, icon) in
                    HStack(spacing: 8) {
                        Image(systemName: icon).font(.system(size: 14)).foregroundStyle(NurseryTheme.indigo)
                        Text(idea).font(.system(size: 12, weight: .medium)).lineLimit(2)
                        Spacer()
                    }
                    .padding(10)
                    .background(NurseryTheme.indigo.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .cardStyle()
    }

    var bestPracticesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Best Practice Reminders", systemImage: "checkmark.shield.fill")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                practiceRow("Post between 9-11am or 7-9pm for best reach")
                practiceRow("Use positive, professional language always")
                practiceRow("Tag local community groups where appropriate")
                practiceRow("Respond to comments within 24 hours")
                practiceRow("Never mention specific children by name publicly")
                practiceRow("Review consent before every post")
            }
        }
        .cardStyle()
    }

    func practiceRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.system(size: 11))
            .foregroundStyle(NurseryTheme.textSecondary)
    }

    func platformIcon(_ platform: String) -> String {
        switch platform {
        case "Instagram":       return "camera.fill"
        case "Facebook":        return "hand.thumbsup.fill"
        case "Nursery Website": return "globe"
        case "Newsletter":      return "envelope.fill"
        default:                return "megaphone.fill"
        }
    }
}
