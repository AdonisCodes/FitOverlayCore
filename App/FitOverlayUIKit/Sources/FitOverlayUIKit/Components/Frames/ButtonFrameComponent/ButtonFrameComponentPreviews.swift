// ButtonFrameComponentPreviews.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the ButtonFrameComponent
internal struct ButtonFrameComponentPreviews: PreviewProvider {
    /// Returns a view containing various button frame component previews
    public static var previews: some View {
        ButtonFrameComponentPreviewsView()
    }
}

/// A view that displays various configurations and examples of ButtonFrameComponent
internal struct ButtonFrameComponentPreviewsView: View {
    /// The configuration object for the button frame component
    @StateObject public var buttonConfig: ButtonFrameComponentConfig = .init()

    /// The main view body displaying property controls and button examples
    public var body: some View {
        PropertyEditor(
            object: buttonConfig,
            properties: [
                [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
                [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
                [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
                [AnyKeyPath("Roundness", keyPath: \.roundness)],
                [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
                [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
            ]
        ) {
            VStack {
                AutoButtonVariationsView()
                HStack {
                    ButtonFrameComponent(
                        config: buttonConfig,
                        action: ({
                            print("Clicked Me")
                        })
                    ) {
                        Text("Hello, World")
                            .fontTableFont(FontTable.SFPro.Body.body4)
                    }

                    ButtonFrameComponent(
                        config: buttonConfig,
                        action: ({
                            print("Clicked Me")
                        })
                    ) {
                        Image(systemName: "play.fill")
                    }
                }

                EnumPropertyView(
                    value: $buttonConfig.frameVariant,
                    cases: ButtonFrameVariants.allCases
                )
            }
        }
    }
}

/// A view that demonstrates automatic variations of button styles and configurations
internal struct AutoButtonVariationsView: View {
    /// The configuration controller for the button frame component
    @StateObject public var buttonController: ButtonFrameComponentConfig = .init()

    /// Tracks whether the automatic variation timer is active
    @State private var isTimerActive = false

    /// The delay between automatic style changes in seconds
    public let switchDelay: TimeInterval = 0.5

    /// The main view body displaying buttons with automatic style variations
    public var body: some View {
        HStack {
            ButtonFrameComponent(
                config: buttonController,
                action: ({ config in
                    config.isCircular.toggle()
                    config.frameVariant = .disabled
                })
            ) { _ in
                ProgressView()
            } onSelfAppear: { _ in
                startChangingVariant()
            }

            Spacer()

            IconButtonComponent(
                onSelfAppear: { config in
                    config.variant = .square
                },
                configAction: { config in
                    if isTimerActive {
                        stopChangingVariant()
                    } else {
                        startChangingVariant()
                    }
                    config.icon = isTimerActive ? .pause : .play
                }
            )
        }
    }

    /// Starts the automatic variant changing timer if it's not already active
    /// This function initiates a cycle of automatic style changes for the button
    public func startChangingVariant() {
        // Check if timer is already active to prevent multiple timers
        if isTimerActive {
            return
        }

        isTimerActive = true

        // Schedule the first variant update
        DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
            updateVariant()
        }
    }

    /// Updates the button's appearance with random variants and configurations
    /// This function is called repeatedly while the timer is active
    public func updateVariant() {
        // Disable rule, because `ButtonFrameVariants` has more than 0 cases, \
        // so it will find a random element
        // swiftlint:disable force_unwrapping
        // Randomly update button properties
        buttonController.frameVariant = .allCases.randomElement()!
        // swiftlint:enable force_unwrapping
        buttonController.isCircular = .random()
        buttonController.fillSpace = .random()

        // Schedule next update if timer is still active
        if isTimerActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
                updateVariant()
            }
        }
    }

    /// Stops the automatic variant changing timer
    /// This function halts the automatic style changes for the button
    public func stopChangingVariant() {
        isTimerActive = false
    }
}
