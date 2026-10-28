// OnboardingScreen.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// A structure representing the content for a single onboarding screen
/// - Contains the title, description and background color for the screen
internal struct OnboardingScreenContent {
    /// The title text to be displayed on the onboarding screen
    public let title: String

    /// The description text providing more detail about the feature
    public let description: String

    /// The background color of the onboarding screen
    public let background: Color = DesignTokens.colors.primary
}

/// A view that presents the onboarding experience when a user first opens the app
/// - Displays a series of screens introducing key features and functionality
/// - Handles navigation between onboarding screens and to registration
public struct OnboardingScreen: View {
    /// Configuration for the title and description display
    @ObservedObject public var titleConfig: InfoPairComponentConfig = .init()

    /// Configuration for the progress indicator showing current position in onboarding flow
    @ObservedObject public var progressIndicatorConfig: ProgressIndicatorComponentConfig = .init()

    /// Configuration for the navigation button
    @ObservedObject public var iconButtonConfig: IconButtonComponentConfig = .init()

    /// State controlling whether to show the application screen
    @State public var shouldShowApplyScreen: Bool = false

    /// State controlling whether to show the registration screen
    @State private var shouldShowRegisterScreen: Bool = false

    /// Array of content for each onboarding screen
    private let onboardingScreenContent: [OnboardingScreenContent] = [
        .init(
            title: "Your ride data, on your video",
            description: """
            FitOverlay renders speed, heart rate, power, cadence, elevation and a live map \
            from your .FIT files right on top of your action-cam footage.
            """
        ),
        .init(
            title: "Drag & drop layout editor",
            description: """
            Place, resize and style every widget exactly how you want it. Save layouts as \
            templates and reuse them across all your videos.
            """
        ),
        .init(
            title: "Perfectly in sync",
            description: """
            Align your workout data with your video once, and FitOverlay keeps every frame \
            in sync — even for long rides and runs.
            """
        ),
        .init(
            title: "One licence, every platform",
            description: """
            Pay once, use FitOverlay forever — on Mac today, and on more platforms as they \
            arrive. Subscriptions are supported too.
            """
        ),
    ]

    /// Initializes a new onboarding screen
    public init() {}

    /// The main view body that manages navigation between different screens
    public var body: some View {
        if shouldShowRegisterScreen {
            RegisterScreen()
        } else if shouldShowApplyScreen {
            generateApplyView()
        } else {
            generateOnboardingView()
        }
    }

    /// Generates the main onboarding view with title, description and navigation controls
    /// - Returns: A view containing the onboarding content and navigation elements
    @ViewBuilder
    private func generateOnboardingView() -> some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(config: titleConfig) { config in
                    config.title = onboardingScreenContent[0].title
                    config.description = onboardingScreenContent[0].description
                }
                .animation(
                    .bouncy,
                    value: progressIndicatorConfig.currentStep
                )
            },
            footerContent: {
                ProgressIndicatorComponent(config: progressIndicatorConfig) { config in
                    config.totalSteps = onboardingScreenContent.count
                }
                Spacer()
                IconButtonComponent(
                    config: iconButtonConfig,
                    onSelfAppear: { _ in
                        iconButtonConfig.variant = .circle
                        iconButtonConfig.icon = .arrowRight
                    },
                    action: handleOnboardingNextScreen
                )
            }
        )
    }

    /// Generates the application view shown after completing the onboarding flow
    /// - Returns: A view containing the application information and continue button
    @ViewBuilder
    private func generateApplyView() -> some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(config: titleConfig) { config in
                    config.title = "Apply to Join"
                    config
                        .description =
                        """
                        We are a closed community, accepting the highest quality candidates only. \
                        If you are ambitious, click next!
                        """
                }
            },
            footerContent: {
                IconButtonComponent(
                    defaultIcon: .arrowRight
                ) {
                    shouldShowApplyScreen = false
                    shouldShowRegisterScreen = true
                }
            }
        ).animation(.bouncy, value: progressIndicatorConfig.currentStep)
    }

    /// Handles navigation to the next screen in the onboarding flow
    /// - Updates the progress indicator and content when moving between screens
    /// - Triggers transition to application screen when onboarding is complete
    public func handleOnboardingNextScreen() {
        if progressIndicatorConfig.currentStep == onboardingScreenContent.count {
            shouldShowApplyScreen = true
            return
        }

        progressIndicatorConfig.currentStep += 1
        titleConfig.title = onboardingScreenContent[progressIndicatorConfig.currentStep - 1].title
        titleConfig.description = onboardingScreenContent[progressIndicatorConfig.currentStep - 1].description
    }
}

#Preview {
    OnboardingScreen()
        .preferredColorScheme(.dark)
}
