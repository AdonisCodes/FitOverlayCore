# FitOverlayCore

[![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg?style=flat&logo=swift)](https://swift.org/)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey.svg)](https://developer.apple.com/)
[![Vapor](https://img.shields.io/badge/Vapor-4-2D68F7.svg?logo=vapor)](https://vapor.codes/)

FitOverlayCore is the core infrastructure powering **FitOverlay** — an easy-to-use fitness
overlay app that renders workout data from `.FIT` files (speed, heart rate, power, cadence,
elevation, map) over action-cam video, with a drag-and-drop layout editor. One licence,
one-time lifetime payment across platforms; subscriptions supported.

This monorepo contains everything needed to run the FitOverlay platform: the server-side
components, the platform-agnostic overlay engine, and the client applications.

## 📦 Project Structure

The repository is organized into several main components:

### Backend (`/Backend`)
The server-side component built with Vapor 4, providing:
- RESTful API endpoints
- Database models and migrations (PostgreSQL / Fluent)
- Authentication and authorization (phone number + one-time code, JWT access/refresh tokens)
- Licence keys, cross-platform device activations, and purchase webhook stubs (Stripe / App Store)
- Docker / docker-compose based local development

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
- **FitOverlayApp**: Main macOS application (SwiftUI, multiplatform-friendly so iOS can follow)
- **FitOverlayAppShared**: Shared code between platforms
  - Network layer
  - Authentication screens & onboarding flow
  - Business logic
- **FitOverlayUIKit**: Shared UI components and theming (design tokens, fonts, inputs, buttons)

### DataTypes (`/Backend/DataTypes`)
Shared data models and type definitions used across the backend and clients.

## 🚀 Features

- **Cross-Platform Core**: Engine and backend build and test on Linux; clients on macOS (iOS-ready)
- **Modern Architecture**: Built with Swift 6.1 and Swift Concurrency
- **Scalable Backend**: Powered by Vapor 4 with PostgreSQL
- **Licensing Built In**: Lifetime licences & subscriptions, device activations across platforms
- **CI/CD**: GitHub Actions for backend, engine, app, and linting

## 🛠️ Technical Stack

- **Backend**: Swift 6.1, Vapor 4, PostgreSQL (Fluent)
- **Engine**: Pure Swift + Foundation (Linux/Windows/WASM-friendly)
- **macOS/iOS**: SwiftUI
- **Infrastructure**: Docker
- **CI/CD**: GitHub Actions
- **Dependencies**:
  - Vapor ecosystem (Fluent, Leaf, JWT)
  - Alamofire for client networking
  - SimpleKeychain for secure token storage

## 🔧 Setup

### Backend (local)

```bash
cd Backend
cp .env.example .env.local        # adjust secrets as needed
docker compose up -d postgres     # start the database
docker compose up api-dev         # run the API with hot reload
# or natively: swift run App serve --env local
```

### Engine

```bash
cd FitOverlayKit
swift build && swift test         # works on Linux and macOS
```

### macOS App

Open `App/FitOverlayApp/FitOverlayApp.xcodeproj` in Xcode 16+, select the `MACOS` scheme,
and run. The app talks to the local backend (`http://127.0.0.1:8080`) by default; use the
in-app debug menu (5 clicks on the root view in debug builds) to switch environments.

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

This project is available under the MIT License. See the [LICENSE](LICENSE.md) file for more information.
