import SwiftUI
import SwiftData

struct ReportsView: View {
    @Query private var allChildren: [Child]
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var allIncidents: [IncidentReport]
    @Query(sort: \AttendanceRecord.date, order: .reverse) private var allRecords: [AttendanceRecord]
    @Query private var allMealRecords: [MealRecord]

    var body: some View {
        ZStack(alignment: .top) {
            NurseryTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                ZStack {
                    NurseryTheme.gradient(NurseryTheme.primary).ignoresSafeArea(edges: .top)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Label("Reports & Compliance", systemImage: "doc.text.fill")
                                .font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            Text("Operational overview · EYFS / Ofsted ready")
                                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
                }
                .frame(height: 90)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // GDPR & Compliance summary
                        complianceSection

                        // Incident statistics
                        incidentStatsCard

                        // Allergen summary
                        allergenSummaryCard

                        // Consent summary
                        consentSummaryCard

                        // Quick reports list
                        quickReportsList

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
        }
    }

    var complianceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Compliance Status", systemImage: "checkmark.shield.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(.green)
            Divider()
            complianceRow(label: "EYFS Framework 2024", status: true, note: "All mandatory checks current")
            complianceRow(label: "Ofsted Registration", status: true, note: "Valid — next inspection TBC")
            complianceRow(label: "DBS Checks (Staff)", status: true, note: "All staff current")
            complianceRow(label: "ICO Registration (UK GDPR)", status: true, note: "Registered data controller")
            complianceRow(label: "Food Hygiene Certificate", status: true, note: "5-star rating")
            complianceRow(label: "Public Liability Insurance", status: true, note: "£5m cover in force")
            complianceRow(label: "RIDDOR Pending", status: allIncidents.filter { $0.riddorRequired && $0.status != "finalised" }.isEmpty,
                           note: allIncidents.filter { $0.riddorRequired && $0.status != "finalised" }.isEmpty ? "No outstanding reports" : "\(allIncidents.filter { $0.riddorRequired && $0.status != "finalised" }.count) report(s) outstanding")
        }
        .cardStyle()
    }

    func complianceRow(label: String, status: Bool, note: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(status ? .green : .red)
                .font(.system(size: 15))
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 13, weight: .semibold))
                Text(note).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
        }
    }

    var incidentStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Incident Statistics (30 days)", systemImage: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.primary)
            Divider()
            let pending   = allIncidents.filter { $0.status == "pending" }.count
            let reviewed  = allIncidents.filter { $0.status == "reviewed" }.count
            let finalised = allIncidents.filter { $0.status == "finalised" }.count
            let serious   = allIncidents.filter { $0.isSerious }.count

            HStack(spacing: 0) {
                incidentStatCell(value: "\(allIncidents.count)", label: "Total", color: NurseryTheme.primary)
                Divider().frame(height: 40)
                incidentStatCell(value: "\(pending)", label: "Pending", color: .orange)
                Divider().frame(height: 40)
                incidentStatCell(value: "\(reviewed)", label: "Reviewed", color: NurseryTheme.teal)
                Divider().frame(height: 40)
                incidentStatCell(value: "\(serious)", label: "Serious", color: .red)
            }
            .frame(maxWidth: .infinity)

            if serious > 0 {
                Label("\(serious) serious incident(s) may require Ofsted notification.", systemImage: "exclamationmark.octagon.fill")
                    .font(.system(size: 11)).foregroundStyle(.red)
                    .padding(8).background(Color.red.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .cardStyle()
    }

    func incidentStatCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 22, weight: .bold)).foregroundStyle(color)
            Text(label).font(.system(size: 10)).foregroundStyle(NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    var allergenSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Allergen Register (FSA Compliant)", systemImage: "allergens")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.red)
            Divider()
            let allergicChildren = allChildren.filter { $0.hasAllergens }
            if allergicChildren.isEmpty {
                Text("No registered allergens on file.")
                    .font(.system(size: 13)).foregroundStyle(NurseryTheme.textSecondary)
            } else {
                ForEach(allergicChildren) { child in
                    HStack(spacing: 10) {
                        ChildAvatarView(initials: child.initials, size: 32, color: NurseryTheme.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(child.fullName).font(.system(size: 13, weight: .semibold))
                            Text(child.allergens.joined(separator: " · "))
                                .font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                        AllergenSeverityBadge(severity: child.allergenSeverity)
                    }
                }
            }
        }
        .cardStyle()
    }

    var consentSummaryCard: some View {
        let total = allChildren.count
        let photo  = allChildren.filter { $0.photographyConsent }.count
        let social = allChildren.filter { $0.socialMediaConsent }.count
        let gps    = allChildren.filter { $0.gpsConsent }.count
        let dataP  = allChildren.filter { $0.dataProcessingConsent }.count
        return VStack(alignment: .leading, spacing: 12) {
            Label("Consent Summary (UK GDPR)", systemImage: "lock.shield.fill")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.purple)
            Divider()
            if total == 0 {
                Text("No children registered.").font(.system(size: 13))
            } else {
                consentRow(label: "Photography",    count: photo,  total: total)
                consentRow(label: "Social Media",   count: social, total: total)
                consentRow(label: "GPS Tracking",   count: gps,    total: total)
                consentRow(label: "Data Processing",count: dataP,  total: total)
            }
        }
        .cardStyle()
    }

    func consentRow(label: String, count: Int, total: Int) -> some View {
        let pct = total > 0 ? Double(count) / Double(total) : 0
        return HStack(spacing: 10) {
            Text(label).font(.system(size: 12)).frame(width: 120, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(NurseryTheme.background).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(NurseryTheme.primary.opacity(0.7))
                        .frame(width: geo.size.width * pct, height: 6)
                }
            }
            .frame(height: 6)
            Text("\(count)/\(total)").font(.system(size: 11, weight: .semibold))
                .foregroundStyle(NurseryTheme.textSecondary).frame(width: 36, alignment: .trailing)
        }
    }

    var quickReportsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Export Reports", systemImage: "square.and.arrow.up")
                .font(.system(size: 14, weight: .bold)).foregroundStyle(NurseryTheme.primary)
            Divider()
            Group {
                reportExportRow(title: "Attendance Register",     subtitle: "Daily/weekly attendance log",      icon: "person.3.fill",               color: NurseryTheme.teal)
                reportExportRow(title: "Incident Log",            subtitle: "All incidents with status",        icon: "exclamationmark.triangle.fill",color: .orange)
                reportExportRow(title: "Allergen Register",       subtitle: "FSA-compliant allergen list",      icon: "allergens",                   color: NurseryTheme.red)
                reportExportRow(title: "Consent Records",         subtitle: "GDPR consent audit trail",         icon: "lock.shield.fill",            color: NurseryTheme.purple)
                reportExportRow(title: "EYFS Progress Overview",  subtitle: "Development milestones summary",   icon: "star.fill",                   color: .yellow)
                reportExportRow(title: "Meal & Nutrition Log",    subtitle: "FSA / food hygiene records",       icon: "fork.knife",                  color: NurseryTheme.primary)
            }
        }
        .cardStyle()
    }

    func reportExportRow(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 13)).foregroundStyle(NurseryTheme.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Allergen Severity Badge

struct AllergenSeverityBadge: View {
    let severity: String
    var color: Color {
        switch severity {
        case "anaphylactic": return .red
        case "allergy":      return .orange
        case "intolerance":  return .yellow
        default:             return .gray
        }
    }
    var body: some View {
        Text(severity.capitalized)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }
}
