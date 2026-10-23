// Tokens.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A structure that defines the color palette used throughout the application
public struct DesignColors: Sendable {
    /// The primary brand color
    public let primary: Color = .init(hex: "0FA958")

    /// Text Colors
    /// The primary text color, used for main content
    public let primaryText: Color = .init(hex: "FFFFFF")
    /// The secondary text color, used for less emphasized content
    public let secondaryText: Color = .init(hex: "B4B4B4")
    /// The dark text color, used for high contrast text
    public let textDark: Color = .init(hex: "000000")

    /// Whitespace Colors
    /// Primary whitespace color level 1
    public let primaryWhitespace1: Color = .init(hex: "000000")
    /// Primary whitespace color level 2
    public let primaryWhitespace2: Color = .init(hex: "3C3C3C")
    /// Primary whitespace color level 3
    public let primaryWhitespace3: Color = .init(hex: "7C7C7C")

    /// Color used for dangerous actions or warnings
    public let danger: Color = .init(hex: "FD8B83")
    /// Color used for error states
    public let error: Color = .init(hex: "FF3B2F")
}

/// A structure that defines padding and spacing values used throughout the application
public struct DesignPadding: Sendable {
    /// Enumeration defining standard padding sizes
    public enum PaddingSizes: CGFloat {
        case base, large, medium, small

        /// The numerical value associated with each padding size
        public var value: CGFloat {
            switch self {
            case .base:
                12 // Base padding value
            case .medium:
                8 // Medium padding value
            case .small:
                4 // Small padding value
            case .large:
                16 // Large padding value
            }
        }
    }

    /// Standard button padding with different horizontal and vertical insets
    public let button: EdgeInsets = .init(top: 20, leading: 30, bottom: 20, trailing: 30)
    /// Even button padding with equal insets on all sides
    public let buttonEven: EdgeInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
    /// Small padding variable with base vertical and large horizontal insets
    public let smallPaddingVar: EdgeInsets = .init(
        top: PaddingSizes.base.value,
        leading: PaddingSizes.large.value,
        bottom: PaddingSizes.base.value,
        trailing: PaddingSizes.large.value
    )

    /// Zero padding on all sides
    public let none: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    /// Minimal padding of 2 points on all sides
    public let minimal: EdgeInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)

    /// Base corner radius size
    public let cornerRadiusBase: CGSize = .init(
        width: PaddingSizes.base.value,
        height: PaddingSizes.base.value
    )
}

/// Protocol defining requirements for design icons
internal protocol DesignIcon {
    /// The associated type that conforms to View protocol
    associatedtype Content: View
    /// The image representation of the icon
    var image: Content { get }
}

/// Enumeration of all available design icons in the application
public enum DesignIcons: String, CaseIterable, DesignIcon {
    case arrowRight
    case other
    case pause, play, unknown
    case subtraction

    /// Returns the SwiftUI view representation of the icon
    public var image: some View {
        switch self {
        case .pause:
            Image(systemName: "pause.circle.fill").toIcon()
        case .play:
            Image(systemName: "play.circle.fill").toIcon()
        case .unknown:
            Image(systemName: "questionmark.circle.fill").toIcon()
        case .arrowRight:
            Image(systemName: "arrow.right").toIcon()
        case .subtraction:
            Image(systemName: "minus").toIcon()
        case .other:
            Image(systemName: "x.circle.fill").toIcon()
        }
    }
}

/// Configuration structure for design icons
public struct DesignIconsConfig: Sendable {
    /// Default width for icons
    public let defaultWidth: CGFloat = 17.5
    /// Default height for icons
    public let defaultHeight: CGFloat = 17.5
}

/// Central enumeration containing all design tokens used in the application
public enum DesignTokens {
    /// Color tokens
    public static let colors: DesignColors = .init()
    /// Padding tokens
    public static let padding: DesignPadding = .init()
    /// Icon configuration tokens
    public static let icons: DesignIconsConfig = .init()

    /// Default corner radius used throughout the application
    public static let defaultCornerRadius: CGFloat = 12
}

