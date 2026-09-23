# HydroTrack

**A water tracker you can log from your Lock Screen without opening the app.**

Native iOS · SwiftUI · WidgetKit · App Intents

## Why

Water trackers fail for one reason: logging is annoying, so you stop. HydroTrack turns your daily goal into bottles and lets you log one with a single tap from the Home Screen or Lock Screen.

## What it does

- **Personal goal** from a quick six step onboarding (weight, activity level, bottle size)
- **Today view** with an animated progress ring and bottles that fill as you log
- **Interactive widgets** for the Home Screen and Lock Screen. Tap to log a bottle or a set amount
- **History** with a month calendar and a weekly chart
- **Smart reminders** based on whether you're on pace for the day

## Design decisions

- **Your goal is bottles, not ounces.** Nobody thinks in ounces. Bottle icons fill from the bottom using a masked SF Symbol, so progress is something you can see.
- **Logging where you already are.** App Intents power the widget buttons, and every log refreshes widgets and reschedules reminders.
- **Liquid Glass on iOS 26** with an `ultraThinMaterial` fallback on older versions.
- **Motion with a job.** The progress ring animates on every log and onboarding steps use spring transitions.

## Run it

1. Open `HydroTrack.xcodeproj` in Xcode
2. Add a Widget Extension target and point it at the files in `HydroTrackWidget/`
3. Turn on the App Group `group.com.hydrotrack.app` for both the app and the widget
4. Build and run

[SETUP.md](SETUP.md) walks through the widget setup step by step.

## Stack

SwiftUI, WidgetKit, App Intents, Swift Charts, UserNotifications, App Group storage.
