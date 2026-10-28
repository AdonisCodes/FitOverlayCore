// IconButtonComponentPreviews.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the IconButtonComponent that displays various configurations and states
/// of the button in SwiftUI previews.
internal struct IconButtonComponentPreviews: PreviewProvider {
    /// The preview content showing different states and configurations of the IconButtonComponent
    public static var previews: some View {
        IconButtonComponentPreviewsView()
    }
}

/// A view that provides an interactive preview interface for the IconButtonComponent,
/// allowing real-time manipulation of various button properties and states.
internal struct IconButtonComponentPreviewsView: View {
    /// Shared configuration object that maintains the state of the button properties
    @StateObject private var sharedConfig = IconButtonComponentConfig()

    /// The main view body that constructs the preview interface
    public var body: some View {
        // Create a property editor with configurable button attributes
        PropertyEditor(
            object: sharedConfig,
            properties: [
                [AnyKeyPath("Is Disabled", keyPath: \.isDisabled)],
                [AnyKeyPath("Is Loading", keyPath: \.isLoading)],
                [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
                [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
                [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
                [AnyKeyPath("Roundness", keyPath: \.roundness)],
                [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
                [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
            ]
        ) {
            VStack {
                HStack {
                    // Interactive icon button that toggles between play and pause states
                    IconButtonComponent(
                        config: sharedConfig,
                        onSelfAppear: { config in
                            // Set initial icon state to play
                            config.icon = .play
                        },
                        configAction: { config in
                            // Toggle between play and pause icons when clicked
                            if config.icon == .play {
                                config.icon = .pause
                            } else {
                                config.icon = .play
                            }
                        }
                    ).contentTransition(.symbolEffect(.replace))
                }

                // Frame variant selector using enum property view
                EnumPropertyView(
                    value: $sharedConfig.frameVariant,
                    cases: ButtonFrameVariants.allCases
                )

                // Button variant selector using enum property view
                EnumPropertyView(
                    value: $sharedConfig.variant,
                    cases: IconButtonVariants.allCases
                )
            }
        }
    }
}
