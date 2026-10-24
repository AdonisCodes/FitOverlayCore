// LoginSuccessTemporary.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// A temporary screen shown after successful user login
///
/// This view displays a placeholder screen with a message indicating that the app
/// is under development. It will be replaced with the actual home screen once
/// the app is ready for general use.
///
/// The screen shows:
/// - A thank you message to users
/// - A progress indicator showing completion of the login flow
/// - Information about the app's development status
public struct LoginSuccessTemporary: View {
    /// Creates a new instance of the temporary login success screen
    ///
    /// This initializer creates the view with default configurations
    public init() {}

    /// The main view body that defines the screen's layout and content
    ///
    /// The view uses an OnboardingScreenFrame to maintain consistent styling with
    /// other onboarding screens, displaying:
    /// - A title section with an InfoPairComponent showing a thank you message
    /// - A footer section with a progress indicator showing completion (step 4 of 4)
    public var body: some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(
                    config: .init(
                        title: "Thanks for your patience!",
                        description: """
                        The app is currently being developed. \
                        This screen will be removed once the app is open for general use!
                        """
                    )
                )
            },
            footerContent: {
                HStack {
                    Spacer()
                    ProgressIndicatorComponent(
                        config: .init(totalSteps: 4, currentStep: 4)
                    )
                    Spacer()
                }
            }
        )
    }
}
