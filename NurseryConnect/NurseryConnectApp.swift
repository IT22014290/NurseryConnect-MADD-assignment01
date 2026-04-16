import SwiftUI
import SwiftData

@main
struct NurseryConnectApp: App {
    @State private var appState = AppState()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            IncidentReport.self,
            AttendanceRecord.self,
            MealRecord.self,
            Message.self,
            MealPlanItem.self,
            TransportRun.self,
            StockItem.self,
            MediaPhoto.self
        ])

        func makeConfig() -> ModelConfiguration {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [makeConfig()])
        } catch {
            // Schema changed (e.g. property renamed) — wipe the old store and start fresh.
            // Sample data will be re-seeded automatically on next launch.
            let storeURL = makeConfig().url
            try? FileManager.default.removeItem(at: storeURL)
            do {
                return try ModelContainer(for: schema, configurations: [makeConfig()])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onAppear {
                    seedSampleDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedSampleDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Child>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            SampleData.populate(context: context)
        }
    }
}
