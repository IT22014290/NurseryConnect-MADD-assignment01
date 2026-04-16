import SwiftUI
import SwiftData

struct AdminComplianceView: View {
    @Query private var allChildren: [Child]
    @Query private var allIncidents: [IncidentReport]

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(colors: [Color(hex: "#2C3E50"), Color(hex: "#3D5A73")],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Compliance Centre", systemImage: "checkmark.shield.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("EYFS · Ofsted · UK GDPR · RIDDOR")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        legislationCard
                        consentAuditCard
                        safeguardingCard
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
    }

    var legislationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Applicable Legislation", systemImage: "doc.text.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.gray)
            Divider()
            VStack(spacing: 8) {
                legRow(title: "EYFS Statutory Framework 2024",
                       body: "Learning, development and welfare requirements for all Ofsted-registered settings.")
                legRow(title: "Children Act 1989 & 2004",
                       body: "Welfare of the child is paramount. Section 47 duty to investigate.")
                legRow(title: "UK GDPR & Data Protection Act 2018",
                       body: "Lawful processing, data minimisation, retention schedules, and subject rights.")
                legRow(title: "Food Safety Act 1990 & EU FIC 1169/2011",
                       body: "Allergen labelling for all 14 declarable allergens in pre-prepared food.")
                legRow(title: "RIDDOR 2013",
                       body: "Mandatory reporting of specified injuries, over-7-day injuries, and dangerous occurrences.")
                legRow(title: "Equality Act 2010",
                       body: "Protected characteristics including disability must not be subject to unlawful discrimination.")
                legRow(title: "Working Together to Safeguard Children 2023",
                       body: "Multi-agency framework for safeguarding and promoting the welfare of children.")
            }
        }
        .cardStyle()
    }

    func legRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 12, weight: .semibold))
            Text(body).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .padding(.vertical, 2)
    }

    var consentAuditCard: some View {
        let total   = allChildren.count
        let missing = allChildren.filter { !$0.dataProcessingConsent }.count
        return VStack(alignment: .leading, spacing: 12) {
            Label("Consent Audit", systemImage: "lock.shield.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.gray)
            Divider()
            if total == 0 {
                Text("No children registered.").font(.system(size: 13))
            } else if missing > 0 {
                Label("\(missing) child/ren missing data processing consent — action required.",
                      systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 12)).foregroundStyle(.red)
                    .padding(8).background(Color.red.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Label("All \(total) children have valid data processing consent on file.",
                      systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12)).foregroundStyle(.green)
            }
        }
        .cardStyle()
    }

    var safeguardingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Safeguarding", systemImage: "lock.shield.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.gray)
            Divider()
            let safeguarding = allIncidents.filter { $0.category == "safeguarding" }
            InfoRow(label: "Total safeguarding concerns", value: "\(safeguarding.count)")
            InfoRow(label: "Pending review", value: "\(safeguarding.filter { $0.status == "pending" }.count)")
            InfoRow(label: "Finalised", value: "\(safeguarding.filter { $0.status == "finalised" }.count)")
            Divider()
            Text("All safeguarding concerns must be logged, reviewed by the Designated Safeguarding Lead (DSL) and, where applicable, referred to the Local Authority Designated Officer (LADO).")
                .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .cardStyle()
    }
}
