// TextInputComponentPreviews.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the TextInputComponent that displays various configuration options
/// and states of the text input component.
internal struct TextInputComponentPreviews: PreviewProvider {
    /// Returns a view that wraps the TextInputComponent with configuration controls
    public static var previews: some View {
        TextInputComponentWrapperView()
    }
}

/// A wrapper view that provides a property editor interface for configuring and
/// previewing the TextInputComponent with various settings and states.
internal struct TextInputComponentWrapperView: View {
    /// The configuration object that controls the appearance and behavior of the TextInputComponent
    @ObservedObject public var config = TextInputComponentConfig()

    /// The main view body that constructs the property editor interface
    public var body: some View {
        // Create a property editor with configurable fields for the TextInputComponent
        PropertyEditor(
            object: config,
            properties: [
                // Text content configuration
                [AnyKeyPath("Title", keyPath: \.title)],
                [AnyKeyPath("Error Message", keyPath: \.errorMessage)],

                // Color configuration for title and error states
                [
                    AnyKeyPath(
                        "TitleColor",
                        keyPath: \.titleSegmentColor
                    ),
                    AnyKeyPath("ErrorColor", keyPath: \.errorSegmentColor),
                ],

                // Input field configuration
                [AnyKeyPath("Text", keyPath: \.text)],
                [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
                [AnyKeyPath("Has Icon", keyPath: \.hasIcon)],

                // Visual styling configuration
                [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
                [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
                [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
                [AnyKeyPath("Text Color", keyPath: \.textColor)],
                [AnyKeyPath("Padding", keyPath: \.padding)],
                [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
            ]
        ) {
            // Stack containing the TextInputComponent and its variant/icon selectors
            VStack {
                // The main TextInputComponent with applied configuration
                TextInputComponent(config: config)

                // Variant selector for different TextInputComponent styles
                EnumPropertyView(
                    value: $config.variant,
                    cases: TextInputFrameComponentVariants.allCases
                )

                // Icon selector for different available icons
                EnumPropertyView(
                    value: $config.icon,
                    cases: DesignIcons.allCases
                )
            }
        }
    }
}
