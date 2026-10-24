// TextInputFrameComponentPreviews.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the TextInputFrameComponent
/// This struct provides SwiftUI previews for the TextInputFrameComponent
/// allowing developers to see how the component looks and behaves in different states
public struct TextInputFrameComponentPreviews: PreviewProvider {
    /// The preview content for the TextInputFrameComponent
    /// - Returns: A view containing the TextInputFrameComponentPropertyEditor
    public static var previews: some View {
        TextInputFrameComponentPropertyEditor()
    }
}

/// A property editor view for TextInputFrameComponent
/// This view provides a UI for editing various properties of the TextInputFrameComponent
/// and displays a live preview of the component with the current settings
public struct TextInputFrameComponentPropertyEditor: View {
    /// The configuration object that holds all the editable properties
    /// Uses @StateObject to maintain state across view updates
    @StateObject private var config = TextInputFrameComponentConfig()

    /// The main view body that constructs the property editor interface
    /// - Returns: A view containing the property editor and preview
    public var body: some View {
        // Create a property editor with configurable fields
        PropertyEditor(
            object: config,
            properties: [
                // Define all editable properties with their respective keypaths
                [AnyKeyPath("Text", keyPath: \.text)],
                [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
                [AnyKeyPath("Has Icon", keyPath: \.hasIcon)],
                [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
                [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
                [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
                [AnyKeyPath("Text Color", keyPath: \.textColor)],
                [AnyKeyPath("Padding", keyPath: \.padding)],
                [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
            ]
        ) {
            // Preview section showing the component and additional controls
            VStack {
                // Display the actual TextInputFrameComponent with current configuration
                TextInputFrameComponent(config: config)

                // Variant selector using enum property view
                EnumPropertyView(
                    value: $config.variant,
                    cases: TextInputFrameComponentVariants.allCases
                )

                // Icon selector using enum property view
                EnumPropertyView(
                    value: $config.icon,
                    cases: DesignIcons.allCases
                )
            }
        }
    }
}
