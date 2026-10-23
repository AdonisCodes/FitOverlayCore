// TextInputComponent.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A customizable text input component that displays a title, input field, and error message.
/// This component is designed to provide a consistent text input experience across the application.
public struct TextInputComponent: View {
    /// The configuration object that controls the appearance and behavior of the text input component.
    @ObservedObject public var config: TextInputComponentConfig

    /// Callback closure that is executed when the icon in the text input is tapped.
    /// - Parameter config: The current configuration of the text input component.
    public let onIconTap: (TextInputComponentConfig) -> Void

    /// Callback closure that is executed when the text input component appears.
    /// - Parameter config: The current configuration of the text input component.
    public let onSelfAppear: (TextInputComponentConfig) -> Void

    /// Initializes a new text input component with the specified configuration and callbacks.
    /// - Parameters:
    ///   - config: The configuration object for the text input component. Defaults to a new instance.
    ///   - onIconTap: The closure to execute when the icon is tapped. Defaults to an empty closure.
    ///   - onSelfAppear: The closure to execute when the component appears. Defaults to an empty closure.
    public init(
        config: TextInputComponentConfig = .init(),
        onIconTap: @escaping (TextInputComponentConfig) -> Void = { _ in },
        onSelfAppear: @escaping (TextInputComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onIconTap = onIconTap
        self.onSelfAppear = onSelfAppear
    }

    /// The body of the view that defines the component's layout and appearance.
    public var body: some View {
        VStack(alignment: .leading) {
            // Display the title if it's not empty
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(config.titleContentFont, config.titleSegmentColor)
            }

            // Display the main text input frame component
            TextInputFrameComponent(
                config: config,
                onIconTap: { onIconTap(config) },
                onSelfAppear: { onSelfAppear(config) }
            )

            // Display the error message with appropriate styling
            Text("\(config.errorMessage) ")
                .fontTableFont(
                    config.titleContentFont,
                    config.errorSegmentColor
                )
        }
    }
}
