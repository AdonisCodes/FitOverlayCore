// PhoneNumberTextInputComponentConfig.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the available variants for the phone number text input component
public enum PhoneNumberTextInputComponentVariants {}

/// Configuration class for the phone number text input component
/// This class manages the state and behavior of a phone number input field,
/// including validation and error message handling
public class PhoneNumberTextInputComponentConfig: TextInputComponentConfig {
    /// The current phone number value that is being input
    /// This property is published to allow for reactive updates
    @Published public var phoneNumber: String

    /// Number of validation attempts allowed before showing error message
    /// Decrements each time validation occurs until it reaches 0
    public var timesUntilShowErrorMessage = 2

    /// Indicates whether the current phone number is valid
    /// When this value changes, it triggers error message updates based on validation count
    @Published public var isValid: Bool {
        didSet {
            // Log validation state change
            print("is valid changed \(isValid)")

            // Check if we should delay showing error message
            if timesUntilShowErrorMessage > 0 {
                timesUntilShowErrorMessage -= 1
                return
            }

            // Update error message based on validation state
            if !isValid {
                errorMessage = "Invalid Phone Number"
                return
            }

            errorMessage = ""
        }
    }

    /// Initializes a new phone number text input component configuration
    /// - Parameters:
    ///   - phoneNumber: Initial phone number value, defaults to "+1"
    ///   - isValid: Initial validation state, defaults to false
    public init(phoneNumber: String = "+1", isValid: Bool = false) {
        self.phoneNumber = phoneNumber
        self.isValid = isValid

        super.init(
            title: "Phone Number"
        )
    }

    /// Cleanup when the instance is being deallocated
    deinit {
        return
    }
}
