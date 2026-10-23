// OnboardingAuthPickerScreen.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// Represents the available authentication routes in the onboarding flow
/// - login: Route to the login screen
/// - register: Route to the registration screen
internal enum AuthScreenRoute {
    case login
    case register
}

/// Authentication picker screen presented during onboarding
/// Allows users to choose between logging in to an existing account or registering a new one
/// This screen serves as the entry point to the authentication flow
public struct OnboardingAuthPickerScreen: View {
    /// Navigation path state storing the current authentication route
    @State private var path: [AuthScreenRoute] = []

    /// Initializes a new instance of the OnboardingAuthPickerScreen
    public init() {}

    /// The main view body of the OnboardingAuthPickerScreen
    /// Presents a navigation stack with options to login or register
    public var body: some View {
        NavigationStack(path: $path) {
            OnboardingScreenFrame(
                titleContent: makeTitleContent,
                footerContent: makeFooter
            )
            .navigationDestination(for: AuthScreenRoute.self) { screen in
                switch screen {
                case .register:
                    OnboardingScreen()
                        .navigationBarBackButtonHidden(true)
                case .login:
                    LoginScreen()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    /// Creates the title content for the onboarding screen
    /// - Returns: A view containing the welcome message and app description
    @ViewBuilder
    private func makeTitleContent() -> some View {
        InfoPairComponent(config:
            .init(
                title: "Welcome to FitOverlay!",
                description: "Beautiful workout data overlays for your action-cam videos — in minutes!"
            ))
    }

    /// Creates the footer content containing authentication options
    /// - Returns: A view with Register and Login buttons
    @ViewBuilder
    private func makeFooter() -> some View {
        VStack {
            TextButtonComponent(defaultText: "Register") {
                path = [
                    .register,
                ]
            }
            TextButtonComponent(defaultText: "Login") {
                path = [
                    .login,
                ]
            }
        }
    }
}

/// SwiftUI preview provider for OnboardingAuthPickerScreen
#Preview {
    OnboardingAuthPickerScreen()
}
