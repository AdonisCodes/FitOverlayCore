// TextButtonComponent.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A custom button component that displays text with configurable styling and behavior.
/// This component provides multiple initialization options and handles both appearance and interaction events.
///
/// The button can be configured with:
/// - Custom text content
/// - Appearance configuration through TextButtonComponentConfig
/// - Appearance and tap action handlers
///
/// Example usage:
/// ```
/// TextButtonComponent(
///     defaultText: "Click me",
///     action: { print("Button tapped") }
/// )
/// ```
public struct TextButtonComponent: View {
    /// The external configuration of the button, provided by the parent view.
    /// This observed object allows dynamic updates to the button's appearance and behavior.
    @ObservedObject private var externalConfig: TextButtonComponentConfig

    /// The configuration to use for the button. This is either the external or internal config.
    /// Provides a single point of access to the button's configuration properties.
    private var config: TextButtonComponentConfig { externalConfig }

    /// A closure that is called when the button appears on screen, passing the current configuration.
    /// Use this for setup or logging when the button becomes visible.
    public let onSelfAppear: ((TextButtonComponentConfig) -> Void)?

    /// A closure to execute when the button is tapped, passing the current configuration.
    /// Handles the button's tap interaction and provides access to the current configuration state.
    public let action: ((TextButtonComponentConfig) -> Void)?

    // MARK: - 1. Initializer with external config

    /// Initializes the TextButtonComponent with an external configuration.
    /// This initializer provides full control over the button's configuration and behavior.
    ///
    /// - Parameters:
    ///   - config: The external configuration that defines the button's appearance and behavior.
    ///   - onSelfAppear: A closure called when the button appears on screen. Defaults to nil.
    ///   - action: A closure called when the button is tapped. Defaults to nil.
    ///
    /// - Note: This is the most flexible initialization method, allowing full external configuration.
    public init(
        config: TextButtonComponentConfig,
        onSelfAppear: ((TextButtonComponentConfig) -> Void)?,
        action: ((TextButtonComponentConfig) -> Void)?
    ) {
        externalConfig = config
        self.onSelfAppear = onSelfAppear
        self.action = action
    }

    // MARK: - 2. Initializer with default internal config

    /// Initializes the TextButtonComponent with a default internal configuration.
    /// This initializer creates a button with basic configuration while allowing custom text and action.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen. Defaults to no-op.
    ///   - defaultText: The default text the button should display.
    ///   - action: A closure called when the button is tapped, providing access to the configuration.
    ///
    /// - Note: Uses internal configuration with custom text and action handling.
    public init(
        onSelfAppear: @escaping (TextButtonComponentConfig) -> Void = { _ in },
        defaultText: String,
        action: @escaping (TextButtonComponentConfig) -> Void
    ) {
        self.onSelfAppear = onSelfAppear
        self.action = action

        // Initialize with default configuration
        _externalConfig = .init(initialValue: .init())
        externalConfig.text = defaultText
    }

    // MARK: - 3. Initializer with action without config

    /// Initializes the TextButtonComponent with a simple action closure.
    /// This is the simplest initialization method, ideal for basic button implementations.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen. Defaults to no-op.
    ///   - defaultText: The default text the button should display.
    ///   - action: A simple closure called when the button is tapped. Defaults to no-op.
    ///
    /// - Note: Provides a simplified interface for basic button functionality.
    public init(
        onSelfAppear: @escaping (TextButtonComponentConfig) -> Void = { _ in },
        defaultText: String,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            onSelfAppear: onSelfAppear,
            defaultText: defaultText
        ) { _ in action() }
    }

    // MARK: - Body

    /// The view body that represents the button. It renders a button frame with the specified text.
    /// This implementation uses ButtonFrameComponent to create a consistent button appearance.
    ///
    /// - Returns: A Button view wrapped in a custom frame, displaying the text and triggering the associated action.
    public var body: some View {
        ButtonFrameComponent(
            config: config,
            action: ({
                // Execute the action closure if it exists
                if let action {
                    action(config)
                }
            })
        ) {
            // Create the button's text content with specified styling
            Text(config.text)
                .fontTableFont(
                    FontTable.SFPro.Headings.head6, DesignTokens.colors.textDark
                )
        }
        onSelfAppear: { _ in
            print("calling on self appear button frame comp")
            // Execute the onSelfAppear closure if it exists
            if let onSelfAppear {
                onSelfAppear(config)
            }
        }
    }
}
