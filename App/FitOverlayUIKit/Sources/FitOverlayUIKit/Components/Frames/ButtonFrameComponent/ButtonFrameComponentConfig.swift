// ButtonFrameComponentConfig.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the available visual variants for button frames
///
/// This enum provides different styling options for button frames:
/// - `disabled`: Represents a non-interactive button state
/// - `generic`: The default button appearance
/// - `rainbow`: A decorative button style with rainbow effects
public enum ButtonFrameVariants: String, CaseIterable {
    case disabled
    case generic
    case rainbow
}

/// Configuration class for customizing button frame appearance and behavior
///
/// This class manages the visual and behavioral properties of button frames,
/// including variant selection, spacing, shape, and colors.
public class ButtonFrameComponentConfig: ObservableObject {
    /// The currently selected button frame variant
    ///
    /// Changes to this property will be logged to the console
    @Published public var frameVariant: ButtonFrameVariants = .generic {
        didSet {
            print("Variant From ButtonFrame is \(frameVariant)")
        }
    }

    /// Determines if the button should fill its container width
    @Published public var fillSpace: Bool = true

    /// Determines if the button should have a circular shape
    @Published public var isCircular: Bool = false

    /// The corner radius of the button frame
    @Published public var roundness = DesignTokens.defaultCornerRadius

    /// The background color for the generic variant
    @Published public var variantGenericBackground = DesignTokens.colors.primary

    /// The background color for the disabled variant
    @Published public var variantDisabledBackground = DesignTokens.colors.primaryWhitespace3

    /// The default padding applied to the button frame
    @Published public var defaultPadding = DesignTokens.padding.button

    /// Initializes a new button frame configuration
    ///
    /// - Parameters:
    ///   - frameVariant: The initial variant of the button frame
    ///   - fillSpace: Whether the button should fill its container width
    ///   - isCircular: Whether the button should have a circular shape
    ///   - roundness: The corner radius of the button
    ///   - variantGenericBackground: The background color for generic variant
    ///   - variantDisabledBackground: The background color for disabled variant
    ///   - defaultPadding: The default padding applied to the button
    public init(
        frameVariant: ButtonFrameVariants = .generic,
        fillSpace: Bool = true,
        isCircular: Bool = false,
        roundness: CGFloat = DesignTokens.defaultCornerRadius,
        variantGenericBackground: Color = DesignTokens.colors.primary,
        variantDisabledBackground: Color = DesignTokens.colors.primaryWhitespace3,
        defaultPadding: EdgeInsets = DesignTokens.padding.button
    ) {
        // Log the initialization of the component
        print("calling initializer \(frameVariant)")

        // Initialize all properties with provided or default values
        self.frameVariant = frameVariant
        self.fillSpace = fillSpace
        self.isCircular = isCircular
        self.roundness = roundness
        self.variantGenericBackground = variantGenericBackground
        self.variantDisabledBackground = variantDisabledBackground
        self.defaultPadding = defaultPadding
    }

    /// Cleanup when the instance is being deallocated
    deinit {
        return
    }
}
