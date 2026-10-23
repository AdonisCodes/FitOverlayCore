// FontTableFontModifier.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/**
 The `FontTableFontModifier` is a view modifier used to apply fonts from the `FontTable`
 to `Text` views in SwiftUI.
 It allows you to use custom font styles defined in the `FontTable` enums,
 ensuring consistency across your app.

 This modifier takes an object conforming to the `IsFontTableFont` protocol,
 which provides access to the appropriate `Font` instance.
 By using this modifier, you can apply predefined fonts that are part of the
 `FontTable`, including headings, body text, and meta labels.

 - Parameters:
     - fontTableType: A value conforming to the `IsFontTableFont` protocol, which provides the
     corresponding `SwiftUI.Font`.

 - Returns: A `View` with the specified font applied.

 ### Usage Examples:

 #### Basic Example:
 To apply a heading font (e.g., `h1`) from the `FontTable.Headings` enum to a `Text` view:

 ```swift
 Text("This is a Heading 1!")
     .fontTableFont(FontTable.Headings.h1)

 Text("This is a Heading 1!")
     .fontTableFont(FontTable.Headings.h1, .black)
 ```
 */
public struct FontTableFontModifier: ViewModifier {
    public let fontTableType: IsFontTableFont
    public let colour: Color?

    public func body(content: Content) -> some View {
        if let colour {
            content.font(fontTableType.font).foregroundStyle(colour)
        } else {
            content.font(fontTableType.font)
        }
    }
}

/// A type alias that restricts the `FontTableFontModifier` to be used only with `Text` views.
/// This ensures type safety and prevents the modifier from being used with incompatible view types.
public typealias FontTableFontModifierViewTypes = Text // Use Type Narrowing Please!

/// Extension that adds font modification capabilities to Text views.
/// This extension is marked with `@MainActor` to ensure all UI updates occur on the main thread.
@MainActor
public extension FontTableFontModifierViewTypes {
    /// Applies a custom font from the FontTable to the text view.
    ///
    /// This method allows you to apply predefined fonts from the FontTable system while
    /// optionally specifying a custom color for the text.
    ///
    /// - Parameters:
    ///   - font: A value conforming to `IsFontTableFont` that specifies the font to be applied
    ///   - colour: An optional Color value that, if provided, will be applied to the text
    /// - Returns: A modified view with the specified font and color applied
    ///
    /// Example usage:
    /// ```
    /// Text("Hello, World!")
    ///     .fontTableFont(FontTable.Headings.h1, .blue)
    /// ```
    func fontTableFont(_ font: IsFontTableFont, _ colour: Color? = nil) -> some View {
        modifier(FontTableFontModifier(fontTableType: font, colour: colour))
    }
}
