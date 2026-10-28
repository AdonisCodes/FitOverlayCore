// ButtonFrameComponent.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/**
 A reusable button component that allows for flexible configuration of its action, content, \
 and appearance.

 This component supports multiple initializer variations to allow for different \
 configurations of actions and content:
 - Action with or without configuration
 - Content with or without configuration
 - Automatic configuration defaults if no custom values are provided.

 The component is highly customizable through its ButtonFrameComponentConfig object, \
 allowing for:
 - Different visual variants (generic, disabled, rainbow)
 - Customizable padding and spacing
 - Flexible content layout
 - Configurable appearance states

 For more information, refer to the documentation in `ButtonFrameComponentDocumentation.md`.
 */
internal struct ButtonFrameComponent<Content: View>: View {
    /// The configuration object that controls the button's appearance and behavior
    /// This observed object will automatically trigger view updates when modified
    @ObservedObject private var config: ButtonFrameComponentConfig

    /// The action to be performed when the button is tapped
    /// Takes the current configuration as a parameter to allow for dynamic behavior
    public let action: (ButtonFrameComponentConfig) -> Void

    /// Callback triggered when the button appears on screen
    /// Useful for setup operations or state initialization
    public let onSelfAppear: (ButtonFrameComponentConfig) -> Void

    /// Closure that generates the button's content view
    /// Can be configured to use the current button configuration
    public var content: (ButtonFrameComponentConfig) -> Content

    // MARK: - Initializer 1: Action with config, content without config

    /**
     Initializes a `ButtonFrameComponent` where the action uses the button's configuration \
     and the content is static.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action triggered when the button is tapped.
     - Parameter content: A closure returning the content view to be displayed inside the button.
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    public init(
        config: ButtonFrameComponentConfig,
        action: @escaping (ButtonFrameComponentConfig) -> Void,
        @ViewBuilder content: @escaping () -> Content,
        onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in
        }
    ) {
        self.config = config
        self.action = action
        self.onSelfAppear = onSelfAppear
        self.content = { _ in
            content()
        }
    }

    // MARK: - Initializer 2: Content with config, action without config

    /**
     Initializes a `ButtonFrameComponent` where the content uses the button's configuration \
     and the action is static.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action triggered when the button is tapped.
     - Parameter content: A ViewBuilder closure that exposes the config, Returns `some View`
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    public init(
        config: ButtonFrameComponentConfig,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
        onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in
        }
    ) {
        self.config = config
        self.action = { _ in
            action()
        }
        self.onSelfAppear = onSelfAppear
        self.content = content
    }

    // MARK: - Initializer 3: Neither action nor content use config

    /**
     Initializes a `ButtonFrameComponent` where neither the action nor the content \
     uses the configuration.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action triggered when the button is tapped.
     - Parameter content: A closure returning the content view to be displayed inside the button.
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    public init(
        config: ButtonFrameComponentConfig,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in
        }
    ) {
        self.config = config
        self.action = { _ in
            action()
        }
        self.onSelfAppear = onSelfAppear
        self.content = { _ in
            content()
        }
    }

    // MARK: - Initializer 4: Both action and content use config

    /**
     Initializes a `ButtonFrameComponent` where both the action and content use the configuration.
     This is the most flexible initialization option, allowing full access to configuration \
     in both action and content.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action when the button is tapped.
     - Parameter content: A closure returning the content view to be displayed inside the button.
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    public init(
        config: ButtonFrameComponentConfig,
        action: @escaping (ButtonFrameComponentConfig) -> Void,
        @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
        onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in
        }
    ) {
        self.config = config
        self.action = action
        self.onSelfAppear = onSelfAppear
        self.content = content
    }

    // MARK: - Body

    /**
     The body of the button, which defines the layout and interaction behavior.

     This computed property constructs the button's visual representation and behavior:
     - Creates a button with the configured action
     - Applies layout modifiers based on configuration
     - Handles appearance states and animations
     - Manages button state (enabled/disabled)

     The body implements a composable view hierarchy that can be customized through \
     the configuration object.
     */
    public var body: some View {
        Button(
            action: ({
                // Execute the configured action with current configuration state
                action(config)
            })
        ) {
            // Render content with current configuration
            content(config)
                .frame(maxWidth: config.fillSpace ? .infinity : nil)
                .padding(config.defaultPadding)
                .background(determineBackgroundColor())
        }
        .cornerRadius(config.isCircular ? .infinity : config.roundness)
        .disabled(config.frameVariant == .disabled)
        .frame(minWidth: 0, minHeight: 0)
        .onAppear {
            print("calling from bframe")
            onSelfAppear(config)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper Functions

    /**
     Determines and returns the appropriate background color for the button based on \
     the configuration's variant.

     This method handles the visual styling of the button based on its current state:
     - Disabled state shows a muted background
     - Generic state uses the standard background
     - Rainbow state applies a gradient effect

     - Returns: A view representing the button's background (gradient or solid color).
     */
    public func determineBackgroundColor() -> some View {
        Group {
            switch config.frameVariant {
            case .disabled:
                // Apply disabled state background
                config.variantDisabledBackground
            case .generic:
                // Apply standard background for normal state
                config.variantGenericBackground
            case .rainbow:
                // Apply gradient background for rainbow variant
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}
