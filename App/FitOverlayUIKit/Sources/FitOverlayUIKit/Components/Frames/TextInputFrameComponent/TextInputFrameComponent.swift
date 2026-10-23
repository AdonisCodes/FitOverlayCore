// TextInputFrameComponent.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/**
 The `TextInputFrameComponent` is a reusable SwiftUI component that provides a customizable \
 text input field with optional icon support.

 This component creates a text input field with configurable styling, \
 including background color, padding, corner radius,
 and optional icon placement. It supports both enabled and disabled states, \
 and allows for custom actions on icon tap and component appearance.

 Example usage:
 ```
 TextInputFrameComponent(
     config: TextInputFrameComponentConfig(),
     onIconTap: { print("Icon tapped") },
     onSelfAppear: { print("Component appeared") }
 )
 ```

 - Parameters:
    - config: Configuration object managing the component's state and appearance
    - onIconTap: Closure executed when the optional icon is tapped
    - onSelfAppear: Closure executed when the component appears in the view hierarchy
 - Returns: A view containing a styled text input field with optional icon

 To see usage examples & visuals, check out `TextInputFrameModifierDocumentation.md`
 */
public struct TextInputFrameComponent: View {
    /// Configuration object that manages the component's state and appearance
    @ObservedObject public var config: TextInputFrameComponentConfig

    /// Closure executed when the icon is tapped (if an icon is present)
    public let onIconTap: () -> Void

    /// Closure executed when the component appears in the view hierarchy
    public let onSelfAppear: () -> Void

    /**
     Initializes a new TextInputFrameComponent with the specified configuration and callbacks.

     - Parameters:
        - config: Configuration object for the component. Defaults to a new instance
        - onIconTap: Closure to execute when icon is tapped. Defaults to empty closure
        - onSelfAppear: Closure to execute when component appears. Defaults to empty closure
     */
    public init(
        config: TextInputFrameComponentConfig = .init(),
        onIconTap: @escaping () -> Void = {},
        onSelfAppear: @escaping () -> Void = {}
    ) {
        self.config = config
        self.onIconTap = onIconTap
        self.onSelfAppear = onSelfAppear
    }

    /// The component's body view implementation
    public var body: some View {
        HStack {
            // Conditionally render the icon if hasIcon is true
            if config.hasIcon {
                config.icon.image
                    .foregroundStyle(config.textColor)
                    .onTapGesture {
                        onIconTap()
                    }
            }
            // Create the text input field with ghost text and binding to config.text
            TextField(config.ghostText, text: $config.text)
                .disabled(config.isDisabled)
        }
        .padding(config.padding)
        .background(
            config.currentBackgroundColor
        )
        .clipShape(
            RoundedRectangle(
                cornerSize: config.cornerRadius
            )
        )
        .onAppear(perform: onSelfAppear)
    }
}
