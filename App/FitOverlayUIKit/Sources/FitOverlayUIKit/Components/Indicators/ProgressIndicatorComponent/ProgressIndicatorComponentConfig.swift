// ProgressIndicatorComponentConfig.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Represents the different visual variants available for the ProgressIndicatorComponent
public enum ProgressIndicatorVariants {
    /// The default variant that displays a simple progress indicator
    case generic
}

/// Configuration class for customizing the appearance and behaviour of the `ProgressIndicatorComponent`
/// This class manages the state and appearance of a progress indicator, including step count, animations, and styling
public class ProgressIndicatorComponentConfig: ObservableObject {
    /// The visual variant of the progress indicator to be displayed
    /// Currently supports only .generic, with more variants planned for future implementation
    @Published public var variant: ProgressIndicatorVariants

    /// The total number of steps in the progress indicator
    /// This value determines the maximum number of steps that can be displayed
    @Published public var totalSteps: Int

    /// The current active step in the progress sequence
    /// This value is managed by the variant and should be between 1 and totalSteps
    @Published public var currentStep: Int

    /// Controls whether animations are enabled for the component
    /// Can be disabled for testing purposes or when implementing custom animations
    @Published public var isAnimating: Bool

    /// The horizontal length of each step indicator
    /// The variant may modify this value based on the current step and other factors
    @Published public var stepLength: CGFloat

    /// The vertical height of each step indicator
    /// The variant may modify this value based on the current step and other factors
    @Published public var stepHeight: CGFloat

    /// The primary color used for the step indicators
    /// The variant may modify this color's appearance based on the current step and other factors
    @Published public var stepColor: Color

    /// Initializes a new ProgressIndicatorComponentConfig instance with customizable parameters
    /// - Parameters:
    ///   - variant: The visual variant to use for the progress indicator
    ///   - totalSteps: The total number of steps to display
    ///   - isAnimating: Whether animations should be enabled
    ///   - stepLength: The length of each step indicator
    ///   - stepHeight: The height of each step indicator
    ///   - stepColor: The color to use for step indicators
    ///   - currentStep: The initial active step
    public init(
        variant: ProgressIndicatorVariants = .generic,
        totalSteps: Int = 4,
        isAnimating: Bool = true,
        stepLength: CGFloat = 7,
        stepHeight: CGFloat = 7,
        stepColor: Color = DesignTokens.colors.primary,
        currentStep: Int = 1
    ) {
        self.variant = variant
        self.totalSteps = totalSteps
        self.isAnimating = isAnimating
        self.stepLength = stepLength
        self.stepHeight = stepHeight
        self.currentStep = currentStep
        self.stepColor = stepColor
    }

    /// Calculates the total length of the step overlay for the generic variant
    /// - Returns: The computed length considering current step position and spacing
    public var determineStepLengthGrowSize: CGFloat {
        // Calculate the base growth size including step length and spacing
        let growSize = CGFloat(
            stepLength + CGFloat(determineSpaceBetweenSteps)
        )

        // Convert current step to CGFloat for calculations
        let currentStepRelative = CGFloat(currentStep)
        let totalStepsRelative = CGFloat(totalSteps)

        // Adjust current step value ensuring it doesn't exceed total steps
        let currentStepFixed = (currentStepRelative >= totalStepsRelative ? totalStepsRelative : currentStepRelative) -
            1

        // Calculate final length including base step length
        return growSize * currentStepFixed + determineStepLength(0)
    }

    /// Calculates the spacing between individual step indicators
    /// - Returns: The computed spacing as a multiple of step length
    public var determineSpaceBetweenSteps: CGFloat {
        stepLength * 1.75
    }

    /// Calculates the length for a specific step in the generic variant
    /// - Parameter step: The step index to calculate length for
    /// - Returns: The computed length for the specified step
    public func determineStepLength(_ step: Int) -> CGFloat {
        // First step has additional padding, other steps use base length
        step == 0 ? (
            stepLength + determineSpaceBetweenSteps * 2
        ) : stepLength
    }

    /// Determines the color for a specific step based on its state
    /// - Parameter step: The step index to determine color for
    /// - Returns: The appropriate color for the step's current state
    public func determineStepColor(_ step: Int) -> Color {
        // Apply reduced opacity for the previous step, full opacity for others
        (
            currentStep - 1 == step && currentStep - 1 > 0
        ) ? stepColor.opacity(0.5) : stepColor
    }

    /// Increments the current step by a specified amount
    /// - Parameter byCount: The number of steps to increment by (defaults to 1)
    /// This method ensures the step count doesn't exceed the total number of steps
    public func incrementStep(_ byCount: Int = 1) {
        let setStepTo = currentStep + byCount
        guard setStepTo <= totalSteps else {
            currentStep = totalSteps
            return
        }
        currentStep = setStepTo
    }

    /// Decrements the current step by a specified amount
    /// - Parameter byCount: The number of steps to decrement by (defaults to 1)
    /// This method ensures the step count doesn't go below 1
    public func decrementStep(_ byCount: Int = 1) {
        let setStepTo = currentStep - byCount
        guard setStepTo >= 1 else {
            currentStep = 1
            return
        }
        currentStep = setStepTo
    }

    /// Sets the current step to a specific value
    /// - Parameter step: The step number to set as current
    /// This method ensures the new step value is within valid bounds
    public func setStep(_ step: Int) {
        guard currentStep != step, step > 0, step <= totalSteps else { return }
        currentStep = step
    }

    deinit {
        return
    }
}
