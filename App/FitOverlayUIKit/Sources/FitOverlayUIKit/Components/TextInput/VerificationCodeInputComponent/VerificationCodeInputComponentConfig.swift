// VerificationCodeInputComponentConfig.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the available variants for the verification code input component
///
/// Currently supports:
/// - generic: The default variant for verification code input
public enum VerificationCodeInputComponentVariants {
    /// Standard verification code input appearance
    case generic
}

/// Configuration class for the verification code input component
///
/// This class extends `TextInputComponentConfig` to provide specific configuration
/// options for verification code input fields, such as separator icons between code segments.
public class VerificationCodeInputComponentConfig: TextInputComponentConfig {
    /// The icon used to separate individual code segments
    ///
    /// This published property allows real-time updates to the separator appearance
    @Published public var separatorIcon: DesignIcons

    /// Initializes a new verification code input component configuration
    ///
    /// - Parameter separatorIcon: The icon to be used as a separator between code segments
    ///                           Defaults to `.subtraction`
    public init(
        separatorIcon: DesignIcons = .subtraction
    ) {
        // Initialize the separator icon property
        self.separatorIcon = separatorIcon

        // Call parent class initializer
        super.init()

        // Set default separator text
        text = " - "
    }

    /// Cleanup when the instance is being deallocated
    deinit {
        return
    }
}
