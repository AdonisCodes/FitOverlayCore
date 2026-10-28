// Initialization.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif

/// Extension to SwiftUI's View protocol providing platform-specific utility functions
public extension View {
    /// Determines if the current platform is macOS
    ///
    /// This function checks the current operating system and returns a boolean value
    /// indicating whether the code is running on macOS.
    ///
    /// - Returns: `true` if running on macOS, `false` if running on iOS
    func isMacOS() -> Bool {
        #if os(iOS)
            // Return false when running on iOS platform
            return false
        #else
            // Return true for macOS platform
            return true
        #endif
    }

    /// Retrieves the screen bounds or visible frame based on the platform
    ///
    /// This function returns the appropriate rectangle representing the screen dimensions:
    /// - On iOS: Returns the main screen bounds
    /// - On macOS: Returns the visible frame of the main screen
    ///
    /// - Returns: A `CGRect` representing the screen dimensions
    func getRect() -> CGRect? {
        #if os(iOS)
            // Return the bounds of the main screen on iOS
            return UIScreen.main.bounds
        #endif

        #if canImport(AppKit)
            // Return the visible frame of the main screen on macOS
            return NSScreen.main?.visibleFrame
        #endif
    }
}
