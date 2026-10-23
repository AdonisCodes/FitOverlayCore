// ProgressIndicatorComponentPreviews.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the ProgressIndicatorComponent
/// This struct provides SwiftUI previews for testing and development purposes
internal struct ProgressIndicatorComponentPreviews: PreviewProvider {
    /// The preview content showing a test implementation of the progress indicator
    public static var previews: some View {
        TestProgressView()
    }
}

/// A test view that demonstrates the ProgressIndicatorComponent functionality
/// This view includes controls for modifying various properties of the progress indicator
internal struct TestProgressView: View {
    /// The configuration object that controls the progress indicator's appearance and behavior
    @ObservedObject public var config = ProgressIndicatorComponentConfig()

    /// The main view body that contains the property editor and progress indicator
    public var body: some View {
        VStack {
            // Create a property editor with configurable fields for the progress indicator
            PropertyEditor(object: config, properties: [
                [AnyKeyPath("Total Steps", keyPath: \.totalSteps)],
                [AnyKeyPath("Current Step", keyPath: \.currentStep)],
                [AnyKeyPath("Enable Animation", keyPath: \.isAnimating)],
                [AnyKeyPath("Step Length", keyPath: \.stepLength)],
                [AnyKeyPath("Step Height", keyPath: \.stepHeight)],
                [AnyKeyPath("Step Color", keyPath: \.stepColor)],
            ]) {
                VStack {
                    // Display the progress indicator component centered horizontally
                    HStack {
                        Spacer()
                        ProgressIndicatorComponent(config: config) { config in
                            // Set initial step when component is created
                            config.currentStep = 1
                        }
                        Spacer()
                    }.padding(.bottom)

                    // Add a reset button to return to the first step
                    Button("Reset Current Step") {
                        config.setStep(1)
                    }
                }
            }
        }
    }
}
