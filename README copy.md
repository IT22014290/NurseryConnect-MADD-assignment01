# NurseryConnect - Setting Manager iOS App

## SE4020 Assignment 1 - Mobile Application Design and Development

### Student Information
- **Student Name:** [Samishka H T]
- **Student ID:** [IT22014290]
- **Chosen User Role:** Setting Manager
- **Selected Features:** Staff Rota Management + Room Capacity Tracking

---

## 📋 Executive Summary

This iOS application provides a **Setting Manager** with essential tools to manage staff scheduling and monitor room capacity compliance. The app implements two complementary features that address critical operational and regulatory requirements for early years childcare settings in the UK.

### Why These Features?

**1. Staff Rota Management**
- Enables efficient workforce planning and scheduling
- Tracks staff qualifications and compliance certifications (DBS, First Aid)
- Provides visibility into staff deployment across rooms
- Supports different shift types (regular, overtime, cover, training)

**2. Room Capacity Tracking**
- Monitors real-time occupancy and staff-to-child ratios
- Ensures compliance with EYFS 2024 statutory requirements
- Provides immediate visibility into capacity constraints
- Helps prevent over-enrollment and maintain safety standards

These features work together: staff scheduling directly impacts room capacity compliance, as EYFS 2024 mandates specific staff-to-child ratios based on age groups.

---

## 🎯 Key Features

### Feature 1: Staff Rota Management

**Core Functionality:**
- View weekly staff schedules with calendar navigation
- Add, edit, and delete staff shifts
- Assign staff to specific rooms or floating roles
- Track shift types (regular, overtime, cover, training)
- Monitor total staff hours and room coverage
- View compliance status (DBS checks, certifications)

**EYFS 2024 Compliance:**
- Tracks staff qualification levels (Level 2-6, QTS, EYT)
- Monitors DBS check validity (3-year renewal cycle)
- Tracks first aid certification expiry
- Displays compliance percentage for scheduled staff

**User Interface:**
- Weekly calendar view with day selection
- Summary cards showing total staff, hours, and compliance
- Shifts organized by room
- Color-coded role indicators
- Swipe-to-delete functionality

### Feature 2: Room Capacity Tracking

**Core Functionality:**
- Real-time room occupancy monitoring
- EYFS 2024 staff-to-child ratio calculations
- Visual capacity indicators and progress bars
- Compliance status for all rooms
- Child attendance management
- Detailed room views with staff and children lists

**EYFS 2024 Ratios Implemented:**
- **Babies (0-2 years):** 1 staff : 3 children
- **Toddlers (2 years):** 1 staff : 3 children
- **Pre-school (3-5 years):** 1 staff : 8 children
- **Mixed age groups:** Uses most restrictive ratio (1:3)

**User Interface:**
- Dashboard with overall summary statistics
- Room capacity cards with visual status indicators
- Occupancy percentage and progress bars
- Required vs. actual staff count comparison
- Compliance alerts and warnings

---

## 🏗️ Technical Architecture

### Technology Stack
- **Language:** Swift 5.9+
- **Framework:** SwiftUI
- **Data Persistence:** SwiftData (iOS 17+)
- **Minimum iOS Version:** iOS 17.0
- **Architecture Pattern:** MVVM (Model-View-ViewModel)

### Data Models

**1. StaffMember**
```swift
- Personal Information: firstName, lastName, employeeID
- Role: manager, roomLeader, keyworker, assistant, etc.
- Qualifications: Level 2-6, QTS, EYT
- Compliance: DBS dates, first aid certification
- Relationships: Many-to-many with Shifts
```

**2. Shift**
```swift
- Assignment: staffMember, room, date
- Timing: startTime, endTime
- Type: regular, overtime, cover, training
- Relationships: Belongs to StaffMember and Room
```

**3. Room**
```swift
- Identity: name, ageGroup
- Capacity: maxCapacity, currentOccupancy
- Ratios: requiredStaffCount (calculated)
- Relationships: Has many Children and Shifts
```

**4. Child**
```swift
- Identity: firstName, lastName, dateOfBirth
- Enrollment: room, enrollmentDate
- Attendance: isPresent
- Medical: dietaryRequirements, allergies (GDPR-sensitive)
- Relationships: Belongs to Room
```

