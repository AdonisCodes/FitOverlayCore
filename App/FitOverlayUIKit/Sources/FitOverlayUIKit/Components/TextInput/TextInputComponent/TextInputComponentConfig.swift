// TextInputComponentConfig.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the variants available for text input components
public enum TextInputComponentVariants {}

/// Configuration class for text input components that inherits from TextInputFrameComponentConfig
/// Manages the appearance and content of text input UI elements
public class TextInputComponentConfig: TextInputFrameComponentConfig {
    /// The title text to be displayed for the text input
    @Published public var title: String

    /// Error message to be shown when validation fails
    @Published public var errorMessage: String

    /// Font style for the title content
    @Published public var titleContentFont: IsFontTableFont

    /// Color for the title segment
    @Published public var titleSegmentColor: Color

    /// Color used for displaying error messages
    @Published public var errorSegmentColor: Color

    /// Initializes a new TextInputComponentConfig instance
    /// - Parameters:
    ///   - title: The title text for the input field. Defaults to empty string
    ///   - errorMessage: The error message to display. Defaults to empty string
    ///   - titleContentFont: Font style for the title. Defaults to SFPro Body3
    ///   - titleSegmentColor: Color for the title. Defaults to primary text color
    ///   - errorSegmentColor: Color for error messages. Defaults to error color
    public init(
        title: String = "",
        errorMessage: String = "",
        titleContentFont: IsFontTableFont = FontTable.SFPro.Body.body3,
        titleSegmentColor: Color = DesignTokens.colors.primaryText,
        errorSegmentColor: Color = DesignTokens.colors.error
    ) {
        // Initialize all properties with provided or default values
        self.title = title
        self.errorMessage = errorMessage
        self.titleContentFont = titleContentFont
        self.titleSegmentColor = titleSegmentColor
        self.errorSegmentColor = errorSegmentColor
    }

    /// Cleanup when the instance is being deallocated
    deinit {
        return
    }
}
