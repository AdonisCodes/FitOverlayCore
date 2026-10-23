// VerificationCodeInputComponentPreviews.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

/// A preview provider for the VerificationCodeInputComponent
/// This struct provides SwiftUI previews for the verification code input component
internal struct VerificationCodeInputComponentPreviews: PreviewProvider {
    /// The preview content showing the verification code input component wrapper view
    /// - Returns: A view containing the verification code input component preview
    public static var previews: some View {
        VerificationCodeInputComponentWrapperView()
    }
}

/// A wrapper view that provides a property editor interface for the VerificationCodeInputComponent
/// This view allows real-time editing of the component's properties in SwiftUI previews
internal struct VerificationCodeInputComponentWrapperView: View {
    /// The configuration object for the verification code input component
    /// This observed object contains all customizable properties of the component
    @ObservedObject public var config = VerificationCodeInputComponentConfig()

    /// The body of the wrapper view containing the property editor and component preview
    /// - Returns: A view containing the property editor and component preview
    public var body: some View {
        // Create a property editor with all configurable properties of the component
        PropertyEditor(object: config, properties: [
            // Title configuration
            [AnyKeyPath("Title", keyPath: \.title)],
            // Error message configuration
            [AnyKeyPath("Error Message", keyPath: \.errorMessage)],
            // Color configurations for title and error states
            [
                AnyKeyPath(
                    "TitleColor",
                    keyPath: \.titleSegmentColor
                ),
                AnyKeyPath("ErrorColor", keyPath: \.errorSegmentColor),
            ],
            // Text content configurations
            [AnyKeyPath("Text", keyPath: \.text)],
            [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
            // Background color configurations
            [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
            [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
            [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
            // Text appearance configurations
            [AnyKeyPath("Text Color", keyPath: \.textColor)],
            // Layout configurations
            [AnyKeyPath("Padding", keyPath: \.padding)],
            [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
        ]) {
            // Display the verification code input component with the current configuration
            VerificationCodeInputComponent(config: config)

            // Display the variant selector for the component
            EnumPropertyView(
                value: $config.variant,
                cases: TextInputFrameComponentVariants.allCases
            )
        }
    }
}
