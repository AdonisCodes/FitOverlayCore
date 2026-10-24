// IconButtonComponentConfig.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Enum defining the different variants of the IconButton component.
/// Used to specify the visual appearance and shape of the button.
///
/// - circle: A circular button with equal width and height
/// - generic: A standard button with default styling
/// - pill: An elongated button with fully rounded corners
/// - square: A square button with slight corner radius
public enum IconButtonVariants: String, CaseIterable {
    case circle
    case generic
    case pill
    case square
}

/// Configuration class for the IconButtonComponent that extends from `ButtonFrameComponentConfig`.
/// Provides customization options for the button's visual style, state, and icon.
///
/// This class manages:
/// - Button variant (shape and layout)
/// - Enabled/disabled state
/// - Icon display
/// - Loading state
public class IconButtonComponentConfig: ButtonFrameComponentConfig {
    /// The variant of the button that determines its shape and layout style.
    /// Changes to this property automatically trigger variant-specific styling updates.
    ///
    /// Default value is `.generic`
    @Published public var variant: IconButtonVariants = .generic {
        didSet {
            applyVariantStyling()
        }
    }

    /// Controls the enabled/disabled state of the button.
    /// When true, the button becomes inactive and visually indicates its disabled state.
    ///
    /// Default value is `true`
    @Published public var isDisabled: Bool = true {
        didSet {
            manageDisabledState()
        }
    }

    /// The icon to be displayed on the button.
    /// Represents the visual symbol shown within the button's bounds.
    ///
    /// Default value is `.unknown`
    @Published public var icon: DesignIcons = .unknown

    /// Indicates whether the button is in a loading state.
    /// Can be used to show loading indicators or disable interactions while processing.
    ///
    /// Default value is `false`
    @Published public var isLoading: Bool = false

    /// Initializes a new instance of IconButtonComponentConfig with default settings.
    ///
    /// This initializer:
    /// 1. Calls the superclass initializer
    /// 2. Applies the default variant styling
    public init() {
        print("init icon config")
        super.init()
        applyVariantStyling()
    }

    /// Applies styling properties based on the current button variant.
    ///
    /// This method configures:
    /// - Circularity (isCircular)
    /// - Corner radius (roundness)
    /// - Space filling behavior (fillSpace)
    /// - Padding values (defaultPadding)
    ///
    /// The styling is determined by the current `variant` property value.
    public func applyVariantStyling() {
        switch variant {
        case .generic:
            // Apply standard button styling with default corner radius
            isCircular = false
            roundness = DesignTokens.defaultCornerRadius
            fillSpace = true
        case .square:
            // Apply square styling with fixed padding and corner radius
            isCircular = false
            roundness = DesignTokens.defaultCornerRadius
            fillSpace = false
            defaultPadding = DesignTokens.padding.buttonEven
        case .circle:
            // Apply circular styling with equal padding
            isCircular = true
            fillSpace = false
            defaultPadding = DesignTokens.padding.buttonEven
        case .pill:
            // Apply pill-shaped styling with standard button padding
            isCircular = true
            fillSpace = true
            defaultPadding = DesignTokens.padding.button
        }
    }

    /// Updates the button's frame variant based on its disabled state.
    ///
    /// This method:
    /// - Sets frame variant to `.disabled` when button is disabled
    /// - Sets frame variant to `.generic` when button is enabled
    public func manageDisabledState() {
        print("Icon Button Setting Variant to \(isDisabled)")
        frameVariant = isDisabled ? .disabled : .generic
    }

    /// Cleanup method called when the instance is being deallocated.
    deinit {
        return
    }
}
