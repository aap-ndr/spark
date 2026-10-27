# Spark - A Neurodiversity-Affirming Community App for ADHD Girls

*What does an app designed by and for ADHD girls look like when belonging matters as much as productivity?* 

Spark is a native iOS app for empowering ADHD teen girls. Explore Spark Circles for affirmations and body doubling on tasks with trusted friends, small-step Quests, Focus Realms with music, Feelings Check, Period Tracker, Neurodiversity Corner for strengths-based understanding, Discover Opportunities for camps and programs, and more. 

Built by a 2e/ADHD student with neuromuscular deficits in her right hand, accessibility is built into Spark’s interface, with special care for hand mobility, sensory overwhelm, and cognitive access. Spark was 1 of 5 selected in a highly competitive national challenge for live stage demo at #TodayAtApple (San Francisco Union Square) by Kode With Klossy and Apple mentors. https://www.youtube.com/watch?v=REu42dOHBcc. Lived experience, feedback from ADHD girls, and the Apple Union Square demo shaped Spark v1.0.

The app is built with SwiftUI. Personal data stays on the device.

## v1.0 Features

**Home** opens with a time-based greeting, a daily affirmation, and a Coming up list that gathers quest reminders, events, cycle predictions, and more. From here you can open Spark Circle, Discover Opportunities, and the toolkit.

**Spark Circle** is an invite-only space for friends to help with body doubling on tasks, sending short encouragements, and sharing quests. Circles and messages live on the device. 

**Quests** break a bigger goal into small steps. Checking off steps earns Sparks. Quests can carry reminders and be shared with a circle.

**Focus** is a set of themed focus realms — Enchanted Forest, Library, Ocean, Starlit Sky, and Clouds — with 10, 15, 25, and 45 minute sessions, a countdown ring, and gentle encouragement. Completed time is tracked.

**Feelings** is a non-clinical check-in: choose a feeling, set an intensity, and add an optional note. A recent list and a 7-day mood strip show how the week has felt. Calming tools include box breathing and a 5-4-3-2-1 grounding exercise.

**Cycle** is for period tracking and a simple prediction of the next expected start. Reminders are added automatically to the Coming Up list.

**Find My Things** — a place to note where everyday items were last put down

**Learn about ADHD** — a Neurodiversity Corner, primers on ADHD strengths, how it presents differently in girls, youth-facing resources, and more.

**Discover Opportunities** is a filterable list of camps, clubs, competitions, and similar programs. Favorites are saved on the device. Links open in an in-app browser.

**Me** allows customization for an inclusive profile: display name, a short bio, likes and dislikes, an illustrated avatar with several choices for skin color, hair, and accessories, and app skins, notification settings, and a replayable tour of the app.

The toolkit also includes:
- **Music** — a built-in library with a mini player that can play alongside a focus realm
- **Events** — birthdays, exams, and other dates, with optional reminders
- **Timer** — a standalone timer separate from Focus
- **Reminders** — one-time, every day, or selected weekdays, with custom categories

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

## Architecture and Design
![](https://github.com/aap-ndr/spark/blob/main/Spark%20App%20-%20Architecture%20and%20Design.png)

## Skins

The Me tab can switch the app’s color wash among Spark, Enchanted Forest, Ocean Calm, Starlit Sky, and Cloud Kingdom. The interface stays in light appearance.

## Accessiblity
The build follows Apple Human Interface Guidelines and universal-design aims. ADHD in girls often includes load from sound, light, motion, cluttered screens, and too many choices at once. Spark is designed so the product does not add another wave of input. The home screen uses a cream base, soft color washes, and a small toolkit grid instead of a dense dashboard. Focus Realms let the user choose the environment: Enchanted Forest, Cozy Library, Ocean Calm, Starlit Sky, or Clouds, each with its own palette, particles, and audio, so someone who is overstimulated can pick a quieter or steadier scene. Feelings tools treat being overwhelmed as a first-class state and offer paced breathing and grounding.

Reduce Motion is implemented in the SwiftUI codebase. When iOS Reduce Motion is on, home fade-ins appear immediately; the logo does not breathe or sparkle; primary buttons do not spring; the Focus tab icon does not pulse; realm particles simplify; music-list stagger is off; the grounding modal uses opacity only; breathing phase changes do not use long ease animations; the timer ring does not animate; quest confetti is skipped. Haptics are optional and not required to complete a task. The app currently locks to light mode, which keeps contrast predictable; Dark Mode is not yet offered.

### VoiceOver and structure
VoiceOver coverage is on Quests, Focus, Feelings, Timer, Music, Reminders, Events, Cycle, Find My Things, Circle, Opportunities, Learn, and Me. Accessibility modifiers appear across about 50 Swift files (200+ uses). Icon-only controls have spoken labels (Close, Save, Back to Home, play/pause, timer and focus controls, invite/copy). Time is spoken as durations. Circle messages, mood-strip days, feelings banners, opportunities, and Learn links have descriptive labels; external links announce that they open in an in-app browser. Hints and values cover quest progress (“3 of 5 steps done”), step state, bookmarks, and reminder on/off. Selected traits mark chips and pickers (moods, realms, durations, sounds, skins, filters). Decorative gradients and redundant emojis are hidden from VoiceOver; related elements are combined so a screen reader hears one coherent item.

### Cognitive access
Quests use short steps and templates (study, tidy, get ready). Focus sessions are 10, 15, 25, or 45 minutes. Mood check-ins use plain words and emojis. Language is strengths-based. Spark Circles (community) are invite-only.

### Accessibility features to be implemented 
Dynamic Type (type uses fixed sizes), Increase Contrast and Differentiate Without Color, Reduce Motion on remaining animations, Formal WCAG 2.2 AA audit and usability testing. 

