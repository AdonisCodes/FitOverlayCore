// ProgressIndicatorComponent.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/**
 The `ProgressIndicatorComponent` is a reusable \
 component that allows you \
 to present some kind of progression of tasks to the user.

 This component has the ability to easily be wrapped \
 & converted into any \
 other component that is needed (that has similar logic),\
 here are some cases:
 - Loading bar can use this by growing the height of each step \
    & slowly stepping over each step.
 - Progress bar to represent the progress of some background work by \
    stepping through a set amount of steps

 For more information, refer to the documentation in \
 `ProgressIndicatorComponentDocumentation.md`
 */
public struct ProgressIndicatorComponent: View {
    /// The configuration object used to manipulate this component's state.
    /// This observed object contains all the necessary parameters to customize \
    /// the appearance and behavior of the progress indicator.
    @ObservedObject public var config: ProgressIndicatorComponentConfig

    /// A closure that is called when the component appears.
    /// - Parameter config: The current configuration of the progress indicator
    /// This can be used to customize the configuration or reset the component's state, \
    /// particularly useful in scroll view scenarios.
    public let onSelfAppear: (ProgressIndicatorComponentConfig) -> Void

    /**
     Initializes a new progress indicator component.

     - Parameters:
        - config: The configuration object that defines the appearance \
            and behavior of the progress indicator
        - onSelfAppear: A closure that is called when the component appears.
            Defaults to an empty closure.
     */
    public init(
        config: ProgressIndicatorComponentConfig,
        onSelfAppear: @escaping (ProgressIndicatorComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onSelfAppear = onSelfAppear
    }

    /// The body of the view that represents the progress indicator
    public var body: some View {
        // Create a ZStack to layer the progress elements
        ZStack(alignment: .leading) {
            // Create the base progress bar with individual step segments
            HStack(spacing: 0) {
                // Iterate through each step to create the progress segments
                ForEach(0 ..< config.totalSteps, id: \.self) { step in
                    // Create a rectangle for each step with configured dimensions and appearance
                    Rectangle()
                        .frame(
                            width: config.determineStepLength(step),
                            height: config.stepHeight
                        )
                        .foregroundStyle(
                            config.determineStepColor(step)
                        )
                        .padding(
                            .trailing,
                            step == config.totalSteps - 1 ? 0 : config.determineSpaceBetweenSteps
                        )
                        .animation(
                            config.isAnimating ? .spring : nil,
                            value: config.currentStep
                        )
                }
            }

            // Create an overlay rectangle that represents the current progress
            Rectangle()
                .frame(
                    width: config.determineStepLengthGrowSize,
                    height: config.stepHeight
                )
                .foregroundStyle(config.stepColor)
                .animation(config.isAnimating ? .smooth : nil, value: config.currentStep)
                .tag("progress-indicator-overlay")
        }
        .onAppear {
            // Call the onSelfAppear closure when the view appears
            onSelfAppear(config)
        }
        .animation(config.isAnimating ? .spring : nil, value: config.totalSteps)
    }
}