/// Protocol defining requirements for font table fonts
public protocol IsFontTableFont {
    /// The SwiftUI font representation
    var font: SwiftUI.Font { get }
}

/// Enumeration containing all font definitions used in the application
public enum FontTable {
    /// Crimson text font family definitions
    public enum Crimson {
        /// Heading styles for Crimson font
        public enum Headings: IsFontTableFont {
            case head1, head2, head3, head4, head5, head6

            /// Returns the appropriate SwiftUI font for each heading level
            public var font: SwiftUI.Font {
                switch self {
                case .head1:
                    FontFamily.CrimsonText.bold.swiftUIFont(size: 60)
                case .head2:
                    FontFamily.CrimsonText.bold.swiftUIFont(size: 48)
                case .head3:
                    FontFamily.CrimsonText.bold.swiftUIFont(size: 36)
                case .head4:
                    FontFamily.CrimsonText.bold.swiftUIFont(size: 30)
                case .head5:
                    FontFamily.CrimsonText.bold.swiftUIFont(size: 24)
                case .head6:
                    FontFamily.CrimsonText.bold.swiftUIFont(size: 20)
                }
            }
        }

        /// Body text styles for Crimson font
        public enum Body: IsFontTableFont {
            case body1, body2, body3, body4

            /// Returns the appropriate SwiftUI font for each body text style
            public var font: SwiftUI.Font {
                switch self {
                case .body1:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 20)
                case .body2:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 18)
                case .body3:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 16)
                case .body4:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 14)
                }
            }
        }

        /// Meta text styles for Crimson font
        public enum Meta: IsFontTableFont {
            case caption1, label1, label2

            /// Returns the appropriate SwiftUI font for each meta text style
            public var font: SwiftUI.Font {
                switch self {
                case .label1:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 14)
                case .label2:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 12)
                case .caption1:
                    FontFamily.CrimsonText.regular.swiftUIFont(size: 12)
                }
            }
        }
    }

    /// SF Pro font family definitions
    public enum SFPro {
        /// Heading styles for SF Pro font
        public enum Headings: IsFontTableFont {
            case head1, head2, head3, head4, head5, head6

            /// Returns the appropriate SwiftUI font for each heading level
            public var font: SwiftUI.Font {
                switch self {
                case .head1:
                    FontFamily.SFProText.bold.swiftUIFont(size: 60)
                case .head2:
                    FontFamily.SFProText.bold.swiftUIFont(size: 48)
                case .head3:
                    FontFamily.SFProText.bold.swiftUIFont(size: 36)
                case .head4:
                    FontFamily.SFProText.semibold.swiftUIFont(size: 30)
                case .head5:
                    FontFamily.SFProText.semibold.swiftUIFont(size: 24)
                case .head6:
                    FontFamily.SFProText.semibold.swiftUIFont(size: 18)
                }
            }
        }

        /// Body text styles for SF Pro font
        public enum Body: IsFontTableFont {
            case body1, body2, body3, body4

            /// Returns the appropriate SwiftUI font for each body text style
            public var font: SwiftUI.Font {
                switch self {
                case .body1:
                    FontFamily.SFProText.regular.swiftUIFont(size: 20)
                case .body2:
                    FontFamily.SFProText.regular.swiftUIFont(size: 18)
                case .body3:
                    FontFamily.SFProText.regular.swiftUIFont(size: 16)
                case .body4:
                    FontFamily.SFProText.regular.swiftUIFont(size: 14)
                }
            }
        }

        /// Meta text styles for SF Pro font
        public enum Meta: IsFontTableFont {
            case caption1, label1, label2

            /// Returns the appropriate SwiftUI font for each meta text style
            public var font: SwiftUI.Font {
                switch self {
                case .label1:
                    FontFamily.SFProText.regular.swiftUIFont(size: 14)
                case .label2:
                    FontFamily.SFProText.regular.swiftUIFont(size: 12)
                case .caption1:
                    FontFamily.SFProText.regular.swiftUIFont(size: 12)
                }
            }
        }
    }

    //    enum Italics {
    //        enum Body: IsFontTableFont {
    //        }
    //        enum Meta: IsFontTableFont {
    //        }
    //    }
}
