# Ledger — Who paid what. Who owes what. Done.

## What it is

Shared expenses across a group of people accumulate fast: rent, groceries, weekend trips, restaurant splits. Most tools either over-engineer the problem (payment integrations, currency conversion, receipt OCR) or under-engineer it (a shared note). Ledger sits in between — a lightweight, offline-capable mobile app that tracks who owes whom and by how much, across any number of groups. It does not move money. It does not require a paid account. It is built for housemates, travel groups, and regular friend groups who just want a clear running balance and a one-tap way to record when things are settled.

## Features

- Groups joined via a 6-character share code — no invite links, no contact sync required
- Equal-split expenses recorded against any group member as payer
- Live net balance per member, recomputed client-side on every Firestore snapshot
- One-tap settle-up: records a settlement and zeroes the balance between two members
- Activity feed showing all expenses and settlements in chronological order
- Offline-first via Firestore's built-in offline persistence — works without a connection, syncs on reconnect
- Google sign-in and email/password auth
- Light and dark theme with system-preference detection

## Screenshots

> Screenshots: add after Firebase setup.

## Architecture

Ledger uses a feature-first MVVM structure. Each feature owns its `data/`, `domain/`, and `presentation/` layers. Blocs (`flutter_bloc`) manage all presentation state. Navigation is declarative via `go_router` with shell routes for the bottom tab bar. Dependencies are wired at startup through `get_it` singletons (repositories) and factories (Blocs). All monetary values are stored and computed in integer minor units (cents) — no floating-point arithmetic anywhere in the balance logic. Balances are computed entirely client-side by `BalanceCalculator`, a pure Dart service in `features/expenses/domain/services/` that takes two lists (expenses + settlements) and returns `List<NetBalance>` with no Firebase dependency. See [`ledger_design/ARCHITECTURE.md`](../ledger_design/ARCHITECTURE.md) for the full data model, security rules, and ADRs.

```
lib/
├── app/            # MaterialApp.router entry, get_it registrations (di.dart)
├── core/           # Router, theme tokens, result type, shared widgets
├── data/           # Firebase initializer and offline-persistence config
├── features/
│   ├── auth/       # Sign-in, register, splash, onboarding — Google + email auth
│   ├── groups/     # Group list, create, join, group detail, member avatars
│   ├── expenses/   # Add expense, activity feed, BalanceCalculator, DebtSimplifier
│   ├── settlements/# Settle-up flow and settlement repository
│   └── profile/    # Profile page, settings (theme toggle), user repository
└── l10n/           # ARB strings (English only, MVP)
```

## Design system

The UI uses OKLCH-tinted neutrals pushed toward the amber hue — no pure black, no pure white. The display typeface is **Fraunces** (variable, used for amounts, screen titles, and empty-state headlines). Body copy and UI chrome use **Be Vietnam Pro** (weights 400, 500, 600). The primary color is a committed amber-ochre (`oklch(55% 0.15 68)`), used as a flat color on buttons, focus rings, and tab indicators — no purple-to-blue gradients, no gradient text, no glowing shadows in dark mode. Layout is left-aligned and list-based; there are no nested cards and no card grids. Elevation in dark mode is communicated through lightness steps, not box-shadows. See [`ledger_design/DESIGN.md`](../ledger_design/DESIGN.md) for full token tables, component patterns, and screen layouts.

## Getting started

### Prerequisites

- Flutter 3.38+ and Dart 3.10+
- A Firebase project (Spark free tier is sufficient for development)
- Node.js with the Firebase CLI installed (`npm install -g firebase-tools`), if you need to deploy Firestore rules

### Install dependencies

```sh
flutter pub get
```

### Firebase setup

**1. Install the FlutterFire CLI**

```sh
dart pub global activate flutterfire_cli
```

**2. Configure your Firebase project**

```sh
flutterfire configure --project=<your-firebase-project-id>
```

This generates three files that are gitignored and must not be committed:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

