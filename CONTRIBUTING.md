# Contributing to FitOverlayCore

Thanks for your interest in contributing! This document explains how the repo is laid out
and what we expect from changes.

## Repository layout

| Path | What it is | Builds on |
| --- | --- | --- |
| `Backend/` | Vapor 4 API (auth, licensing, app launch) | Linux, macOS |
| `Backend/DataTypes/` | DTOs shared between backend & clients | Linux, macOS, iOS |
| `FitOverlayKit/` | Pure-Swift FIT/overlay engine | Linux, macOS, iOS (anything) |
| `App/FitOverlayApp/` | macOS app (Xcode project) | macOS |
| `App/FitOverlayAppShared/` | Shared client screens & logic | macOS, iOS |
| `App/FitOverlayUIKit/` | Design system / UI components | macOS, iOS |

## Ground rules

1. **Keep `FitOverlayKit` platform-agnostic.** Only the Swift standard library and
   Foundation are allowed. No SwiftUI/AppKit/UIKit/AVFoundation/CoreLocation — rendering
   and media APIs live in the host apps.
2. **`Backend` and `FitOverlayKit` must build and test on Linux.** CI enforces this on
   every pull request.
3. **Tests ride along.** New services, parsers, and models come with `*UnitTests` (no
   external dependencies) and, where appropriate, `*IntegrationTests` (may use Postgres).
   CI filters on those suffixes.
4. **Lint & format.** We use SwiftLint (`.swiftlint.yml`) and SwiftFormat (`.swiftformat`):

   ```bash
   npm run lint
   npm run format
   ```

5. **Documentation comments** on public types and members, in the same style as the
   existing code.

## Development quick start

```bash
# Backend
cd Backend
cp .env.example .env.local
docker compose up -d postgres
swift run App serve --env local

# Engine
cd FitOverlayKit && swift test

# Clients
open App/FitOverlayApp/FitOverlayApp.xcodeproj
```

## Pull requests

- Branch from `main`, keep PRs focused on one logical change.
- Make sure `swift test` passes in `Backend/` (unit tests at minimum) and `FitOverlayKit/`.
- Fill in a clear description: what changed, why, and how it was tested.
