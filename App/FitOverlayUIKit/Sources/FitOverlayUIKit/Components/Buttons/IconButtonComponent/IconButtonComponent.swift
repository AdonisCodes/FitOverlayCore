// IconButtonComponent.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A custom button component that displays an icon and allows for flexible configuration and action handling.
/// This component provides various initialization options and supports loading states, icon customization,
/// and action handling with async capabilities.
public struct IconButtonComponent: View {
    /// The external configuration of the button, provided by the parent view.
    /// This observed object contains all the customizable properties of the button.
    @ObservedObject private var externalConfig: IconButtonComponentConfig

    /// A closure that is called when the button appears on screen, passing the current configuration.
    /// This allows parent views to react to the button's appearance and modify its configuration if needed.
    public let onSelfAppear: (IconButtonComponentConfig) -> Void

    /// A closure to execute when the button is tapped, passing the current configuration.
    /// This async closure can throw errors and is executed within a task to handle loading states.
    public let action: () async throws -> Void

    /// A closure that allows modification of the button's configuration before the main action is executed.
    /// This is useful for updating the button's state or appearance before performing the main action.
    public var configAction: (IconButtonComponentConfig) -> Void = { _ in }

    // MARK: - 1. Initializer with external config

    /// Initializes the IconButtonComponent with an external configuration.
    /// This initializer provides full control over the button's configuration through an external config object.
    ///
    /// - Parameters:
    ///   - config: The external configuration that defines the button's appearance and behavior.
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        config: IconButtonComponentConfig,
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        action: @escaping () async throws -> Void = {}
    ) {
        externalConfig = config
        self.onSelfAppear = onSelfAppear
        self.action = action
    }

    // MARK: - 2. Initializer with default internal config

    /// Initializes the IconButtonComponent with a default internal configuration.
    /// This initializer creates a new configuration with a specified default icon.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - defaultIcon: The default icon to display (default is `.unknown`).
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        defaultIcon: DesignIcons = .unknown,
        action: @escaping () async throws -> Void = {}
    ) {
        self.onSelfAppear = onSelfAppear
        self.action = action

        // Initialize with default configuration and set the specified icon
        _externalConfig = .init(initialValue: .init())
        externalConfig.icon = defaultIcon
    }

    // MARK: - 3. Initializer with config and config action

    /// Initializes the IconButtonComponent with a configuration and config action.
    /// This initializer is useful when the button needs to perform configuration updates before the main action.
    ///
    /// - Parameters:
    ///   - config: The initial configuration for the button (default is a new instance).
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - configAction: A closure to modify the configuration before the main action (default is no-op).
    public init(
        config: IconButtonComponentConfig = .init(),
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        configAction: @escaping (IconButtonComponentConfig) -> Void = { _ in }
    ) {
        self.onSelfAppear = onSelfAppear
        self.configAction = configAction
        action = {}

        externalConfig = config
    }

    // MARK: - Body

    /// The view body that represents the button. It renders a button frame with the specified icon.
    /// The body handles the button's appearance, loading states, and action execution.
    ///
    /// - Returns: A Button view wrapped in a custom frame, displaying the icon and triggering the associated action.
    public var body: some View {
        ButtonFrameComponent(
            config: externalConfig,
            action: ({
                // Execute the config action before the main action
                configAction(externalConfig)

                // Create a task to handle the async action
                Task {
                    do {
                        print("starting action")
                        externalConfig.isLoading = true
                        try await action()
                        print("finished action action")
                        externalConfig.isLoading = false
                    } catch {
                        // Ensure loading state is reset on error
                        externalConfig.isLoading = false
                        throw error
                    }
                }
            })
        ) {
            if externalConfig.isLoading {
                // Display loading indicator when action is in progress
                ProgressView()
            } else {
                // Display the icon with appropriate styling when not loading
                externalConfig.icon.image
                    .foregroundStyle(DesignTokens.colors.textDark)
            }
        } onSelfAppear: { _ in
            onSelfAppear(externalConfig)
        }
    }
}
