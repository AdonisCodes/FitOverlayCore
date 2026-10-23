// AnyOrientationStackComponentConfig.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the available stack orientations for the AnyOrientationStackComponent
public enum AnyOrientationStackComponentVariants {
    /// Horizontal stack that arranges views in a row
    case hstack
    /// Vertical stack that arranges views in a column
    case vstack
    /// Depth-based stack that overlays views on top of each other
    case zstack
}

/// Configuration class for AnyOrientationStackComponent that manages the layout properties
/// of different stack types (HStack, VStack, ZStack).
///
/// This class provides reactive properties for controlling stack orientation, alignment, and spacing.
public class AnyOrientationStackComponentConfig: ObservableObject {
    /// The current stack orientation variant
    /// Defaults to vertical stack (.vstack)
    @Published public var variant: AnyOrientationStackComponentVariants = .vstack

    /// Horizontal alignment for vertical stack layout
    /// Controls the positioning of elements along the horizontal axis when in VStack mode
    @Published public var vstackAlignment: HorizontalAlignment

    /// Vertical alignment for horizontal stack layout
    /// Controls the positioning of elements along the vertical axis when in HStack mode
    @Published public var hstackAlignment: VerticalAlignment

    /// The spacing between elements in the stack
    /// Applies to both HStack and VStack layouts
    @Published public var spacing: CGFloat

    /// Initializes a new stack component configuration
    /// - Parameters:
    ///   - variant: The stack orientation to use (default: .vstack)
    ///   - vstackAlignment: Horizontal alignment for vertical stack (default: .leading)
    ///   - hstackAlignment: Vertical alignment for horizontal stack (default: .bottom)
    ///   - spacing: Space between stack elements (default: 0)
    public init(
        variant: AnyOrientationStackComponentVariants = .vstack,
        vstackAlignment: HorizontalAlignment = .leading,
        hstackAlignment: VerticalAlignment = .bottom,
        spacing: CGFloat = 0
    ) {
        // Initialize stack configuration with provided or default values
        self.variant = variant
        self.vstackAlignment = vstackAlignment
        self.hstackAlignment = hstackAlignment
        self.spacing = spacing
    }

    /// Cleanup method called when the instance is being deallocated
    deinit {
        return
    }
}
