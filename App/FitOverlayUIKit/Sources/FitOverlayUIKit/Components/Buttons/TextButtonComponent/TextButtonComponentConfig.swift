// TextButtonComponentConfig.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Enum defining the different variants of the TextButton component.
/// This enum provides various button shape options that can be used to customize the appearance of text buttons.
///
/// - circle: A circular button shape
/// - generic: A standard button shape with default styling
/// - pill: An elongated button with fully rounded ends
/// - square: A button with equal width and height
public enum TextButtonVariants: String, CaseIterable {
    case circle
    case generic
    case pill
    case square
}

/// Configuration class for the TextButtonComponent that extends from `ButtonFrameComponentConfig`.
/// This class manages the visual styling, state management, and text content of a text button component.
///
/// The configuration includes:
/// - Button variant selection (shape and layout)
/// - Enabled/disabled state management
/// - Button text content
/// - Variant-specific styling properties
public class TextButtonComponentConfig: ButtonFrameComponentConfig {
    /// The variant of the button that determines its shape and layout style.
    /// Changes to this property automatically trigger variant-specific styling updates.
    ///
    /// - Note: Default value is `.generic`
    @Published public var variant: TextButtonVariants = .generic {
        didSet {
            applyVariantStyling()
        }
    }

    /// Controls the enabled/disabled state of the button.
    /// When set to `true`, the button becomes inactive and its appearance is updated accordingly.
    ///
    /// - Note: Default value is `false` (enabled)
    @Published public var isDisabled: Bool = false {
        didSet {
            manageDisabledState()
        }
    }

    /// The text content displayed on the button.
    /// This property defines the button's label that will be shown to users.
    ///
    /// - Note: Default value is "Enter Text Here"
    @Published public var text: String = "Enter Text Here"

    /// Initializes a new instance of TextButtonComponentConfig with default settings.
    ///
    /// This initializer:
    /// 1. Calls the superclass initializer
    /// 2. Applies the default variant styling
    ///
    /// - Returns: A configured TextButtonComponentConfig instance
    public init() {
        super.init()
        applyVariantStyling()
    }

    /// Applies styling properties based on the current button variant.
    ///
    /// This method configures the following properties for each variant:
    /// - isCircular: Determines if the button has circular corners
    /// - roundness: The corner radius for non-circular variants
    /// - fillSpace: Whether the button should expand to fill available space
    /// - defaultPadding: The internal padding of the button
    public func applyVariantStyling() {
        switch variant {
        case .generic:
            // Apply standard button styling with default corner radius
            isCircular = false
            roundness = DesignTokens.defaultCornerRadius
            fillSpace = true
        case .square:
            // Apply square button styling with equal dimensions
            isCircular = false
            roundness = DesignTokens.defaultCornerRadius
            fillSpace = false
            defaultPadding = DesignTokens.padding.buttonEven
        case .circle:
            // Apply circular button styling
            isCircular = true
            fillSpace = false
            defaultPadding = DesignTokens.padding.buttonEven
        case .pill:
            // Apply pill-shaped button styling with rounded ends
            isCircular = true
            fillSpace = true
            defaultPadding = DesignTokens.padding.button
        }
    }

    /// Updates the button's frame variant based on its disabled state.
    ///
    /// This method:
    /// - Sets the frame variant to `.disabled` when the button is disabled
    /// - Sets the frame variant to `.generic` when the button is enabled
    ///
    /// - Note: This is automatically called when the `isDisabled` property changes
    public func manageDisabledState() {
        frameVariant = isDisabled ? .disabled : .generic
    }

    /// Cleanup method called when the instance is being deallocated
    deinit {
        return
    }
}