### Key Algorithms

**Staff-to-Child Ratio Calculation:**
```swift
var requiredStaffCount: Int {
    switch ageGroup {
    case .babies, .toddlers:
        return ceil(currentOccupancy / 3.0)  // 1:3 ratio
    case .preschool:
        return ceil(currentOccupancy / 8.0)  // 1:8 ratio
    case .mixed:
        return ceil(currentOccupancy / 3.0)  // Most restrictive
    }
}
```

**Compliance Status Calculation:**
```swift
var compliancePercentage: String {
    let validStaff = shifts.filter { $0.staffMember?.isDBSValid ?? false }.count
    return Int((Double(validStaff) / Double(totalStaff)) * 100)
}
```

---

## 📱 User Interface Design

### Design Principles

1. **Professional Aesthetic**
   - Clean, modern interface appropriate for childcare professionals
   - Soft color palette with clear status indicators
   - Consistent use of SF Symbols for icons

2. **Information Hierarchy**
   - Critical information (compliance, capacity) prominently displayed
   - Summary cards provide at-a-glance insights
   - Detailed information accessible through drill-down

3. **Color-Coded Status**
   - Green: Compliant, low occupancy, valid certifications
   - Blue: Normal operations
   - Orange: Warnings, near capacity, expiring certifications
   - Red: Non-compliant, full capacity, expired certifications

4. **Touch-Friendly Design**
   - Minimum 44pt touch targets
   - Swipe gestures for common actions
   - Clear visual feedback for interactions

### Key UI Components

**Tab Navigation**
- Staff Rota tab with calendar icon
- Room Capacity tab with door icon
- Easy switching between features

**Summary Cards**
- Large, readable metrics
- Icon-based visual hierarchy
- Color-coded status indicators

**List Views**
- Grouped sections for organization
- Swipe actions for quick operations
- Search and filter capabilities

---

## 🔒 Regulatory Compliance & Data Protection

### UK GDPR Compliance

**Data Minimization:**
- Only essential data is collected and stored
- Medical and dietary information limited to operational necessity
- No unnecessary tracking or analytics

**Purpose Limitation:**
- Data used exclusively for childcare operations
- Clear labeling of GDPR-sensitive fields
- No data sharing with third parties

**Storage Security:**
- SwiftData provides encrypted local storage
- Data remains on-device (no cloud sync implemented)
- Biometric authentication could be added (future enhancement)

**User Rights:**
- Data can be edited or deleted through the UI
- Export functionality could be added for data portability
- Clear retention policies should be implemented in production

**Sensitive Data Handling:**
```swift
// GDPR-sensitive fields clearly marked
child.dietaryRequirements  // Special category data
child.allergies           // Medical data
child.medicalConditions   // Health information
```

### EYFS 2024 Statutory Framework

**Staff Qualification Requirements:**
- Level 3 qualification tracking
- At least half of staff must hold Level 2
- Early Years Teacher/QTS recognition

**Staff-to-Child Ratios:**
- Automatic calculation based on age groups
- Real-time compliance monitoring
- Visual alerts for non-compliance

**Safeguarding:**
- DBS check validity tracking
- 3-year renewal reminders needed
- Certification expiry monitoring

### Ofsted Inspection Readiness

**Documentation:**
- Staff schedules readily available
- Ratio compliance history accessible
- Staff qualification records maintained

**Compliance Reporting:**
- Quick compliance status overview
- Filterable staff directory
- Room-by-room breakdown

### Children Act 1989

**Duty of Care:**
- Adequate staffing levels enforced
- Qualified staff assignment tracked
- Child safety through ratio compliance

**Record Keeping:**
- Enrollment dates recorded
- Attendance tracking
- Medical information securely stored

### Design Decisions for Compliance

1. **No Login Required (Per Assignment Brief)**
   - Production app would require authentication
   - Role-based access control needed
   - Audit logging for data access

2. **Local Storage Only**
   - Reduces data breach risk
   - Complies with data minimization
   - Production would need encrypted cloud backup

3. **Clear Data Labeling**
   - GDPR-sensitive fields marked in code
   - Footer text explains data protection
   - Users informed of storage policies

4. **Automatic Calculations**
   - Prevents human error in ratio compliance
   - Real-time updates ensure accuracy
   - Visual feedback guides decision-making

