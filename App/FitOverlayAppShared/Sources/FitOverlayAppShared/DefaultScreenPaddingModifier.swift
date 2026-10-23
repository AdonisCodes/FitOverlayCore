// DefaultScreenPaddingModifier.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A view modifier that applies default screen padding to content
///
/// This modifier applies consistent horizontal and vertical padding values that are
/// suitable for most screen content in the app.
///
/// Usage:
/// ```
/// Text("Hello World")
///     .modifier(DefaultScreenPaddingModifier())
/// ```
internal struct DefaultScreenPaddingModifier: ViewModifier {
    /// Applies the default screen padding modification to the given content
    ///
    /// - Parameter content: The content to which the padding will be applied
    /// - Returns: A modified view with standard horizontal (30 points) and vertical (50 points) padding
    public func body(content: Content) -> some View {
        // Apply horizontal padding of 30 points
        // Apply vertical padding of 50 points
        content
            .padding(.horizontal, 30)
            .padding(.vertical, 50)
    }
}

/// Extension to provide a convenient modifier method for default screen padding
public extension View {
    /// Applies the default screen padding to the view
    ///
    /// This method provides a more convenient way to apply the default screen padding
    /// compared to using the modifier directly.
    ///
    /// Usage:
    /// ```
    /// Text("Hello World")
    ///     .defaultScreenPadding()
    /// ```
    ///
    /// - Returns: A view modified with the default screen padding
    func defaultScreenPadding() -> some View {
        modifier(DefaultScreenPaddingModifier())
    }
}
