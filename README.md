# LinguaVerse — Onboarding Frontend

> Flutter/Dart · Android · Bold & Colourful · Onboarding Flow (5 Screens)

This package contains the complete onboarding flow for LinguaVerse:
splash → language picker → avatar picker → level test → goal setter → completion.

---

## What's Inside

```
lib/
  main.dart                              ← Entry point + GoRouter
  theme/
    app_theme.dart                       ← AppColors, AppSpacing, AppRadius, AppTheme
  models/
    avatar_model.dart                    ← 10 avatars with personality data
    language_model.dart                  ← 5 languages with metadata
  onboarding/
    widgets/
      onboarding_widgets.dart            ← GradientButton, OnboardingProgress,
                                           OnboardingShell, AnimatedCheck, FloatingBadge
    screens/
      splash_screen.dart                 ← Animated logo reveal (3-phase sequence)
      language_picker_screen.dart        ← Staggered language cards with fun facts
      avatar_picker_screen.dart          ← 2-col avatar grid with intro preview
      level_test_screen.dart             ← 3-question MCQ placement + results
      goal_setter_screen.dart            ← Goal cards + reminder toggle
      onboarding_complete_screen.dart    ← Celebration screen with summary
pubspec.yaml                             ← All dependencies declared
```

---

## Prerequisites

Before you start, make sure you have completed **Day 1 of the crash course**:

- Flutter SDK installed at `C:\flutter`
- `C:\flutter\bin` in your Windows PATH
- Android Studio installed with a Pixel 7 emulator (API 34) created and running
- VS Code with the Flutter and Dart extensions installed

Verify your setup:

```bash
flutter doctor
# Every item should be green except iOS (expected on Windows)
```

---

## Step 1 — Create a Fresh Flutter Project

Open a terminal in VS Code and run:

```bash
flutter create linguaverse
cd linguaverse
```

This creates the default counter app project. You will replace the generated
files with the files from this package.

---

## Step 2 — Copy the Files

Copy the following into your project, replacing any existing files:

| Source (this package)              | Destination (your project)               |
|------------------------------------|------------------------------------------|
| `pubspec.yaml`                     | `linguaverse/pubspec.yaml`               |
| `lib/main.dart`                    | `linguaverse/lib/main.dart`              |
| `lib/theme/app_theme.dart`         | `linguaverse/lib/theme/app_theme.dart`   |
| `lib/models/`                      | `linguaverse/lib/models/`                |
| `lib/onboarding/`                  | `linguaverse/lib/onboarding/`            |

If those folders don't exist yet in your project, create them first:

```bash
mkdir lib\theme
mkdir lib\models
mkdir lib\onboarding\screens
mkdir lib\onboarding\widgets
```

---

## Step 3 — Create the Assets Folders

The app expects these asset directories to exist. Create them:

```bash
mkdir assets\animations
mkdir assets\avatars
mkdir assets\images
```

The Lottie animation files are referenced in the code but are not bundled here
(they are free downloads). The app will run without them — it falls back gracefully.
To add them later, see **Step 6**.

---

## Step 4 — Install Dependencies

With your terminal open in the `linguaverse/` folder:

```bash
flutter pub get
```

This downloads all packages declared in `pubspec.yaml`. It takes about 30–60
seconds on first run. You should see `Got dependencies!` at the end.

If you see an error about `firebase_core`, that is expected — Firebase needs a
`google-services.json` file from your Firebase project (your teammate sets this
up). For now, you can comment out the Firebase lines in `pubspec.yaml`:

```yaml
# firebase_core: ^2.27.0
# firebase_auth: ^4.17.0
# cloud_firestore: ^4.15.0
# firebase_analytics: ^10.8.0
```

Then run `flutter pub get` again.

---

## Step 5 — Run the App

Make sure your Android emulator is running (check the bottom-right of VS Code
for the device selector, or run `flutter devices` in the terminal).

```bash
flutter run
```

You should see the LinguaVerse splash screen within 10–15 seconds. The full
onboarding sequence plays automatically:

1. **Splash** — animated logo, auto-advances after ~2.8 seconds
2. **Language Picker** — tap a language, tap Continue
3. **Avatar Picker** — tap an avatar, optionally rename it, tap Continue
4. **Level Test** — answer 3 questions (or tap Skip)
5. **Goal Setter** — pick a goal, optionally set a reminder, tap Start Learning
6. **Complete** — celebration screen, tap to reach the Home placeholder

---

## Step 6 — Add Lottie Animations (Optional but Recommended)

The app is designed with Lottie animations in mind. Without them it runs fine,
but adding them takes about 5 minutes and makes a big visual difference.

