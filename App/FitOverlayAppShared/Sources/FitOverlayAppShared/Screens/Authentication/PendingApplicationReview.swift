// PendingApplicationReview.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// View that informs the user that their application is pending
///
/// This screen is displayed after a user submits their application and is waiting for review.
/// It provides:
/// - A message informing the user about the next steps
/// - Instructions to contact support via Discord
/// - A progress indicator showing completion of the application process
///
/// The view uses `OnboardingScreenFrame` to maintain consistent styling with other onboarding screens.
public struct PendingApplicationReview: View {
    /// Creates a new instance of the pending application review screen
    ///
    /// This view is stateless and doesn't require any initialization parameters
    public init() {}

    /// The main view body that constructs the pending application review UI
    ///
    /// Layout consists of:
    /// - Title section with an `InfoPairComponent` displaying the pending status message
    /// - Footer section with a `ProgressIndicatorComponent` showing this as step 4 of 4
    public var body: some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(
                    config: .init(
                        title: "We'll get back to you soon!",
                        description: """
                        FitOverlay is in early access. We review new accounts as fast as we can — \
                        we'd love to hear about the videos you want to make!
                        """
                    )
                )
            },
            footerContent: {
                Spacer()
                ProgressIndicatorComponent(
                    config: .init(totalSteps: 4, currentStep: 4)
                )
                Spacer()
            }
        )
    }
}
