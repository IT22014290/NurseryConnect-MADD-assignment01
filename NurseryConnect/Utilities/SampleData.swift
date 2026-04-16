import Foundation
import SwiftData

enum SampleData {

    static func populate(context: ModelContext) {
        let cal = Calendar.current
        func dob(years: Int, months: Int = 0) -> Date {
            cal.date(byAdding: .month, value: -(years * 12 + months), to: Date()) ?? Date()
        }

        // MARK: - Children
        let c0 = buildChild("Olivia Bennett",   dob: dob(years: 3, months: 4),  kw: "Sarah Johnson",  room: "Sunshine Room",  parent1: "Emma Bennett",   phone1: "07700900001", diet: "",                      allergens: "")
        let c1 = buildChild("Noah Williams",    dob: dob(years: 2, months: 1),  kw: "Sarah Johnson",  room: "Sunshine Room",  parent1: "Claire Williams", phone1: "07700900002", diet: "Vegetarian",            allergens: "Milk,Eggs")
        let c2 = buildChild("Isla Thompson",    dob: dob(years: 4, months: 0),  kw: "James Carter",   room: "Rainbow Room",   parent1: "Fiona Thompson",  phone1: "07700900003", diet: "Gluten-Free",           allergens: "Gluten")
        let c3 = buildChild("Ethan Harris",     dob: dob(years: 1, months: 8),  kw: "Sarah Johnson",  room: "Sunshine Room",  parent1: "Rachel Harris",   phone1: "07700900004", diet: "",                      allergens: "Peanuts")
        let c4 = buildChild("Amelia Clarke",    dob: dob(years: 3, months: 6),  kw: "James Carter",   room: "Rainbow Room",   parent1: "Helen Clarke",    phone1: "07700900005", diet: "Halal",                 allergens: "")
        let c5 = buildChild("Liam Patel",       dob: dob(years: 2, months: 9),  kw: "Priya Singh",    room: "Starlight Room", parent1: "Anita Patel",     phone1: "07700900006", diet: "Vegetarian,Halal",      allergens: "Nuts,Sesame")
        let c6 = buildChild("Sophia Davis",     dob: dob(years: 4, months: 2),  kw: "Priya Singh",    room: "Starlight Room", parent1: "Kate Davis",      phone1: "07700900007", diet: "",                      allergens: "")
        let c7 = buildChild("Jack Robinson",    dob: dob(years: 0, months: 14), kw: "James Carter",   room: "Rainbow Room",   parent1: "Lucy Robinson",   phone1: "07700900008", diet: "",                      allergens: "")

        let children = [c0, c1, c2, c3, c4, c5, c6, c7]
        for c in children { context.insert(c) }

        // Check in
        c0.isCheckedIn = true; c0.checkInTime = cal.date(bySettingHour: 8,  minute: 15, second: 0, of: Date()); c0.checkInBy = "Emma Bennett"
        c1.isCheckedIn = true; c1.checkInTime = cal.date(bySettingHour: 8,  minute: 30, second: 0, of: Date()); c1.checkInBy = "Claire Williams"
        c2.isCheckedIn = true; c2.checkInTime = cal.date(bySettingHour: 9,  minute: 0,  second: 0, of: Date()); c2.checkInBy = "Fiona Thompson"
        c4.isCheckedIn = true; c4.checkInTime = cal.date(bySettingHour: 8,  minute: 45, second: 0, of: Date()); c4.checkInBy = "Helen Clarke"
        c5.isCheckedIn = true; c5.checkInTime = cal.date(bySettingHour: 9,  minute: 10, second: 0, of: Date()); c5.checkInBy = "Anita Patel"

        c1.allergenSeverity = "intolerance"
        c3.allergenSeverity = "anaphylactic"
        c5.allergenSeverity = "allergy"

        c2.isTransportChild = true; c2.school = "St. Mary's Primary"
        c5.isTransportChild = true; c5.school = "Hillside Academy"

        // MARK: - Diary Entries
        let diaryData: [(Child, String, String, String, Double)] = [
            (c0, "checkin",   "Arrived happy and settled. Dropped off by mum Emma.",                          "Sarah Johnson", 8.0),
            (c0, "wellbeing", "Happy and engaged on arrival. Mood: Happy.",                                    "Sarah Johnson", 7.5),
            (c0, "activity",  "Outdoor play – sandbox and climbing frame. Loved the slide!",                   "Sarah Johnson", 6.0),
            (c0, "meal",      "Breakfast: Porridge with banana. Ate most of portion.",                         "Sarah Johnson", 5.5),
            (c0, "sleep",     "Nap – settled quickly. Position: back.",                                        "Sarah Johnson", 3.0),
            (c0, "milestone", "EYFS Communication: Olivia counted to 10 independently during play!",           "Sarah Johnson", 1.5),
            (c1, "checkin",   "Arrived cheerful. Dropped off by mum Claire.",                                  "Sarah Johnson", 7.5),
            (c1, "meal",      "Lunch: Vegetarian pasta. Ate all. Dairy-free milk 180ml.",                      "Sarah Johnson", 4.0),
            (c1, "nappy",     "Wet nappy – cream applied.",                                                    "Sarah Johnson", 2.0),
            (c2, "checkin",   "Arrived with dad. Happy mood.",                                                 "James Carter",  7.0),
            (c2, "activity",  "Arts & crafts – finger painting. EYFS Expressive Arts.",                        "James Carter",  5.0),
        ]

        for item in diaryData {
            let e = DiaryEntry(childId: item.0.id, childName: item.0.fullName,
                               entryType: item.1, description: item.2, keyworkerName: item.3)
            e.timestamp = Date().addingTimeInterval(-item.4 * 3600)
            if item.1 == "meal"  { e.mealType = "lunch"; e.foodConsumed = "most"; e.fluidType = "water"; e.fluidAmount = 150 }
            if item.1 == "sleep" { e.sleepPosition = "back"; e.sleepStart = Date().addingTimeInterval(-item.4 * 3600); e.sleepEnd = Date().addingTimeInterval(-(item.4 - 1.5) * 3600) }
            if item.1 == "nappy" { e.nappyType = "wet"; e.creamApplied = true }
            context.insert(e)
        }

        // MARK: - Incidents
        let inc1 = IncidentReport(childId: c0.id, childName: c0.fullName, reportedBy: "Sarah Johnson",
                                   category: "minor_accident",
                                   description: "Olivia slipped near the sink and grazed her right knee. No bleeding – cleaned and plaster applied.")
        inc1.location = "Bathroom"
        inc1.immediateAction = "Wound cleaned with antiseptic wipe. Small plaster applied. Child settled and resumed play."
        inc1.witnesses = "James Carter"
        inc1.status = "pending"
        inc1.injuryBodyLocation = "Right knee"
        context.insert(inc1)

        let inc2 = IncidentReport(childId: c1.id, childName: c1.fullName, reportedBy: "Sarah Johnson",
                                   category: "minor_accident",
                                   description: "Noah bumped his forehead on the table corner. Small red mark – no loss of consciousness.")
        inc2.location = "Dining Area"
        inc2.immediateAction = "Cold compress applied for 10 minutes. Child monitored for 30 minutes."
        inc2.witnesses = "Priya Singh"
        inc2.status = "reviewed"
        inc2.managerName = "Mrs. Karen White"
        inc2.managerReviewDate = Date().addingTimeInterval(-3600)
        inc2.parentNotified = true
        inc2.parentNotifiedTime = Date().addingTimeInterval(-3000)
        inc2.injuryBodyLocation = "Forehead"
        context.insert(inc2)

        // MARK: - Meal Plan
        let monday = currentWeekMonday()
        let mealPlanData: [(Int, String, String, String)] = [
            (0, "breakfast",       "Porridge with banana",                    "Milk,Gluten"),
            (0, "morning_snack",   "Apple slices & water",                    ""),
            (0, "lunch",           "Chicken with roast vegetables",           ""),
            (0, "afternoon_snack", "Yoghurt with berries",                    "Milk"),
            (1, "breakfast",       "Wholegrain toast with baked beans",       "Gluten"),
            (1, "morning_snack",   "Breadsticks & hummus",                    "Gluten,Sesame"),
            (1, "lunch",           "Pasta bolognese",                         "Gluten,Milk"),
            (1, "afternoon_snack", "Cucumber & cream cheese",                 "Milk"),
            (2, "breakfast",       "Weetabix with milk",                      "Gluten,Milk"),
            (2, "morning_snack",   "Pear slices",                             ""),
            (2, "lunch",           "Salmon fishcakes with peas",              "Fish,Gluten,Eggs"),
            (2, "afternoon_snack", "Melon chunks",                            ""),
            (3, "breakfast",       "Scrambled egg on toast",                  "Eggs,Gluten"),
            (3, "morning_snack",   "Rice cakes",                              "Gluten"),
            (3, "lunch",           "Beef stew with mashed potato",            ""),
            (3, "afternoon_snack", "Cheese & crackers",                       "Milk,Gluten"),
            (4, "breakfast",       "Muesli",                                  "Gluten,Milk,Nuts"),
            (4, "morning_snack",   "Carrot sticks",                           ""),
            (4, "lunch",           "Cheese & vegetable quesadilla",           "Milk,Gluten"),
            (4, "afternoon_snack", "Banana with milk",                        "Milk"),
        ]
        for item in mealPlanData {
            let m = MealPlanItem(weekStartDate: monday, dayOfWeek: item.0, mealType: item.1, foodItem: item.2, allergens: item.3)
            context.insert(m)
        }

        // MARK: - Stock
        let stockData: [(String, String, Double, Double, String)] = [
            ("Whole Milk",          "Dairy",   5,  10, "litres"),
            ("Eggs (Free Range)",   "Protein", 24, 12, "units"),
            ("Wholegrain Bread",    "Grains",  3,  4,  "loaves"),
            ("Baby Porridge",       "Grains",  2,  3,  "kg"),
            ("Salmon (Fresh)",      "Fish",    1,  2,  "kg"),
            ("Chicken Breast",      "Protein", 3,  2,  "kg"),
            ("Mixed Vegetables",    "Produce", 4,  3,  "kg"),
            ("Pasta (Wholegrain)",  "Grains",  2,  2,  "kg"),
        ]
        for s in stockData {
            let item = StockItem(name: s.0, category: s.1, currentLevel: s.2, minimumLevel: s.3, unit: s.4)
            context.insert(item)
        }

        // MARK: - Messages
        let msg1 = Message(senderName: "Emma Bennett", senderRole: "Parent",
                           recipientName: "Sarah Johnson", recipientRole: "Keyworker",
                           content: "Hi Sarah, Olivia had a slight runny nose this morning. She had Calpol before coming in – could you keep an eye on her please?",
                           childName: "Olivia Bennett")
        let msg2 = Message(senderName: "Sarah Johnson", senderRole: "Keyworker",
                           recipientName: "Emma Bennett", recipientRole: "Parent",
                           content: "Thanks Emma. Olivia is happy and settled. Will monitor and update you if anything changes.",
                           childName: "Olivia Bennett")
        let msg3 = Message(senderName: "Mrs. Karen White", senderRole: "Setting Manager",
                           recipientName: "All Staff", recipientRole: "Keyworker",
                           content: "Reminder: Please ensure all diary entries are completed before 4pm handover. Ofsted visit scheduled for Thursday – keep records up to date.")
        msg2.isRead = true
        msg3.isRead = false
        context.insert(msg1); context.insert(msg2); context.insert(msg3)

        // MARK: - Transport Run
        let run = TransportRun(driverName: "Mike Stevens", children: ["Isla Thompson", "Liam Patel"])
        run.estimatedArrival = "3:45 PM"
        context.insert(run)

        // MARK: - Media Photos
        let photoData: [(String, String, String)] = [
            ("Outdoor Play",   "Children enjoying the sunshine in our garden",          "Sarah Johnson"),
            ("Arts & Crafts",  "Creative afternoon – wonderful artwork from our children", "James Carter"),
            ("Story Time",     "Afternoon story time – so engaged!",                      "Priya Singh"),
            ("Music Session",  "Exploring sounds and rhythms today",                      "Sarah Johnson"),
        ]
        for (tag, cap, kw) in photoData {
            let p = MediaPhoto(activityTag: tag, caption: cap, keyworkerName: kw)
            context.insert(p)
        }

        try? context.save()
    }

    // MARK: - Builder helpers

    private static func buildChild(_ name: String, dob: Date, kw: String, room: String,
                                    parent1: String, phone1: String, diet: String, allergens: String) -> Child {
        let c = Child(fullName: name, dateOfBirth: dob, keyworkerName: kw, room: room)
        c.parentOneName  = parent1
        c.parentOnePhone = phone1
        c.parentOneEmail = parent1.lowercased().replacingOccurrences(of: " ", with: ".") + "@email.com"
        c.dietaryRequirements = diet
        c.allergenList   = allergens
        c.authorisedCollectors = "\(parent1) (Parent)"
        c.address        = "123 Sample Street, London, UK"
        c.photographyConsent      = true
        c.socialMediaConsent      = allergens.isEmpty
        c.dataProcessingConsent   = true
        c.medicalTreatmentConsent = true
        c.gpsConsent = true
        return c
    }

    private static func currentWeekMonday() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
    }
}
