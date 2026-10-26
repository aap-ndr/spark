# Spark

Spark is a native iOS app for ADHD girls and gender-expansive youth. It treats focus, feelings, routines, and friendships as one supportive place, with a warm, strengths-based tone.

The app is built with SwiftUI. Personal data stays on the device.

## Features

**Home** opens with a time-based greeting, a daily affirmation, and a Coming up list that gathers nearby events, cycle predictions, quest reminders, and enabled reminders. From here you can open Spark Circle, Discover Opportunities, and the toolkit.

**Quests** break a bigger goal into small steps. Checking off steps earns Sparks. Quests can carry reminders and be shared with a circle.

**Focus** is a set of themed focus realms — Enchanted Forest, Library, Ocean, Starlit Sky, and Clouds — with 10, 15, 25, and 45 minute sessions, a countdown ring, and gentle encouragement. Completed time is tracked.

**Feelings** is a non-clinical check-in: choose a feeling, set an intensity, and add an optional note. A recent list and a 7-day mood strip show how the week has felt. Calming tools include box breathing and a 5-4-3-2-1 grounding exercise.

**Me** holds the profile: display name, a short bio, likes and dislikes, an illustrated avatar, app skins, notification settings, and a replayable tour of the app.

The toolkit also includes:

- **Cycle** — period tracking and a simple prediction of the next expected start
- **Music** — a built-in library with a mini player that can play alongside a focus realm
- **Events** — birthdays, exams, and other dates, with optional reminders
- **Timer** — a standalone timer separate from Focus
- **Find My Things** — a place to note where everyday items were last put down
- **Reminders** — one-time, every day, or selected weekdays, with custom categories
- **Learn about ADHD** — a short Neurodiversity Corner, with resource links opened inside the app

**Spark Circle** is an invite-only space for sending short encouragements and sharing quests. Circles and messages live on this device. Seeded members can reply with a small set of warm demo responses.

**Discover Opportunities** is a filterable list of camps, clubs, competitions, and similar programs. Favorites are saved on the device. Links open in an in-app browser.

## Getting started

Requirements:

- Xcode with the iOS 26.5 SDK
- An iPhone or simulator running iOS 26.5 or later

Open `spark.xcodeproj`, choose a run destination, and run the `spark` scheme. On first launch, enter a display name of at least two characters, choose an avatar, and confirm you are 13 or older. After that, the app opens on Home.

Notifications for quests, events, reminders, and cycle predictions need permission from iOS. You can change that later from the Me tab.

## Project layout

```
spark.xcodeproj          Xcode project
spark/
  sparkApp.swift         App entry point and store setup
  ContentView.swift      Onboarding or main tabs
  DesignSystem/          Colors, type, spacing, skins, haptics
  Components/            Shared controls and avatar views
  Features/              Screen content for each feature
  Models/                Codable models
  State/                 Observable stores
  Services/              Notifications, audio, upcoming items, opportunities
  Navigation/            Tabs and routes
  Views/                 SwiftUI screens
  Assets.xcassets        App icon and accent color
```

`sparkApp` creates one store per feature and passes them through the SwiftUI environment. Each store saves its own data with `UserDefaults`. Illustrated avatars are fetched when needed and cached.

## Skins

The Me tab can switch the app’s color wash among Spark, Enchanted Forest, Ocean Calm, Starlit Sky, and Cloud Kingdom. The interface stays in light appearance.
