import SwiftUI
import SwiftData

// MARK: - NurseryConnect iOS Application
// SE4020 Mobile Application Design and Development — Assignment 1
//
// User Role:   Keyworker (Early Years Practitioner / Carer)
// Feature 1:   Daily Diary & Activity Monitoring (FR13–FR18, EYFS)
// Feature 2:   Incident Reporting (FR24–FR29, RIDDOR / EYFS)
//
// Data Persistence: SwiftData (iOS 17+)
// Compliance: UK GDPR, EYFS 2024, RIDDOR 2013, Children Act 1989

@main
struct NurseryConnectApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Child.self, DiaryEntry.self, IncidentReport.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
