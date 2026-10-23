// Fonts.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
    import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
    import UIKit.UIFont
#endif
#if canImport(SwiftUI)
    import SwiftUI
#endif

/// Deprecated font typealias that will be removed in SwiftGen 7.0
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
public typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command file_length implicit_return
// swiftlint:disable identifier_name line_length type_body_length

// MARK: - Fonts

/// Namespace containing all custom font families used in the application
internal enum FontFamily {
    /// The Crimson Text font family with its various styles
    public enum CrimsonText {
        /// Bold variant of Crimson Text font
        public static let bold = FontConvertible(
            name: "CrimsonText-Bold",
            family: "Crimson Text",
            path: "CrimsonText-Bold.ttf"
        )
        /// Bold italic variant of Crimson Text font
        public static let boldItalic = FontConvertible(
            name: "CrimsonText-BoldItalic",
            family: "Crimson Text",
            path: "CrimsonText-BoldItalic.ttf"
        )
        /// Italic variant of Crimson Text font
        public static let italic = FontConvertible(
            name: "CrimsonText-Italic",
            family: "Crimson Text",
            path: "CrimsonText-Italic.ttf"
        )
        /// Regular variant of Crimson Text font
        public static let regular = FontConvertible(
            name: "CrimsonText-Regular",
            family: "Crimson Text",
            path: "CrimsonText-Regular.ttf"
        )
        /// Semi-bold variant of Crimson Text font
        public static let semiBold = FontConvertible(
            name: "CrimsonText-SemiBold",
            family: "Crimson Text",
            path: "CrimsonText-SemiBold.ttf"
        )
        /// Semi-bold italic variant of Crimson Text font
        public static let semiBoldItalic = FontConvertible(
            name: "CrimsonText-SemiBoldItalic",
            family: "Crimson Text",
            path: "CrimsonText-SemiBoldItalic.ttf"
        )
        /// Collection of all Crimson Text font variants
        public static let all: [FontConvertible] = [bold, boldItalic, italic, regular, semiBold, semiBoldItalic]
    }

    /// The SF Pro Text font family with its various styles
    public enum SFProText {
        /// Bold variant of SF Pro Text font
        public static let bold = FontConvertible(
            name: "SFProText-Bold",
            family: "SF Pro Text",
            path: "SF-Pro-Text-Bold.otf"
        )
        /// Regular variant of SF Pro Text font
        public static let regular = FontConvertible(
            name: "SFProText-Regular",
            family: "SF Pro Text",
            path: "SF-Pro-Text-Regular.otf"
        )
        /// Semi-bold variant of SF Pro Text font
        public static let semibold = FontConvertible(
            name: "SFProText-Semibold",
            family: "SF Pro Text",
            path: "SF-Pro-Text-Semibold.otf"
        )
        /// Collection of all SF Pro Text font variants
        public static let all: [FontConvertible] = [bold, regular, semibold]
    }

    /// Collection of all custom fonts available in the application
    public static let allCustomFonts: [FontConvertible] = [CrimsonText.all, SFProText.all].flatMap(\.self)

    /// Registers all custom fonts in the application
    public static func registerAllCustomFonts() {
        allCustomFonts.forEach { $0.register() }
    }
}

// MARK: - Implementation Details

/// A structure representing a custom font that can be converted to platform-specific font objects
public struct FontConvertible: Sendable {
    /// The PostScript name of the font
    public let name: String
    /// The family name of the font
    public let family: String
    /// The file path where the font is stored
    public let path: String

    #if os(macOS)
        /// Platform-specific font type
        public typealias Font = NSFont
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        /// Platform-specific font type
        public typealias Font = UIFont
    #endif

    /// Creates a platform-specific font object with the specified size
    /// - Parameter size: The desired size of the font
    /// - Returns: A platform-specific font object
    public func font(size: CGFloat) -> Font {
        guard let font = Font(font: self, size: size) else {
            fatalError("Unable to initialize font '\(name)' (\(family))")
        }
        return font
    }

    #if canImport(SwiftUI)
        /// Creates a SwiftUI font with the specified size
        /// - Parameter size: The desired size of the font
        /// - Returns: A SwiftUI Font object
        @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
        public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
            SwiftUI.Font.custom(self, size: size)
        }

        /// Creates a SwiftUI font with a fixed size
        /// - Parameter fixedSize: The fixed size of the font
        /// - Returns: A SwiftUI Font object
        @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
        public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
            SwiftUI.Font.custom(self, fixedSize: fixedSize)
        }

        /// Creates a SwiftUI font with dynamic type support
        /// - Parameters:
        ///   - size: The base size of the font
        ///   - textStyle: The text style to scale relative to
        /// - Returns: A SwiftUI Font object
        @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
        public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
            SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
        }
    #endif

    /// Registers the font with the system
    public func register() {
        guard let url else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    /// Registers the font if it hasn't been registered already
    fileprivate func registerIfNeeded() {
        #if os(iOS) || os(tvOS) || os(watchOS)
            if !UIFont.fontNames(forFamilyName: family).contains(name) {
                register()
            }
        #elseif os(macOS)
            if let url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
                register()
            }
        #endif
    }

    /// The URL where the font file is located
    fileprivate var url: URL? {
        BundleToken.bundle.url(forResource: path, withExtension: nil)
    }
}

/// Convenience initializer for platform-specific fonts
public extension FontConvertible.Font {
    /// Creates a platform-specific font from a FontConvertible
    /// - Parameters:
    ///   - font: The FontConvertible to create the font from
    ///   - size: The desired size of the font
    convenience init?(font: FontConvertible, size: CGFloat) {
        font.registerIfNeeded()
        self.init(name: font.name, size: size)
    }
}

#if canImport(SwiftUI)
    /// SwiftUI Font extensions for iOS 13 and later
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public extension SwiftUI.Font {
        /// Creates a custom SwiftUI Font from a FontConvertible
        /// - Parameters:
        ///   - font: The FontConvertible to create the font from
        ///   - size: The desired size of the font
        /// - Returns: A SwiftUI Font object
        static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
            font.registerIfNeeded()
            return custom(font.name, size: size)
        }
    }

    /// Additional SwiftUI Font extensions for iOS 14 and later
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
    public extension SwiftUI.Font {
        /// Creates a custom SwiftUI Font with a fixed size
        /// - Parameters:
        ///   - font: The FontConvertible to create the font from
        ///   - fixedSize: The fixed size of the font
        /// - Returns: A SwiftUI Font object
        internal static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
            font.registerIfNeeded()
            return custom(font.name, fixedSize: fixedSize)
        }

        /// Creates a custom SwiftUI Font with dynamic type support
        /// - Parameters:
        ///   - font: The FontConvertible to create the font from
        ///   - size: The base size of the font
        ///   - textStyle: The text style to scale relative to
        /// - Returns: A SwiftUI Font object
        static func custom(
            _ font: FontConvertible,
            size: CGFloat,
            relativeTo textStyle: SwiftUI.Font.TextStyle
        ) -> SwiftUI.Font {
            font.registerIfNeeded()
            return custom(font.name, size: size, relativeTo: textStyle)
        }
    }
#endif

// swiftlint:disable convenience_type
/// Private class for managing bundle access
private final class BundleToken {
    /// The bundle containing the font resources
    public static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()

    deinit {
        return
    }
}

// swiftlint:enable convenience_type
// swiftlint:enable superfluous_disable_command file_length implicit_return
// swiftlint:enable identifier_name line_length type_body_length
