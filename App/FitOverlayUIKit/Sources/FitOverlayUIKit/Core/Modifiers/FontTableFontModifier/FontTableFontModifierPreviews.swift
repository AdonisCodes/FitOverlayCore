// FontTableFontModifierPreviews.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider that demonstrates the usage of various font styles from the FontTable
/// using the fontTableFont modifier.
internal struct FontTableFontModifierPreviews: PreviewProvider {
    /// The preview content showing different font styles
    public static var previews: some View {
        TestView()
    }
}

/// A test view that wraps the ContentView for preview purposes
internal struct TestView: View {
    /// The body of the test view
    /// - Returns: A view containing the ContentView
    public var body: some View {
        ContentView()
    }
}

/// A view that demonstrates all available font styles from the FontTable
internal struct ContentView: View {
    /// The body of the content view that displays text samples with different font styles
    /// - Returns: A vertical stack of text views with various font styles applied
    public var body: some View {
        // Create a vertical stack with leading alignment to display font samples
        VStack(alignment: .leading) {
            // Crimson Text Font Examples - Headings
            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head3)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head4)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head5)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Headings.head6)

            // Crimson Text Font Examples - Body
            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body3)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Body.body4)

            // Crimson Text Font Examples - Meta
            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Meta.label1)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Meta.label2)

            Text("This is bold Crimson Text!")
                .fontTableFont(FontTable.Crimson.Meta.caption1)

            // SF Pro Font Examples - Headings
            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head2)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head3)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head4)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head5)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Headings.head6)

            // SF Pro Font Examples - Body
            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body2)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body3)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Body.body4)

            // SF Pro Font Examples - Meta
            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Meta.label1)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Meta.label2)

            Text("This is bold SFPro Text!")
                .fontTableFont(FontTable.SFPro.Meta.caption1)
        }
        .padding()
    }
}