---

## 🧪 Testing Strategy

### Unit Testing (To Be Implemented)

**Model Tests:**
```swift
@Test("Staff-to-child ratio calculation for babies room")
func testBabiesRoomRatio() {
    let room = Room(name: "Test", ageGroup: .babies, maxCapacity: 12)
    // Add 6 present children
    #expect(room.requiredStaffCount == 2)  // 6 ÷ 3 = 2
}

@Test("DBS validity check")
func testDBSValidity() {
    let staff = StaffMember(...)
    staff.dbsCheckExpiry = Date().addingTimeInterval(86400 * 365)
    #expect(staff.isDBSValid == true)
}
```

**Business Logic Tests:**
```swift
@Test("Shift duration calculation")
func testShiftDuration() {
    let shift = Shift(
        startTime: Date(hour: 8),
        endTime: Date(hour: 16)
    )
    #expect(shift.durationHours == 8.0)
}
```

### UI Testing (To Be Implemented)

**Navigation Tests:**
- Tab switching functionality
- Sheet presentation and dismissal
- Navigation stack behavior

**Data Entry Tests:**
- Form validation
- Data persistence
- Error handling

**Interaction Tests:**
- Swipe gestures
- Toggle actions (attendance)
- Search and filter

### Manual Testing Checklist

**Staff Rota Management:**
- ✅ Add shift with all required fields
- ✅ Delete shift via swipe
- ✅ View shifts by date
- ✅ Navigate between weeks
- ✅ View staff directory
- ✅ Filter staff by role
- ✅ Compliance indicators display correctly

**Room Capacity Tracking:**
- ✅ View all rooms
- ✅ Room detail view navigation
- ✅ Toggle child attendance
- ✅ Add new child
- ✅ Occupancy percentage calculation
- ✅ Required staff calculation
- ✅ Compliance alerts display

**Edge Cases:**
- ✅ Empty state handling
- ✅ Zero occupancy rooms
- ✅ Full capacity rooms
- ✅ No staff scheduled
- ✅ Invalid time ranges (prevented)

---

## 🚀 Implementation Highlights

### SwiftUI Best Practices

**1. Environment Objects & Bindings:**
```swift
@Environment(\.modelContext) private var modelContext
@Bindable var room: Room  // Two-way binding for attendance
```

**2. Query Performance:**
```swift
@Query(sort: \StaffMember.lastName) private var allStaff: [StaffMember]
// Sorted at database level, not in memory
```

**3. Computed Properties:**
```swift
var shiftsForSelectedDate: [Shift] {
    allShifts.filter { shift in
        Calendar.current.isDate(shift.date, inSameDayAs: selectedDate)
    }
}
```

**4. Animations:**
```swift
withAnimation {
    selectedDate = newDate
}
```

### Swift Concurrency

**Model Container Setup:**
```swift
.modelContainer(for: [StaffMember.self, Shift.self, Room.self, Child.self])
```

**Error Handling:**
```swift
do {
    try modelContext.save()
    dismiss()
} catch {
    errorMessage = error.localizedDescription
    showingError = true
}
```

### Advanced Concepts

**1. Relationships:**
- Many-to-many: Staff ↔ Shifts ↔ Rooms
- One-to-many: Room → Children
- Optional relationships handled gracefully

**2. Date Handling:**
```swift
let calendar = Calendar.current
let startOfDay = calendar.startOfDay(for: date)
let weekDates = (0..<7).compactMap { ... }
```

**3. Custom Formatting:**
```swift
var timeRangeString: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return "\(formatter.string(from: startTime)) - ..."
}
```

**4. Validation:**
```swift
private var isValid: Bool {
    guard selectedStaff != nil else { return false }
    guard endTime > startTime else { return false }
    return true
}
```

---

## 🎨 UI Components Catalog

### Custom Components

**1. DayButton**
- Weekly calendar day selector
- Shows day name and number
- Selected state with blue background

**2. SummaryCard**
- Icon, value, title layout
- Color-coded by context
- Shadow for depth

**3. ShiftRow**
- Staff avatar with role color
- Time range and duration
- Compliance indicators

**4. RoomCapacityCard**
- Room icon and status badge
- Occupancy progress bar
- Staff ratio information

