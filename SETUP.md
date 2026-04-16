# HydroTrack — Xcode Setup Guide

Complete step-by-step instructions for creating the Xcode project and wiring up all source files.

---

## 1. Prerequisites

| Requirement | Version |
|---|---|
| Xcode | 16+ (iOS 17 SDK minimum; iOS 26 SDK for Liquid Glass) |
| Deployment Target | iOS 17.0 |
| Apple Developer Account | Paid ($99/yr) — required for App Groups + WidgetKit on device |

---

## 2. Create the Xcode Project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Fill in:
   - **Product Name:** `HydroTrack`
   - **Bundle Identifier:** `com.yourname.hydrotrack` *(replace with your actual identifier)*
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Minimum Deployment:** iOS 17.0
4. Save the project into the `hydro-track/` folder (this repo root)

---

## 3. Add the Widget Extension Target

1. **File → New → Target**
2. Choose **Widget Extension**
3. Fill in:
   - **Product Name:** `HydroTrackWidget`
   - **Bundle Identifier:** `com.yourname.hydrotrack.widget`
   - **Include Configuration Intent:** ❌ (uncheck — we use `StaticConfiguration`)
4. When prompted "Activate HydroTrackWidget scheme?", click **Activate**

---

## 4. Configure App Groups (critical for data sharing)

Both targets must share the same App Group so the widget can read water logs.

### Main App target:
1. Select the `HydroTrack` target → **Signing & Capabilities**
2. Click **+ Capability** → add **App Groups**
3. Click **+** and add: `group.com.yourname.hydrotrack` *(must match `HydroDataStore.appGroupID`)*

### Widget Extension target:
1. Select the `HydroTrackWidget` target → **Signing & Capabilities**
2. Add **App Groups** → add the same group: `group.com.yourname.hydrotrack`

> ⚠️ **Update the App Group ID in code:** Open `Shared/DataStore/HydroDataStore.swift` and change:
> ```swift
> static let appGroupID = "group.com.hydrotrack.app"
> ```
> to your actual group identifier.

---

## 5. Add Capabilities to Main App

In the `HydroTrack` target → **Signing & Capabilities**, add:

| Capability | Why |
|---|---|
| **Push Notifications** | Required for `UNUserNotificationCenter` |
| **Background Modes** | Check *Background fetch* (for notification rescheduling) |

---

## 6. Add Source Files to Targets

### Files to add to BOTH targets (main app + widget):

These files are in `Shared/` and must be included in both the `HydroTrack` and `HydroTrackWidget` targets:

| File | Path |
|---|---|
| `UserProfile.swift` | `Shared/Models/` |
| `WaterLog.swift` | `Shared/Models/` |
| `HydroDataStore.swift` | `Shared/DataStore/` |
| `Color+Theme.swift` | `Shared/Extensions/` |
| `Date+Extensions.swift` | `Shared/Extensions/` |

**How to add to both targets:**
- Drag the `Shared/` folder into the Xcode project navigator
- In the file addition dialog, check **both** `HydroTrack` and `HydroTrackWidget` under "Add to targets"

Also add `NotificationService.swift` to both targets (the widget intents reschedule notifications).

### Files to add to the MAIN APP target only:

Add all files in:
- `HydroTrack/` (recursively — all `.swift` files)

### Files to add to the WIDGET EXTENSION target only:

Add all files in:
- `HydroTrackWidget/` (recursively — all `.swift` files)

> **Tip:** After dragging, select each file in the navigator and check the **Target Membership** in the File Inspector (right panel) to confirm correct assignment.

---

## 7. Configure URL Scheme (for widget deep links)

1. Select the `HydroTrack` target → **Info** tab
2. Under **URL Types**, click **+**
3. Set:
   - **Identifier:** `com.yourname.hydrotrack`
   - **URL Schemes:** `hydrotrack`

This enables the custom amount buttons on the lock screen widget to open the app.

---

## 8. Swift Package / Framework Dependencies

No external packages required. All dependencies are first-party Apple frameworks:

