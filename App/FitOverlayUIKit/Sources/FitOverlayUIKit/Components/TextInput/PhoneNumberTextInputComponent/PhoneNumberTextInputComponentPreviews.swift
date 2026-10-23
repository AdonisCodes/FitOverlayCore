// PhoneNumberTextInputComponentPreviews.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

#if !os(macOS)
    /// A preview provider for the PhoneNumberTextInputComponent.
    /// This struct provides SwiftUI previews to visualize the component in different states.
    public struct PhoneNumberTextInputComponentPreviews: PreviewProvider {
        /// The static previews property required by PreviewProvider protocol.
        /// Returns a view containing the phone number input component preview.
        ///
        /// - Returns: A view wrapped in the PhoneNumberTextInputComponentWrapperView.
        public static var previews: some View {
            PhoneNumberTextInputComponentWrapperView()
        }
    }

    /// A wrapper view that contains the preview implementation for PhoneNumberTextInputComponent.
    /// This view provides a testing environment for the phone number input component.
    public struct PhoneNumberTextInputComponentWrapperView: View {
        /// The body property required by the View protocol.
        /// Configures and displays the phone number input component with default settings.
        ///
        /// - Returns: A view containing the configured PhoneNumberTextInputComponent.
        public var body: some View {
            // Note: Commented code below represents additional configuration options
            // that can be uncommented and modified for testing different component states

//        PropertyEditor(
//            object: config,
//            properties: [
//                [AnyKeyPath("Title", keyPath: \.title)],
//                [AnyKeyPath("Error Message", keyPath: \.errorMessage)],
//                [
//                    AnyKeyPath(
//                        "TitleColor",
//                        keyPath: \.titleSegmentColor
//                    ),
//                    AnyKeyPath("ErrorColor", keyPath: \.errorSegmentColor),
//                ],
//                [AnyKeyPath("Text", keyPath: \.text)],
//                [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
//                [AnyKeyPath("Has Icon", keyPath: \.hasIcon)],
//                [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
//                [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
//                [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
//                [AnyKeyPath("Text Color", keyPath: \.textColor)],
//                [AnyKeyPath("Padding", keyPath: \.padding)],
//                [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
//            ]
//        ) {
//            VStack {
//                PhoneNumberTextInputComponent(config: config)
//
//                EnumPropertyView(
//                    value: $config.variant,
//                    cases: TextInputFrameComponentVariants.allCases
//                )
//
//                EnumPropertyView(
//                    value: $config.icon,
//                    cases: DesignIcons.allCases
//                )
//            }

            // Creates a basic preview of the phone number input component
            // with default configuration, padding, and dark color scheme
            PhoneNumberTextInputComponent(config: .init()).padding().preferredColorScheme(.dark)
        }
    }
#endif