1. Go to [lottiefiles.com](https://lottiefiles.com) and create a free account
2. Search for each animation below, click the result, and download the **Lottie JSON** file
3. Rename it and save it to `assets/animations/`

| File to save as           | LottieFiles search term         |
|---------------------------|---------------------------------|
| `celebrate.json`          | `confetti celebration`          |
| `correct.json`            | `checkmark success green`       |
| `wrong.json`              | `error cross shake`             |
| `waveform.json`           | `sound wave pulse`              |
| `streak.json`             | `fire flame loop`               |
| `achievement.json`        | `trophy badge unlock`           |

After adding files, hot-restart the app with `r` in the terminal (or Shift+F5
in VS Code). Lottie loads the files from assets at runtime.

---

## Step 7 — Hot Reload vs Hot Restart

While the emulator is running:

| Key | What it does |
|-----|--------------|
| `r` in terminal | **Hot reload** — updates UI changes instantly, keeps app state |
| `R` in terminal | **Hot restart** — full restart, resets all state back to splash |
| `Ctrl+S` in VS Code | Auto hot-reload on save (if Flutter extension is installed) |

Use hot reload for most UI tweaks. Use hot restart when you change `main.dart`,
routing, or state management code.

---

## How the Router Works

Data passes between screens using GoRouter's `extra` parameter — a plain
`Map<String, dynamic>`. Each screen declares what it expects:

```
/                         (no params)
  ↓ auto-navigates after 2.8s
/onboarding/language      (no params)
  ↓ context.go('/onboarding/avatar', extra: { 'languageCode': 'es' })
/onboarding/avatar        receives: languageCode
  ↓ context.go('/onboarding/level-test', extra: { languageCode, avatarId, avatarName })
/onboarding/level-test    receives: languageCode, avatarId, avatarName
  ↓ context.go('/onboarding/goal', extra: { ...+ cefrLevel })
/onboarding/goal          receives: languageCode, avatarId, avatarName, cefrLevel
  ↓ context.go('/onboarding/complete', extra: { ...+ goalId, dailyXP, reminder* })
/onboarding/complete      receives: all of the above
  ↓ context.go('/home')
/home                     (placeholder — replaced in Week 2)
```

This means if you navigate directly to `/onboarding/avatar` without passing
`extra`, the screen will receive `null` for all parameters and will show with
default/empty values. That is fine for testing individual screens.

---

## Design System Quick Reference

All design tokens are in `lib/theme/app_theme.dart`. Use these everywhere —
never hardcode colours, spacing, or border radius values directly.

```dart
// Colours
AppColors.primary        // #1A56DB — main blue
AppColors.teal           // #0E9F6E — correct / success
AppColors.orange         // #D97706 — streak / warning
AppColors.purple         // #7C3AED — achievements
AppColors.red            // #DC2626 — wrong / error

// Spacing (use these instead of raw numbers)
AppSpacing.xs  =  4.0
AppSpacing.sm  =  8.0
AppSpacing.md  = 16.0
AppSpacing.lg  = 24.0
AppSpacing.xl  = 32.0

// Border radius
AppRadius.sm   = 8px
AppRadius.md   = 12px
AppRadius.lg   = 16px
AppRadius.xl   = 24px
AppRadius.full = 999px  (fully round)

// Gradients
AppColors.gradientPrimary  // blue → purple
AppColors.gradientTeal     // teal → blue
AppColors.gradientWarm     // orange → pink
```

---

## Reusable Widgets

These are in `lib/onboarding/widgets/onboarding_widgets.dart` and can be
imported anywhere in the app:

| Widget | What it does |
|--------|-------------|
| `GradientButton` | Full-width gradient CTA with press scale animation |
| `OnboardingProgress` | Animated pill progress dots |
| `OnboardingShell` | Page wrapper: back button + progress bar |
| `AnimatedCheck` | Springy animated checkmark that pops in when visible |
| `FloatingBadge` | Small coloured pill (used for RTL, personality tags) |

---

## Connection Points for Your Teammate

These are the exact spots where AI and Firebase logic plugs in:

| What to wire | Location | Notes |
|---|---|---|
| Save language choice to Firestore | `language_picker_screen.dart` → `_continue()` | Write to `users/{uid}.learningLanguages` |
| Save avatar to Firestore | `avatar_picker_screen.dart` → `_continue()` | Write `avatarId` + `avatarName` |
| Generate level test questions via Claude | `level_test_screen.dart` → `_questions` field | Replace hardcoded `_spanishQuestions` with API call |
| Save CEFR level to Firestore | `level_test_screen.dart` → `_continue()` | Write to `users/{uid}/progress/{lang}.cefrLevel` |
| Save goal + reminder to Firestore | `goal_setter_screen.dart` → `_continue()` | Write to `users/{uid}` doc |
| Schedule push notification for reminder | `goal_setter_screen.dart` → `_continue()` | Use `flutter_local_notifications` |
| Mark onboarding complete in SharedPreferences | `onboarding_complete_screen.dart` → `_launch()` | Set `onboarding_complete = true` |
| Skip onboarding on re-launch | `main.dart` → `initialLocation` | Read SharedPreferences; if complete, go to `/home` |

---

## Common Issues

**`flutter pub get` fails with dependency conflict**
Run `flutter pub upgrade` — this resolves version constraints automatically.

**`assets/animations/` error at runtime**
Make sure the folder exists even if it is empty. Create a `.gitkeep` file
inside it so Git tracks the empty folder.

**`flutter run` says "No connected devices"**
Open Android Studio, start the Pixel 7 emulator from the Device Manager,
then re-run `flutter run`.

**Text renders as boxes (Arabic/Urdu)**
Arabic and Urdu glyphs require a font that supports them. Google Fonts' Nunito
does not include Arabic. Your teammate adds `arabic_font` or `google_fonts`
Noto Sans Arabic for RTL screens. This is a known Week 8 task.

**Hot reload shows old UI**
Some changes — especially in `main.dart`, theme, or GoRouter config —
require a hot restart (`R`), not hot reload (`r`).

---

## What Comes Next (Week 2)

Replace the `_HomeScreenPlaceholder` in `main.dart` with the real `HomeScreen`.
The crash course Day 7 code is a good starting point. The home screen needs:

- Avatar greeting row (use Hero tag `'user-avatar'` to match the profile screen)
- Streak card with animated XP bar
- Lesson card that navigates to `/lesson`
- Bottom navigation bar with 4 tabs

Add the home screen file to `lib/screens/home_screen.dart` and update the
`/home` route in `main.dart` to point to it.

---

*LinguaVerse · Semester Project · UI Developer Reference*
# trigger
