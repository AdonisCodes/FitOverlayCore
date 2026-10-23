// InfoPairComponent.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/**
 The `InfoPairComponent` is a UI element that renders a title + subtext.

 The component can be used for the following:
 - To render out a title + description information for onboarding screens
 - To render a title & subtext component for a description page

 For more information on how to use this, take a look at `InfoPairComponentDocumentation.md`
 */
public struct InfoPairComponent: View {
    /// The configuration object that contains the title and description for the component
    @ObservedObject public var config: InfoPairComponentConfig

    /// Callback closure that is called when the view appears
    /// - Parameter config: The current configuration of the InfoPairComponent
    public let onSelfAppear: (InfoPairComponentConfig) -> Void

    /// Initializes a new InfoPairComponent
    /// - Parameters:
    ///   - config: The configuration object containing the title and description. Defaults to empty configuration.
    ///   - onSelfAppear: Closure that is called when the view appears. Defaults to empty closure.
    public init(
        config: InfoPairComponentConfig = .init(),
        onSelfAppear: @escaping (InfoPairComponentConfig) -> Void = { _ in }
    ) {
        // Initialize the observed object with the provided configuration
        _config = .init(initialValue: config)

        // Store the onSelfAppear closure
        self.onSelfAppear = onSelfAppear
    }

    /// The body of the view that defines its content and layout
    public var body: some View {
        // Create a vertical stack with leading alignment
        VStack(alignment: .leading) {
            // Title text view with custom font and styling
            Text(config.title)
                .fontTableFont(
                    FontTable.Crimson.Headings.head4,
                    DesignTokens.colors.primaryText
                )
                .tag("title")
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            // Description text view with custom font and styling
            Text(config.description)
                .fontTableFont(
                    FontTable.Crimson.Body.body1,
                    DesignTokens.colors.secondaryText
                )
                .tag("description")
                .lineLimit(3)
                .minimumScaleFactor(0.5)
        }.onAppear {
            // Call the onSelfAppear closure when the view appears
            onSelfAppear(config)
        }
    }
}
