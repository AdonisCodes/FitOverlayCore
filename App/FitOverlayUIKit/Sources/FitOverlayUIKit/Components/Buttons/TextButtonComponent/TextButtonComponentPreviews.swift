// TextButtonComponentPreviews.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the TextButtonComponent that displays various configuration options and states
internal struct TextButtonComponentPreviews: PreviewProvider {
    /// Returns a view containing the TextButtonComponent previews with configurable properties
    public static var previews: some View {
        TextButtonComponentPreviewsView()
    }
}

/// A view that provides an interactive preview of the TextButtonComponent with editable properties
internal struct TextButtonComponentPreviewsView: View {
    /// Shared configuration object for the TextButtonComponent that maintains its state
    @StateObject private var sharedConfig = TextButtonComponentConfig()

    /// The main view body that displays the TextButtonComponent with its property editor
    public var body: some View {
        // Create a property editor with configurable options for the TextButtonComponent
        PropertyEditor(
            object: sharedConfig,
            properties: [
                [AnyKeyPath("Is Disabled", keyPath: \.isDisabled)],
                [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
                [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
                [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
                [AnyKeyPath("Roundness", keyPath: \.roundness)],
                [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
                [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
            ]
        ) {
            VStack {
                // Display the TextButtonComponent with a counter functionality
                TextButtonComponent(
                    config: sharedConfig,
                    onSelfAppear: { config in
                        // Initialize the button text to "0"
                        config.text = "0"
                    },
                    action: { config in
                        // Increment the counter when button is pressed
                        let textAsNum = Int(config.text) ?? 0
                        config.text = "\(textAsNum + 1)"
                    }
                )
                .contentTransition(.symbolEffect(.replace))

                // Add frame variant selector
                EnumPropertyView(
                    value: $sharedConfig.frameVariant,
                    cases: ButtonFrameVariants.allCases
                )

                // Add button variant selector
                EnumPropertyView(
                    value: $sharedConfig.variant,
                    cases: TextButtonVariants.allCases
                )
            }
        }
    }
}
