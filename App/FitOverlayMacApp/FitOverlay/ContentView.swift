// ContentView.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayAppShared
import FitOverlayUIKit
import SwiftUI

/// The main content view for the FitOverlay app
///
/// This view serves as the root view of the application, handling different states including:
/// - Network connectivity status
/// - App loading state
/// - User authentication state
/// - Application update requirements
/// - User application review status
internal struct ContentView: View {
    /// The environment configuration object containing app state and user authentication information
    @EnvironmentObject public var baseEnvironmentConfig: BaseAppEnvironmentObject

    /// The network manager object that monitors network connectivity
    @EnvironmentObject public var networkChecker: NetworkManager

    /// The main view body that determines which view to display based on app state
    ///
    /// The view hierarchy is determined by checking:
    /// 1. Network connectivity
    /// 2. App loading status
    /// 3. App update requirements
    /// 4. User authentication and acceptance status
    public var body: some View {
        if networkChecker.isConnected {
            VStack {
                if baseEnvironmentConfig.isAppFinishedLoading {
                    if baseEnvironmentConfig.shouldUpdateApp {
                        ForceUpdate()
                    } else if baseEnvironmentConfig.isLoggedIn, baseEnvironmentConfig.isAccepted {
                        LoginSuccessTemporary()
                    } else if baseEnvironmentConfig.isLoggedIn {
                        PendingApplicationReview()
                    } else {
                        OnboardingAuthPickerScreen()
                    }
                } else {
                    ProgressView()
                }
            }
        } else {
            NoNetworkConnectionView()
        }
    }
}

/// Provides a preview of the ContentView for SwiftUI previews
#Preview {
    ContentView()
}
