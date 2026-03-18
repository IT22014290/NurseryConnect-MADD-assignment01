# NurseryConnect

A mobile app for early years keyworkers to manage daily childcare records and incident reports, built with SwiftUI and SwiftData for iOS/iPadOS.

---

## Assignment Topic

### What is the App?

NurseryConnect is an iOS app designed for use in UK nursery settings. It gives keyworkers a single, structured tool to log everything that happens with their assigned children throughout the day — from meals and naps to developmental milestones and safety incidents — replacing paper-based records and disconnected spreadsheets.

The app is built around regulatory compliance: every feature maps to a specific legal obligation under EYFS 2024, RIDDOR 2013, UK GDPR, or the Children Act 1989.

### Who are the Users?

The primary users are **early years keyworkers** — childcare practitioners in UK nursery or pre-school settings who are each assigned a small group of children (typically 3–4 under-twos, or 4–6 two-year-olds) they are responsible for throughout the day.

Secondary users include **nursery managers**, who review and countersign incident reports before they are sent to parents, and **parents/guardians**, who are notified of incidents and must acknowledge them through the workflow.

### Core Functionality and Why it is Useful

UK nurseries are legally required to maintain detailed daily records for every child (EYFS 2024, Section 3) and to report accidents and incidents with immutable timestamps and a documented parent-notification trail (RIDDOR 2013). In practice, most settings still do this on paper — which is slow, error-prone, and difficult to audit.

NurseryConnect solves this with two core workflows:

**1. Daily Diary** — keyworkers log every significant event for each assigned child: arrival and departure, activities linked to EYFS learning areas, sleep duration, meals and fluid intake, nappy changes, mood/wellbeing, and developmental milestones. The 7-day date picker gives an instant timeline view, and the wellbeing summary surfaces mood, meal count, and sleep at a glance.

**2. Incident Reporting** — when an accident or concern occurs, keyworkers fill in a structured form with an auto-set, immutable timestamp (EYFS/RIDDOR requirement), body map for injury location, severity rating, RIDDOR flag, and witness details. The report then moves through a 5-stage workflow (Draft → Awaiting Manager Review → Approved → Parent Acknowledged → Closed) with overdue warnings if same-day parent notification has not been completed.

Together these features give nurseries a legally defensible, auditable digital record system that saves keyworkers time and ensures nothing is missed.

---

## Features

### Dashboard (My Children)
- All children assigned to the logged-in keyworker
- Live statistics: total assigned, present count, allergy alert count
- Search by name/room, filter by attendance status
- Prominent allergy alert banner when any present child has an allergen on record

### Daily Diary
- 7-day scrollable date picker
- Wellbeing summary: mood emoji, meal count, sleep duration, entry count
- 8 diary entry types:
  - **Check-In / Check-Out** — arrival and collection, with who brought/collected the child
  - **Activity** — tagged with one of the 7 EYFS areas of learning
  - **Sleep/Nap** — start/end time, sleep position (safe-sleep SIDS guidance)
  - **Meal** — food offered, consumption level (All / Most / Half / Little / None / Refused), fluid intake
  - **Nappy** — wet / dirty / both, concerns, cream applied
  - **Wellbeing** — emoji mood rating (Happy, Content, Unsettled, Upset, Poorly)
  - **Milestone** — developmental achievement with next steps

### Incident Reporting
- Structured form with auto-set immutable timestamp (cannot be edited — EYFS/RIDDOR compliance)
- 6 incident categories: Minor Accident, Accident Requiring First Aid, Safeguarding Concern, Near Miss, Allergic Reaction, Medical Incident
- Body map: 16 body locations for injury mapping
- Witness tracking
- RIDDOR reportable flag and Ofsted notification tracking
- 5-stage workflow: Draft → Awaiting Manager Review → Approved (Parent Notified) → Parent Acknowledged → Closed
- Overdue banner when same-day parent notification has not been completed

### Child Profiles
- Personal info, medical conditions, dietary requirements, allergen badges
- EYFS information and named keyworker
- Photo consent tracking with GDPR compliance notice

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.0 |
| UI Framework | SwiftUI |
| Data Persistence | SwiftData |
| Minimum iOS | iOS 17 |
| Platforms | iPhone & iPad |
| External Dependencies | None |

---

## Architecture

- **Pattern:** MVVM-inspired with SwiftUI state management (`@State`, `@Bindable`, `@Environment`)
- **Data access:** `@Query` + `@Environment(\.modelContext)` for reactive SwiftData reads/writes
- **Data model:** `Child` → `DiaryEntry` + `IncidentReport` (cascade delete)
- **Design system:** Centralized `NurseryTheme` (brand colors, typography, spacing, corner radii)
- **Navigation:** `TabView` at root (My Children | Incidents), `NavigationStack` + `TabView` within child detail (Diary | Profile | Incidents)

---

## Project Structure

```
NurseryConnect/
├── Models/
│   ├── Child.swift               # Child data model
│   ├── DiaryEntry.swift          # Diary entry model (all 8 entry types)
│   └── IncidentReport.swift      # Incident model with workflow and compliance fields
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   └── ChildCardView.swift
│   ├── Diary/
│   │   ├── DailyDiaryView.swift
│   │   └── AddDiaryEntryView.swift
│   ├── Incidents/
│   │   ├── IncidentListView.swift
│   │   ├── IncidentFormView.swift
│   │   └── IncidentDetailView.swift
│   ├── Profile/
│   │   ├── ChildDetailView.swift
│   │   └── ChildProfileView.swift
│   └── Components/
│       └── NurseryCard.swift
├── Utilities/
│   ├── NurseryTheme.swift         # Design system
│   └── SampleData.swift          # Demo data (auto-loads on first launch)
├── ContentView.swift              # Root tab navigation
└── NurseryConnectApp.swift        # App entry point and SwiftData container
```

---

## Regulatory Compliance

| Regulation | How the App Addresses It |
|---|---|
| EYFS 2024 | Mandatory diary logging, named keyworker assignment, 7 EYFS learning area tags, developmental milestone recording |
| RIDDOR 2013 | Immutable incident timestamps, RIDDOR reportable flag, Ofsted notification field |
| UK GDPR | Data minimisation (keyworkers see only assigned children), photo consent tracking, special category data notices |
| Children Act 1989 | Immutable audit trail, safeguarding concern category, manager countersign before parent notification |

---

## Getting Started

1. Open `NurseryConnect.xcodeproj` in Xcode 15+
2. Select a simulator or device running iOS 17+
3. Build and run (`Cmd+R`)

Sample data (3 demo children with diary entries and incidents) loads automatically on first launch via `SampleData.swift`.

## Requirements

- Xcode 15+
- iOS 17+ / iPadOS 17+
- No external dependencies