A checked-in example showing the expected shape (no real credentials) is at `lib/firebase_options.dart.example`.

**3. Enable authentication providers**

In the Firebase console under **Authentication → Sign-in method**, enable:

- Email/Password
- Google

**4. Create the Firestore database**

In the Firebase console, create a Firestore database in **Native mode**. Choose the region closest to your users.

**5. Deploy security rules**

The rules file lives at the repo root as `firestore.rules`. Deploy it with:

```sh
firebase deploy --only firestore:rules
```

### Run

```sh
flutter run
```

## Tests

Run the full test suite:

```sh
flutter test
```

Current count: **54 tests**. Coverage includes `BalanceCalculator` pure-unit tests (zero expenses, single expense, multi-member splits, settlement zeroing, rounding remainder, overpayment credit), Bloc tests with `mocktail` fakes and `bloc_test`, and widget tests for key pages with mocked Blocs and no live Firebase connection.

Static analysis:

```sh
flutter analyze
```

Should produce zero issues. The project uses `flutter_lints` with no inline suppressions.

## Project structure

```
lib/
├── app/
│   ├── app.dart              # MaterialApp.router, theme, locale wiring
│   └── di.dart               # get_it registrations for all repositories and services
├── core/
│   ├── result/               # Sealed Result<T, E> type
│   ├── router/               # GoRouter definition, shell route, redirect guards
│   ├── theme/                # Color tokens, typography scale, spacing, ThemeCubit
│   └── widgets/              # Shared UI primitives (ScrollBorderScaffold, etc.)
├── data/
│   └── firebase/             # FirebaseInitializer, offline-persistence config
├── features/
│   ├── auth/
│   │   ├── data/             # FirebaseAuthRepository
│   │   ├── domain/           # AuthRepository interface, AppUser, AuthFailure
│   │   └── presentation/     # AuthBloc, SignInPage, RegisterPage, SplashPage, OnboardingPage
│   ├── groups/
│   │   ├── data/             # FirestoreGroupRepository
│   │   ├── domain/           # GroupRepository interface, Group, GroupMember
│   │   └── presentation/     # GroupBloc, GroupDetailBloc, UserBalancesBloc, pages, MemberAvatar
│   ├── expenses/
│   │   ├── data/             # FirestoreExpenseRepository
│   │   ├── domain/           # ExpenseRepository interface, Expense, BalanceCalculator, DebtSimplifier
│   │   └── presentation/     # ExpenseBloc, AddExpensePage, ActivityFeedView, ExpenseListView
│   ├── settlements/
│   │   ├── data/             # FirestoreSettlementRepository
│   │   ├── domain/           # SettlementRepository interface, Settlement
│   │   └── presentation/     # SettlementBloc, SettleUpPage
│   └── profile/
│       ├── data/             # FirestoreUserRepository
│       ├── domain/           # UserRepository interface, UserProfile
│       └── presentation/     # ProfileBloc, ProfilePage, SettingsPage
└── l10n/                     # app_en.arb, generated AppLocalizations
```

## Roadmap

Items explicitly deferred from MVP:

- Percentage and custom splits (the domain accepts a `SplitStrategy` — the extension point is additive, no Bloc changes required)
- Push notifications via FCM (requires a Cloud Function trigger on expense writes; the data model already supports it)
- Receipt scanning
- Currency conversion (amounts are stored as minor units; display currency is hardcoded to the group creator's locale in MVP)
- Group deletion and member removal (cascading Firestore deletes not yet specified)
- Firebase App Check
- Integration tests against the Firebase Emulator Suite

## License

MIT — see `LICENSE`.

## Acknowledgements

Built with [Flutter](https://flutter.dev) and [Firebase](https://firebase.google.com). Typography: [Fraunces](https://fonts.google.com/specimen/Fraunces) and [Be Vietnam Pro](https://fonts.google.com/specimen/Be+Vietnam+Pro), both served via Google Fonts.
