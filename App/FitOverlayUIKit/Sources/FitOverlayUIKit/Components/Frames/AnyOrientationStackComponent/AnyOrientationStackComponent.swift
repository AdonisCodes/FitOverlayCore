// AnyOrientationStackComponent.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI
import ViewExtractor

/**
 The `AnyOrientationStackComponent` is a reusable component that provides flexible stack \
 layouts with dynamic orientation switching.

 This component allows you to create stacks that can switch between vertical (VStack), \
 horizontal (HStack), and depth-based (ZStack) orientations
 at runtime. It handles alignment and spacing configurations automatically based on the \
 selected orientation.

 Example usage:
 ```
 let config = AnyOrientationStackComponentConfig(variant: .vstack)
 AnyOrientationStackComponent(config: config) {
     Text("Item 1")
     Text("Item 2")
 }
 ```

 - Parameters:
     - config: The configuration object used to manage state \
     & modifications to `AnyOrientationStackComponent`
 - Returns: A view that arranges its children in the specified stack orientation

 To see usage examples & visuals, check out `AnyOrientationStackModifierDocumentation.md`
 */
public struct AnyOrientationStackComponent<Content: View>: View {
    /// The configuration object that controls the stack's behavior and appearance
    @ObservedObject public var config: AnyOrientationStackComponentConfig

    /// The content view builder that provides the stack's child views
    @ViewBuilder public let content: Content

    /**
     Initializes a new instance of AnyOrientationStackComponent.

     - Parameters:
        - config: The configuration object that defines the stack's behavior
        - content: A closure that returns the stack's child views
     */
    public init(config: AnyOrientationStackComponentConfig, @ViewBuilder content: () -> Content) {
        self.config = config
        self.content = content()
    }

    /// The body of the view that renders the appropriate stack type based on configuration
    public var body: some View {
        // Extract child views from the content builder
        Extract(content) { views in
            // Determine stack type based on variant configuration
            switch config.variant {
            case .vstack:
                // Render vertical stack with configured alignment and spacing
                VStack(alignment: config.vstackAlignment, spacing: config.spacing) {
                    ForEach(views) { view in
                        view
                    }
                }
            case .hstack:
                // Render horizontal stack with configured alignment and spacing
                HStack(alignment: config.hstackAlignment, spacing: config.spacing) {
                    ForEach(views) { view in
                        view
                    }
                }
            case .zstack:
                // Render depth-based stack (overlapping views)
                ZStack {
                    ForEach(views) { view in
                        view
                    }
                }
            }
        }
    }
}
