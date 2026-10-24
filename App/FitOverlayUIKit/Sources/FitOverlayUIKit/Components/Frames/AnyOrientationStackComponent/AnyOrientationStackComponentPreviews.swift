// AnyOrientationStackComponentPreviews.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

/// A preview provider for the AnyOrientationStackComponent
/// This struct provides SwiftUI previews to visualize the component in different states
internal struct AnyOrientationStackComponentPreviews: PreviewProvider {
    /// The preview content showing the AnyOrientationStackComponent wrapped in a container view
    /// - Returns: A view containing the preview content
    public static var previews: some View {
        AnyOrientationStackComponentWrapperView()
    }
}

/// A wrapper view that demonstrates the usage of AnyOrientationStackComponent
/// This view serves as a container to showcase the component with sample content
internal struct AnyOrientationStackComponentWrapperView: View {
    /// The configuration object for the stack component
    /// Uses @ObservedObject to respond to changes in the configuration
    @ObservedObject public var config = AnyOrientationStackComponentConfig()

    /// The body of the view containing the AnyOrientationStackComponent
    /// - Returns: A view with the configured stack component and sample text elements
    public var body: some View {
        // Create an instance of AnyOrientationStackComponent with the specified configuration
        // and demonstrate it with two text views as child elements
        AnyOrientationStackComponent(config: config) {
            Text("HI")
            Text("HI")
        }
    }
}
