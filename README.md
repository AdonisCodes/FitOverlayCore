# FitOverlayCore

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg?style=flat&logo=swift)](https://swift.org/)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey.svg)](https://developer.apple.com/)
[![Vapor](https://img.shields.io/badge/Vapor-4-2D68F7.svg?logo=vapor)](https://vapor.codes/)

FitOverlayCore is the core infrastructure powering **FitOverlay** — an easy-to-use fitness
overlay app that renders workout data from `.FIT` files (speed, heart rate, power, cadence,
elevation, map) over action-cam video, with a drag-and-drop layout editor. One licence,
one-time lifetime payment across platforms; subscriptions supported.

This monorepo is a full fork of
[AutomaInfraCore](https://github.com/GetAutomaApp/AutomaInfraCore), renamed to FitOverlay,
with the FIT/overlay engine, licensing, and a macOS app added on top. It contains everything
needed to run the FitOverlay platform, including the server-side components and shared
client libraries.

## 📦 Project Structure

The repository is organized into several main components:

### Backend (`/Backend`)
The server-side component built with Vapor 4, providing:
- RESTful API endpoints
- Database models and migrations (PostgreSQL / Fluent)
- Authentication and authorization (phone number + one-time code, JWT access/refresh tokens)
- Profile generation pipeline (OpenAI image generation → Tigris storage) and transactional
  messaging (SNS), executed through Temporal workflows and a dedicated worker command
- Licence keys, cross-platform device activations, and purchase webhook stubs (Stripe / App Store)
- Integration with external services (Twitter, OpenAI, RSS feeds, web scraping, Textract)
- Metrics and monitoring (Prometheus, Loki, Grafana, Tempo)

### FitOverlayKit (`/FitOverlayKit`)
The FIT/overlay engine as a **separate, pure Swift package** with no Apple-only frameworks,
so it can be embedded in any app — including Windows or WebAssembly builds later:
- `FitParser` — binary `.FIT` decoding (header, CRC, record messages)
- `FitDataModel` — activity samples/tracks, interpolation, smoothing
- `OverlayLayout` — serialisable overlay documents: widgets with position/size/style/data bindings, templates
- `OverlayTimeSync` — data-to-video time synchronisation
- `OverlayRender` — per-frame, platform-agnostic draw commands

### App (`/App`)
Contains the client-side applications and shared components:
- **FitOverlayApp**: Main iOS application (ported from the reference client)
- **FitOverlayMacApp**: macOS application built on the same shared packages
- **FitOverlayAppShared**: Shared code between platforms
  - Network layer
  - Data models
  - Business logic
- **FitOverlayUIKit**: Shared UI components and theming

### DataTypes (`/Backend/DataTypes`)
Shared data models and type definitions used across the application.

## 🚀 Features

- **Cross-Platform Support**: Native applications for both iOS and macOS; engine and backend build on Linux
- **Modern Architecture**: Built with Swift 6.2 and Swift Concurrency
- **Scalable Backend**: Powered by Vapor 4 with PostgreSQL and Temporal workers
- **Licensing Built In**: Lifetime licences & subscriptions, device activations across platforms
- **AI Integration**: OpenAI integration for profile generation
- **Monitoring**: Built-in metrics and logging

## 🛠️ Technical Stack

- **Backend**: Swift 6.2, Vapor 4, PostgreSQL, Temporal
- **Engine**: Pure Swift + Foundation (Linux/Windows/WASM-friendly)
- **iOS/macOS**: SwiftUI
- **Infrastructure**: Docker, AWS (via Soto), Tigris (S3-compatible storage)
- **Hosting**: Fly.io
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus, Loki, Grafana, Tempo
- **Dependencies**:
  - Vapor ecosystem (Fluent, Leaf, JWT)
  - Alamofire for networking
  - OpenAI SDK
  - TwitterAPIKit
  - SwiftSoup for HTML parsing
  - swift-temporal-sdk for workflows

## 🔧 Setup

### Backend (local)

```bash
cd Backend
cp .env.example .env.local        # adjust secrets as needed
npm run compose:build-and-up      # full stack: API, worker, Postgres, Temporal, observability
# or natively: swift run App serve --env local
# Temporal worker: swift run App temporal-worker
```

### Engine

```bash
cd FitOverlayKit
swift build && swift test         # works on Linux and macOS
```

### Apps

- iOS: open `App/FitOverlayApp/FitOverlayApp.xcodeproj`, scheme `IOS`
- macOS: open `App/FitOverlayMacApp/FitOverlayMacApp.xcodeproj`, scheme `MACOS`

The apps talk to the local backend (`http://127.0.0.1:8080`) by default; use the in-app
debug menu (5 taps/clicks on the root view in debug builds) to switch environments.

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

This project is open source and available under the MIT License. See the [LICENSE](LICENSE.md) file for more information.
