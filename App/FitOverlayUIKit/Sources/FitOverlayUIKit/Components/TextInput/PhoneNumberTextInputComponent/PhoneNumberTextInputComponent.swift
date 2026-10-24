// PhoneNumberTextInputComponent.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import PhoneNumberKit
import SwiftUI

// Check if it is macOS
#if !os(macOS)
    /// A UIViewRepresentable wrapper for PhoneNumberTextField that handles phone number input and validation
    public struct PhoneNumberTextFieldView: UIViewRepresentable {
        /// The configuration object that contains all the styling and state information
        @ObservedObject public var config: PhoneNumberTextInputComponentConfig

        /// The underlying PhoneNumberTextField instance
        private let textField = PhoneNumberTextField()

        /// Creates and configures the PhoneNumberTextField
        /// - Parameter context: The context in which the view is being created
        /// - Returns: A configured PhoneNumberTextField instance
        public func makeUIView(context: Context) -> PhoneNumberKit.PhoneNumberTextField {
            // Configure the text field with default settings
            textField.withExamplePlaceholder = true
            textField.withFlag = true
            textField.withPrefix = true
            textField.withDefaultPickerUI = true
            textField.placeholder = config.title
            textField.textColor = .init(config.textColor)
            textField.delegate = context.coordinator

            // Add target for text change events
            textField.addTarget(
                context.coordinator,
                action: #selector(Coordinator.textFieldDidChange(_:)),
                for: .editingChanged
            )
            return textField
        }

        /// Updates the UIView when the SwiftUI view updates
        /// - Parameters:
        ///   - uiView: The PhoneNumberTextField to update
        ///   - context: The context in which the update is occurring
        public func updateUIView(
            _ uiView: PhoneNumberKit.PhoneNumberTextField, context _: Context
        ) {
            // Update text only if it differs from current value
            if uiView.text != config.phoneNumber {
                uiView.text = config.phoneNumber
            }
        }

        /// Coordinator class that handles the delegation and communication between UIKit and SwiftUI
        public class Coordinator: NSObject, UITextFieldDelegate {
            /// The configuration object shared with the parent view
            @ObservedObject public var config: PhoneNumberTextInputComponentConfig

            /// Initializes the coordinator with the given configuration
            /// - Parameter config: The configuration object to use
            public init(config: PhoneNumberTextInputComponentConfig) {
                self.config = config
            }

            /// Handles text field changes and updates the configuration
            /// - Parameter textField: The text field that changed
            @objc
            public func textFieldDidChange(_ textField: UITextField) {
                // Update phone number in config
                config.phoneNumber = textField.text ?? ""

                // Validate phone number if possible
                if let phoneTextField = textField as? PhoneNumberTextField {
                    config.isValid = phoneTextField.isValidNumber
                } else {
                    config.isValid = false
                }
            }

            deinit {
                return
            }
        }

        /// Creates a coordinator for this view
        /// - Returns: A new coordinator instance
        public func makeCoordinator() -> Coordinator {
            Coordinator(config: config)
        }
    }

    /// A SwiftUI view component that provides phone number input functionality
    public struct PhoneNumberTextInputComponent: View {
        /// The configuration object that contains all the styling and state information
        @ObservedObject public var config: PhoneNumberTextInputComponentConfig

        /// Initializes the phone number input component
        /// - Parameter config: The configuration object to use
        public init(
            config: PhoneNumberTextInputComponentConfig
        ) {
            self.config = config
        }

        /// The body of the view containing the phone number input field and associated UI elements
        public var body: some View {
            VStack(alignment: .leading) {
                // Display title if present
                if !config.title.isEmpty {
                    Text(config.title)
                        .fontTableFont(
                            config.titleContentFont, config.titleSegmentColor
                        )
                }

                // Phone number input field
                PhoneNumberTextFieldView(config: config)
                    .frame(height: 23)
                    .padding(config.padding)
                    .background(config.currentBackgroundColor)
                    .clipShape(RoundedRectangle(cornerSize: config.cornerRadius))

                // Error message display
                Text("\(config.errorMessage)")
                    .fontTableFont(
                        config.titleContentFont,
                        config.errorSegmentColor
                    )
            }
        }
    }
#endif
