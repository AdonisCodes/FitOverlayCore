// Helpers.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SimpleKeychain
import SwiftUI

#if canImport(UIKit)
    import UIKit

    /// Extension to UIApplication that provides additional functionality for handling keyboard input
    public extension UIApplication {
        /// Dismisses the keyboard by resigning the first responder status
        /// This method can be called from anywhere in the app to dismiss the keyboard
        func endEditing() {
            // Sends a resign first responder action through the responder chain
            sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif

/// Dismisses the keyboard / resigns first responder in a platform-appropriate way.
/// On macOS this is a no-op since AppKit manages the field editor itself.
@MainActor
public func dismissKeyboard() {
    #if canImport(UIKit)
        UIApplication.shared.endEditing()
    #endif
}

/// Opens an external URL in the default browser / App Store in a platform-appropriate way.
/// - Parameter url: The URL to open
@MainActor
public func openExternalURL(_ url: URL) {
    #if canImport(UIKit)
        UIApplication.shared.open(url)
    #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
    #endif
}

/// A helper class that provides methods for securely storing and retrieving data from the keychain
/// This class is marked with @MainActor to ensure all operations are performed on the main thread
@MainActor
public class KeychainHelper {
    /// Enumeration of available keychain keys for storing different types of tokens
    public enum KeyChainKeys: String {
        /// Key for storing the authentication token
        case authenticationToken
        /// Key for storing the refresh token
        case refreshToken
        /// Key for storing the FitOverlay licence key
        case licenseKey
    }

    /// Static instance of SimpleKeychain configured to only be accessible after first unlock of the device
    public static var keychain = SimpleKeychain(
        accessibility: .afterFirstUnlockThisDeviceOnly
    )

    /// Retrieves a string value from the keychain for the specified key
    /// - Parameter key: The keychain key to retrieve the value for
    /// - Returns: The string value if it exists, nil otherwise
    public static func get(for key: KeyChainKeys) -> String? {
        try? keychain.string(forKey: key.rawValue)
    }

    /// Stores a string value in the keychain for the specified key
    /// - Parameters:
    ///   - key: The keychain key to store the value for
    ///   - value: The string value to store
    /// - Returns: Boolean indicating whether the operation was successful
    @discardableResult
    public static func set(for key: KeyChainKeys, value: String) -> Bool {
        (
            try? keychain.set(value, forKey: key.rawValue)
        ) != nil
    }

    /// Deletes the value associated with the specified key from the keychain
    /// - Parameter key: The keychain key whose value should be deleted
    public static func delete(for key: KeyChainKeys) {
        try? keychain.deleteItem(forKey: key.rawValue)
    }

    deinit {
        return
    }
}
