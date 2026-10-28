// FitOverlayApp.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayAppShared
import SwiftUI

/// The main FitOverlay application entry point (macOS-first, multiplatform-friendly)
///
/// This struct serves as the root of the application, handling app lifecycle events,
/// environment configuration, and network connectivity monitoring.
@main
internal struct FitOverlayApp: App {
    /// The base environment configuration object containing app state and user authentication information
    @StateObject public var baseConfig = BaseAppEnvironmentObject()

    /// The network manager object that monitors network connectivity status
    @StateObject public var networkChecker: NetworkManager = .init()

    /// Handles application launch and setup
    ///
    /// This method:
    /// 1. Checks network connectivity
    /// 2. Retrieves and validates client version requirements
    /// 3. Handles user authentication state
    /// 4. Sets up periodic token refresh
    ///
    /// - Note: This runs when the app launches and sets up a 15-minute timer for token refresh
    @Sendable
    private func onAppOpen() async {
        let launchManager = AppLaunch(
            baseURL: baseConfig.apiBaseURL
        )

        if networkChecker.isConnected {
            let serverRequiredVersion = await launchManager.getClientConfig()

            if serverRequiredVersion.requiredClientVersion > baseConfig.clientVersion {
                baseConfig.shouldUpdateApp = true
            }

            baseConfig.isLoggedIn = await launchManager.getAccessToken()
            if baseConfig.isLoggedIn {
                baseConfig.isAccepted = await launchManager
                    .isUserAccepted()
            }
        }

        baseConfig.isAppFinishedLoading = true

        Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { _ in
            Task {
                if await networkChecker.isConnected {
                    let result = await launchManager.getAccessToken()
                    await MainActor.run {
                        baseConfig.isLoggedIn = result
                    }
                }
            }
        }
    }

    /// The main scene of the application
    ///
    /// Configures and presents the root view hierarchy with:
    /// - Dark mode color scheme
    /// - Debug menu activation gesture (5 taps/clicks, debug builds only)
    /// - Environment objects for app configuration and network status
    public var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onTapGesture(count: 5) {
                    #if DEBUG
                        baseConfig.isDebugMenuActive = true
                    #else
                        if baseConfig.isTestflight {
                            baseConfig.isDebugMenuActive = true
                        }
                    #endif
                }
                .task(onAppOpen)
                .debugMenuPresentation(isPresented: $baseConfig.isDebugMenuActive)
                .environmentObject(baseConfig)
                .environmentObject(networkChecker)
                #if os(macOS)
                .frame(minWidth: 960, minHeight: 600)
                #endif
        }
    }
}

private extension View {
    /// Presents the debug menu full screen on iOS and as a sheet on macOS
    /// (where `fullScreenCover` is unavailable).
    @ViewBuilder
    func debugMenuPresentation(isPresented: Binding<Bool>) -> some View {
        #if os(macOS)
            sheet(isPresented: isPresented) {
                DebugMenu()
                    .frame(minWidth: 480, minHeight: 420)
            }
        #else
            fullScreenCover(isPresented: isPresented) {
                DebugMenu()
            }
        #endif
    }
}