**5. ComplianceStatusCard**
- Shield icon with status color
- Compliance message
- Color-coded border

### SF Symbols Used
- `calendar` - Staff Rota tab
- `door.left.hand.open` - Room Capacity tab
- `person.3.fill` - Staff indicators
- `checkmark.shield.fill` - Compliance
- `figure.and.child.holdinghands` - Children
- `clock.fill` - Time/duration
- `graduationcap.fill` - Qualifications

---

## 📊 Sample Data

The app includes realistic sample data for demonstration:

**Staff Members (5):**
- Sarah Johnson (Manager, Level 6)
- Emma Thompson (Room Leader, Level 3)
- Michael Brown (Keyworker, Level 3)
- Jessica Davis (Assistant, Level 2)
- James Wilson (Keyworker, Level 3)

**Rooms (3):**
- Butterflies (Babies, 0-2 years, capacity 12)
- Caterpillars (Toddlers, 2 years, capacity 15)
- Dragonflies (Pre-school, 3-5 years, capacity 24)

**Children (7):**
- Distributed across rooms
- Mix of present and absent
- Various ages appropriate for rooms

**Shifts (4):**
- Today's schedule
- Different shift times
- Assigned to specific rooms

---

## 🔧 Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- macOS Sonoma 14.0 or later
- iOS 17.0+ simulator or device

### Installation Steps

1. **Open Xcode:**
   - Create new iOS App project
   - Name: "NurseryConnect"
   - Interface: SwiftUI
   - Storage: SwiftData

2. **Add Source Files:**
   - Copy all `.swift` files to your project
   - Ensure build target membership is set

3. **Build and Run:**
   - Select iPhone 15 Pro simulator
   - Press Cmd+R to build and run
   - Sample data loads automatically on first launch

### File Structure
```
NurseryConnect/
├── NurseryConnectApp.swift          # App entry point
├── Models.swift                      # Data models
├── ContentView.swift                 # Main tab view
├── StaffRotaView.swift              # Feature 1 main view
├── RoomCapacityView.swift           # Feature 2 main view
├── AddShiftView.swift               # Add shift form
├── StaffListView.swift              # Staff directory
├── RoomDetailView.swift             # Room detail screen
└── AddChildView.swift               # Add child form
```

---

## 🎓 Learning Outcomes Demonstrated

### 1. SwiftUI Proficiency
- Complex view hierarchies
- List views with sections
- Sheet presentations
- Tab navigation
- Form validation
- Custom components

### 2. SwiftData Mastery
- Model definition with @Model macro
- Relationships between entities
- Queries and filtering
- CRUD operations
- Data persistence

### 3. iOS Development Best Practices
- MVVM architecture
- Separation of concerns
- Computed properties for derived data
- Error handling
- User input validation

### 4. Professional Development
- Code organization and readability
- Consistent naming conventions
- Comprehensive documentation
- Sample data for testing
- Regulatory compliance awareness

---

## 🚧 Known Limitations & Future Enhancements

### Current Limitations

1. **No Backend Integration**
   - Data is local only
   - No multi-device sync
   - No real-time updates

2. **No Authentication**
   - As per assignment brief
   - Production would require login
   - No role-based access control

3. **Limited Historical Data**
   - No shift history beyond current data
   - No attendance reports
   - No compliance audit trail

4. **Basic Search**
   - Text-based only
   - No advanced filters
   - No saved searches

### Future Enhancements

**Phase 1 - Enhanced Features:**
- Push notifications for shift reminders
- Photo upload for children (with consent)
- PDF export for schedules
- iCloud sync for data backup

**Phase 2 - Compliance:**
- Audit logging
- Compliance reports for Ofsted
- DBS expiry notifications
- Training certificate upload

**Phase 3 - Integration:**
- Parent communication portal
- Financial management integration
- Catering menu coordination
- Emergency contact system

**Phase 4 - Analytics:**
- Occupancy trends
- Staff utilization reports
- Capacity forecasting
- Cost per child analysis

---

## 📝 Development Challenges & Solutions

### Challenge 1: Complex Relationships
**Problem:** Managing many-to-many relationships between Staff, Shifts, and Rooms.

**Solution:** Used SwiftData's relationship capabilities with optional binding. Each Shift references both a StaffMember and Room, allowing flexible queries.