| Framework | Used in |
|---|---|
| `SwiftUI` | All UI |
| `WidgetKit` | Widget extension |
| `AppIntents` | Interactive widget buttons |
| `UserNotifications` | Hydration reminders |
| `Charts` | Weekly bar chart (iOS 16+) |

All are pre-linked — no Package.swift additions needed.

---

## 9. Build Settings Checklist

| Setting | Value |
|---|---|
| iOS Deployment Target (both targets) | 17.0 |
| Swift Language Version | Swift 5 |
| Widget extension's `NSExtensionPrincipalClass` | Should be auto-set by Xcode to `$(PRODUCT_MODULE_NAME).HydroTrackWidgetBundle` |

---

## 10. Info.plist Additions (Main App)

Add these keys to your `HydroTrack/Info.plist`:

```xml
<!-- Privacy string shown when requesting notification permission -->
<key>NSUserNotificationsUsageDescription</key>
<string>HydroTrack sends reminders to keep you on track with your daily water goal.</string>
```

---

## 11. App Store Compliance Notes

- **Privacy Nutrition Label:** No user data leaves the device. Select "Data Not Collected" in App Store Connect.
- **Permissions used:** Local Notifications only (no camera, location, contacts, health data).
- **Minimum iOS:** 17.0 ensures interactive widget support (AppIntents + WidgetKit buttons).
- **Liquid Glass:** Automatically activates on iOS 26+ via `#available` check. Falls back to `ultraThinMaterial` on iOS 17–25 with no code changes required.
- **Age Rating:** 4+ (no objectionable content).

---

## 12. Project File Structure Summary

```
hydro-track/
├── Shared/
│   ├── Models/
│   │   ├── UserProfile.swift        ← Add to BOTH targets
│   │   └── WaterLog.swift           ← Add to BOTH targets
│   ├── DataStore/
│   │   └── HydroDataStore.swift     ← Add to BOTH targets
│   └── Extensions/
│       ├── Color+Theme.swift        ← Add to BOTH targets
│       └── Date+Extensions.swift   ← Add to BOTH targets
│
├── HydroTrack/                      ← Main app target only
│   ├── HydroTrackApp.swift
│   ├── ContentView.swift
│   ├── Services/
│   │   └── NotificationService.swift ← Add to BOTH targets
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── Steps/
│   │       ├── NameStepView.swift
│   │       ├── WeightStepView.swift
│   │       ├── SexStepView.swift
│   │       ├── ActivityStepView.swift
│   │       ├── BottleSizeStepView.swift
│   │       └── SummaryStepView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── ProgressRingView.swift
│   │   └── QuickLogView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   ├── CalendarGridView.swift
│   │   └── WeeklyBarChart.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       └── WaterBottleIcon.swift
│
└── HydroTrackWidget/                ← Widget extension target only
    ├── HydroTrackWidgetBundle.swift
    ├── HydroTrackWidget.swift
    ├── Intents/
    │   ├── LogBottleIntent.swift
    │   └── LogCustomAmountIntent.swift
    └── Views/
        ├── LockScreenWidgetView.swift
        └── HomeScreenWidgetView.swift
```

---

## 13. First Run

1. Build and run on a physical device (widgets require a real device to test)
2. Long-press the lock screen → add widget → find "HydroTrack" → choose the rectangular widget
3. Complete onboarding in the app first — the widget shows placeholder data until a profile exists
4. Allow notifications when prompted

---

## Quick Troubleshooting

| Symptom | Fix |
|---|---|
| Widget shows placeholder data | Verify App Group IDs match exactly in both targets |
| `HydroDataStore` not found in widget | Confirm `HydroDataStore.swift` is in widget target membership |
| Tapping bottle icon does nothing | Ensure `AppIntents` framework is linked to widget target |
| Liquid Glass not showing | Test on iOS 26 simulator or device; falls back silently on iOS 17–25 |
| Notifications not firing | Check notification permission in Settings → HydroTrack |
