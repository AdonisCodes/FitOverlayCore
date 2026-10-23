// TextInputFrameComponentConfig.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the available variants for the text input frame component
/// - disabled: Represents a disabled state of the text input
/// - generic: Represents the default state of the text input
public enum TextInputFrameComponentVariants: String, CaseIterable {
    case disabled
    case generic
}

/// Configuration class for the text input frame component
/// Manages the appearance and behavior of a text input frame
public class TextInputFrameComponentConfig: ObservableObject {
    /// The current text value of the input field
    @Published public var text: String

    /// Placeholder text shown when the input field is empty
    @Published public var ghostText: String

    /// Icon displayed in the text input frame
    @Published public var icon: DesignIcons

    /// Determines if the icon should be displayed
    @Published public var hasIcon: Bool

    /// The background color of the text input frame
    @Published public var backgroundColor: Color

    /// The current background color, which changes based on the component's state
    @Published public var currentBackgroundColor: Color

    /// The background color used when the component is disabled
    @Published public var disabledBackgroundColor: Color

    /// The color of the text in the input field
    @Published public var textColor: Color

    /// The padding applied to the text input frame
    @Published public var padding: EdgeInsets

    /// The corner radius of the text input frame
    @Published public var cornerRadius: CGSize
    /// The current variant of the text input frame
    /// Updates the background color when changed
    @Published public var variant: TextInputFrameComponentVariants {
        willSet {
            // Update the current background color based on the new variant
            switch newValue {
            case .generic:
                currentBackgroundColor = backgroundColor
            case .disabled:
                currentBackgroundColor = disabledBackgroundColor
            }
        }
    }

    /// Indicates whether the text input frame is currently disabled
    public var isDisabled: Bool {
        variant == .disabled
    }

    /// Initializes a new text input frame component configuration
    /// - Parameters:
    ///   - text: The initial text value
    ///   - ghostText: The placeholder text
    ///   - icon: The icon to display
    ///   - hasIcon: Whether to show the icon
    ///   - variant: The initial variant of the component
    ///   - backgroundColor: The background color for normal state
    ///   - disabledBackgroundColor: The background color for disabled state
    ///   - textColor: The color of the input text
    ///   - padding: The padding around the content
    ///   - cornerRadius: The corner radius of the frame
    public init(
        text: String = "",
        ghostText: String = "Hello There!",
        icon: DesignIcons = .arrowRight,
        hasIcon: Bool = true,
        variant: TextInputFrameComponentVariants = .generic,
        backgroundColor: Color = DesignTokens.colors.primaryWhitespace2,
        disabledBackgroundColor: Color = DesignTokens.colors.primaryWhitespace3,
        textColor: Color = DesignTokens.colors.primaryText,
        padding: EdgeInsets = DesignTokens.padding.smallPaddingVar,
        cornerRadius: CGSize = DesignTokens.padding.cornerRadiusBase
    ) {
        // Initialize all properties with provided or default values
        self.text = text
        self.ghostText = ghostText
        self.icon = icon
        self.hasIcon = hasIcon
        self.variant = variant
        self.backgroundColor = backgroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        currentBackgroundColor = backgroundColor
        self.textColor = textColor
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    deinit {
        return
    }
}