### Challenge 2: Real-Time Ratio Calculations
**Problem:** Calculating required staff based on current attendance and age groups.

**Solution:** Implemented computed properties in the Room model that dynamically calculate based on currentOccupancy and ageGroup.

### Challenge 3: Date and Time Handling
**Problem:** Managing shifts across different dates while maintaining time accuracy.

**Solution:** Separated date selection from time pickers, then combined using Calendar components for accurate shift creation.

### Challenge 4: Compliance Indicators
**Problem:** Showing multiple compliance states (DBS, first aid, qualifications) clearly.

**Solution:** Created compact icon-based indicators with color coding and tooltip-style information.

### Challenge 5: Empty States
**Problem:** Graceful handling when no data exists.

**Solution:** Implemented dedicated empty state views with helpful messages and clear calls-to-action.

---

## 📚 References & Resources

### Apple Documentation
- [SwiftUI Framework](https://developer.apple.com/documentation/swiftui/)
- [SwiftData Framework](https://developer.apple.com/documentation/swiftdata/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### UK Regulations
- [EYFS Statutory Framework 2024](https://www.gov.uk/government/publications/early-years-foundation-stage-framework--2)
- [UK GDPR Guidance](https://ico.org.uk/for-organisations/guide-to-data-protection/)
- [Ofsted Early Years Inspection Handbook](https://www.gov.uk/government/publications/early-years-inspection-handbook-eif)
- [Children Act 1989](https://www.legislation.gov.uk/ukpga/1989/41/contents)

### Development Resources
- Swift Documentation
- iOS 17 Release Notes
- SwiftData WWDC Sessions
- SF Symbols App

---

## 👨‍💻 Development Process

### Week 1: Planning & Design
- Analyzed case study requirements
- Selected user role and features
- Created data model diagrams
- Designed UI mockups
- Researched regulatory requirements

### Week 2: Core Implementation
- Set up Xcode project
- Implemented data models
- Created basic navigation structure
- Built Staff Rota view
- Added sample data

### Week 3: Feature Completion
- Implemented Room Capacity tracking
- Created add/edit forms
- Added compliance calculations
- Refined UI design
- Implemented swipe actions

### Week 4: Polish & Testing
- Manual testing and bug fixes
- UI refinements
- Documentation writing
- Compliance report preparation
- Final testing

---

## ✅ Assignment Requirements Checklist

### Core Requirements
- [x] iOS application using SwiftUI
- [x] One user role selected (Setting Manager)
- [x] Two key features implemented
- [x] At least two screens with navigation
- [x] Data persistence (SwiftData)
- [x] No login/authentication
- [x] Professional UI design
- [x] Thorough testing
- [x] Detailed write-up
- [x] Regulatory compliance report

### Feature Requirements
- [x] Staff Rota Management fully functional
- [x] Room Capacity Tracking fully functional
- [x] Features complement each other
- [x] Appropriate for 4-week scope
- [x] Meaningful functionality

### Technical Requirements
- [x] SwiftUI components used effectively
- [x] Navigation controller implemented
- [x] Data models well-structured
- [x] Error handling implemented
- [x] Code quality and organization
- [x] Best practices followed

### Documentation Requirements
- [x] Design choices explained
- [x] Implementation decisions documented
- [x] Challenges identified
- [x] Regulatory compliance addressed
- [x] Testing approach described

---

## 🎯 Conclusion

This NurseryConnect iOS application successfully demonstrates a viable MVP for setting managers in early years childcare environments. By focusing on Staff Rota Management and Room Capacity Tracking, the app addresses critical operational needs while maintaining compliance with UK regulations including EYFS 2024, UK GDPR, and Ofsted requirements.

The implementation showcases modern iOS development practices using SwiftUI and SwiftData, with a professional interface appropriate for the sensitive childcare context. While designed as an MVP, the architecture provides a solid foundation for future enhancements and production deployment.

The complementary nature of the two features creates a cohesive user experience: effective staff scheduling enables proper room capacity management, both of which are essential for regulatory compliance and quality childcare provision.

---

**Last Updated:** March 14, 2026
**Version:** 1.0
**Platform:** iOS 17.0+
**Framework:** SwiftUI + SwiftData
