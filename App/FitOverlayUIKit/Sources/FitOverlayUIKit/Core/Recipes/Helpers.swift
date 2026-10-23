// Helpers.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Extension to SwiftUI's Color type that adds hex color code initialization support
public extension Color {
    /// Initializes a Color instance from a hexadecimal color string
    /// - Parameter hex: A string representing a hex color code. Supports 3-digit RGB (12-bit),
    ///                 6-digit RGB (24-bit), and 8-digit ARGB (32-bit) formats
    /// - Note: Valid formats are: "RGB", "RRGGBB", "AARRGGBB"
    init(hex: String) {
        // Remove any non-alphanumeric characters from the hex string
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        // Convert hex string to integer
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64

        // Parse hex string based on its length
        switch hex.count {
        case 3: // RGB (12-bit)
            // Multiply by 17 to convert 4-bit to 8-bit color values
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            // Default to white with zero opacity for invalid formats
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        // Initialize color with normalized RGB values
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

/// Internal enum containing helper methods for image manipulation in the design system
internal enum DesignImages {
    /// Applies standard icon styling to an image
    /// - Parameter image: The SwiftUI Image to be styled
    /// - Returns: A View with the image styled according to design system specifications
    public static func iconManipulation(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: DesignTokens.icons.defaultWidth,
                height: DesignTokens.icons.defaultHeight
            )
            .padding(0)
    }
}

/// Extension to SwiftUI's Image type that adds design system conformance
public extension Image {
    /// Converts the image into an icon conforming to the design system specifications
    /// - Returns: A View containing the image styled as a system icon
    func toIcon() -> some View {
        DesignImages
            .iconManipulation(self)
    }
}
