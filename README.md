# NurseryConnect

A SwiftUI iOS application for nursery management, built as Assignment 1 for the Mobile App Design & Development (MADD) module.

## Overview

NurseryConnect is a role-based nursery management platform that connects all stakeholders of a childcare setting — staff, parents, drivers, catering, and marketing — within a single app. Each user role gets a tailored dashboard and feature set relevant to their responsibilities.

## Features by Role

| Role | Key Features |
|------|-------------|
| **Administrator** | System configuration, compliance management, children registry |
| **Setting Manager** | Attendance overview, incident queue, reports |
| **Keyworker** | Child profiles, diary entries, attendance, incident reporting |
| **Room Leader** | Room-level oversight, staff supervision dashboard |
| **Driver** | Transport manifest, GPS tracking, school collections |
| **Parent / Guardian** | Child diary, GPS tracking, in-app messaging |
| **Catering Staff** | Meal planning, allergen alerts, stock management |
| **Marketing Coordinator** | Content calendar, media library, GDPR-safe content |

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Persistence:** SwiftData
- **Architecture:** Observable state (`@Observable`) with environment injection
- **Minimum Platform:** iOS (Xcode project)

## Project Structure

```
NurseryConnect/
├── NurseryConnectApp.swift       # App entry point, SwiftData container setup
├── ContentView.swift             # Root view
├── Models/
│   └── DataModels.swift          # SwiftData models & AppState
├── Views/
│   ├── RoleSelectionView.swift   # Role picker on launch
│   ├── Admin/                    # Administrator views
│   ├── Manager/                  # Setting Manager views
│   ├── Keyworker/                # Keyworker views
│   ├── RoomLeader/               # Room Leader views
│   ├── Driver/                   # Driver views
│   ├── Parent/                   # Parent / Guardian views
│   ├── Catering/                 # Catering Staff views
│   ├── Marketing/                # Marketing Coordinator views
│   └── Shared/                   # Reusable components, messaging
└── Utilities/
    ├── SampleData.swift           # Seed data for development
    └── Theme.swift                # App-wide colour & style tokens
```

## Getting Started

1. Clone the repository.
2. Open `NurseryConnect.xcodeproj` in Xcode.
3. Select a simulator or connected device running iOS 17+.
4. Build and run (`Cmd + R`).

On first launch the app seeds sample data automatically. Select any role from the role selection screen to explore that role's dashboard.

## Author

**Thevin Samishka H T** — IT22014290  
Y4S2 · Mobile App Design & Development · Assignment 1
