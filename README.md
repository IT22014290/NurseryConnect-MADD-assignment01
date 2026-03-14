# NurseryConnect

A digital nursery management app for early years keyworkers, built with SwiftUI and SwiftData for iOS/iPadOS.

## Overview

NurseryConnect streamlines two core workflows for early years practitioners:

- **Daily Diary** — Track children's activities, meals, sleep, wellbeing, and developmental milestones
- **Incident Reporting** — Record and manage safety incidents with full workflow tracking and parent notification

The app is built with strong regulatory compliance for UK settings (EYFS 2024, RIDDOR 2013, UK GDPR, Children Act 1989).

## Features

### Dashboard (My Children)
- View all children assigned to the keyworker
- Statistics: total assigned, present count, allergy alerts
- Search and filter by name/room or attendance status
- Allergy alert banner for present children

### Daily Diary
- 7-day date picker with chronological entry timeline
- Wellbeing summary (mood, meals, sleep, entry count)
- 8 diary entry types:
  - Check-In / Check-Out
  - Activity (with EYFS area tagging)
  - Sleep/Nap (with duration tracking)
  - Meal (food, consumption level, fluid intake)
  - Nappy
  - Wellbeing (emoji mood rating)
  - Milestone (with next steps)

### Incident Reporting
- Comprehensive incident form with auto-set immutable timestamp
- 6 incident categories: Minor Accident, First Aid, Safeguarding, Near Miss, Allergic Reaction, Medical
- Body map injury location (16 locations)
- Witness management
- RIDDOR reportable flag
- 5-stage workflow: Submitted → Manager Countersigned → Parent Notified → Parent Acknowledged
- Overdue warning for same-day notification compliance

### Child Profiles
- Personal information, medical data, dietary requirements, allergens
- EYFS information and keyworker assignment
- GDPR-aware data protection notices

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.0 |
| UI Framework | SwiftUI |
| Data Persistence | SwiftData |
| Min iOS | iOS 17 |
| Platforms | iPhone & iPad |
| Dependencies | None (Apple frameworks only) |

## Architecture

- **Pattern:** MVVM-inspired with SwiftUI state management
- **Data:** `@Query` + `@Environment(\.modelContext)` for reactive SwiftData access
- **Models:** `Child` → `DiaryEntry` + `IncidentReport` (cascade delete relationships)
- **Design System:** Centralized `NurseryTheme` (colors, typography, spacing, corner radii)
- **Reusable Components:** `NurseryCard`, status badges, allergy badges, child avatars, empty states

## Project Structure

```
NurseryConnect/
├── Models/
│   ├── Child.swift
│   ├── DiaryEntry.swift
│   └── IncidentReport.swift
├── Views/
│   ├── Dashboard/       # DashboardView, ChildCardView
│   ├── Diary/           # DailyDiaryView, AddDiaryEntryView
│   ├── Incidents/       # IncidentListView, IncidentFormView, IncidentDetailView
│   ├── Profile/         # ChildDetailView, ChildProfileView
│   └── Components/      # NurseryCard (reusable)
├── Utilities/
│   ├── NurseryTheme.swift
│   └── SampleData.swift
├── ContentView.swift
└── NurseryConnectApp.swift
```

## Regulatory Compliance

- **EYFS 2024** — Mandatory diary logging, named keyworker, developmental milestone tracking (7 learning areas)
- **RIDDOR 2013** — Digital incident forms, RIDDOR flag, Ofsted notification tracking
- **UK GDPR** — Data minimisation, Special Category Data handling, photo consent tracking
- **Children Act 1989** — Immutable audit trails, safeguarding tracking, manager countersign workflow

## Getting Started

1. Open `NurseryConnect.xcodeproj` in Xcode 15+
2. Select a simulator or device running iOS 17+
3. Build and run (`Cmd+R`)

Sample data is loaded automatically on first launch via `SampleData.swift` (3 demo children with diary entries and incidents).

## Requirements

- Xcode 15+
- iOS 17+ / iPadOS 17+
- No external dependencies
