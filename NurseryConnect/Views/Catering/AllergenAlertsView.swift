import SwiftUI
import SwiftData

struct AllergenAlertsView: View {
    @Query(sort: \Child.fullName) private var allChildren: [Child]
    @State private var showAll = false

    var allergenChildren: [Child] { allChildren.filter { $0.hasAllergens } }
    var displayChildren: [Child] { showAll ? allergenChildren : allergenChildren.filter { $0.isCheckedIn } }

    let topAllergens = ["Milk","Eggs","Peanuts","Tree nuts","Fish","Shellfish","Wheat","Soya","Sesame","Celery","Mustard","Sulphites","Lupin","Molluscs"]

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.red).ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Allergen Register", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("14 EU Declarable Allergens · FSA Compliant")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Toggle filter
                        HStack {
                            Text(showAll ? "All registered children" : "Children in today")
                                .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
                            Spacer()
                            Toggle("", isOn: $showAll)
                                .labelsHidden()
                                .tint(NurseryTheme.red)
                        }
                        .cardStyle(padding: 12)

                        // Summary
                        allergenSummaryGrid

                        // Children list
                        if displayChildren.isEmpty {
                            EmptyStateView(icon: "checkmark.circle",
                                           title: "No Allergens",
                                           message: showAll ? "No children have registered allergens." : "No children with allergens are present today.",
                                           color: .green)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: showAll ? "All Allergen Records (\(displayChildren.count))" : "Present Today (\(displayChildren.count))")
                                ForEach(displayChildren) { child in
                                    allergenChildCard(child)
                                }
                            }
                        }

                        // Legal notice
                        legalNotice

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
    }

    var allergenSummaryGrid: some View {
        let active = allChildren.filter { $0.hasAllergens }
        let present = allergenChildren.filter { $0.isCheckedIn }
        let anaphylactic = allergenChildren.filter { $0.allergenSeverity == "anaphylactic" }

        return HStack(spacing: 10) {
            allergenStatCell(value: "\(active.count)",       label: "Registered", color: NurseryTheme.red)
            allergenStatCell(value: "\(present.count)",      label: "Present",    color: .orange)
            allergenStatCell(value: "\(anaphylactic.count)", label: "Anaphylactic", color: anaphylactic.isEmpty ? .green : .red)
        }
    }

    func allergenStatCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .bold)).foregroundStyle(color)
            Text(label).font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(NurseryTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    func allergenChildCard(_ child: Child) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ChildAvatarView(initials: child.initials, size: 44, color: NurseryTheme.red, isCheckedIn: child.isCheckedIn)
                VStack(alignment: .leading, spacing: 3) {
                    Text(child.fullName).font(.system(size: 15, weight: .semibold))
                    Text(child.room).font(.system(size: 12)).foregroundStyle(NurseryTheme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    AllergenSeverityBadge(severity: child.allergenSeverity)
                    Text(child.isCheckedIn ? "Present" : "Absent")
                        .font(.system(size: 10))
                        .foregroundStyle(child.isCheckedIn ? .green : .gray)
                }
            }
            // Allergen tags
            FlowLayout(spacing: 6) {
                ForEach(child.allergens, id: \.self) { allergen in
                    Text(allergen)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                }
            }
            if child.allergenSeverity == "anaphylactic" {
                Label("EpiPen on site — check location before service", systemImage: "cross.case.fill")
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(.red)
                    .padding(6).background(Color.red.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .cardStyle()
    }

    var legalNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Legal Obligation", systemImage: "doc.text.fill")
                .font(.system(size: 12, weight: .semibold)).foregroundStyle(NurseryTheme.primary)
            Text("Under the Food Information for Consumers Regulation (EU FIC 1169/2011, retained in UK law), all 14 major allergens must be declared in pre-prepared food. Staff must verify allergen status before every mealtime service.")
                .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle()
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                y += lineHeight + spacing; x = 0; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += lineHeight + spacing; x = bounds.minX; lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
