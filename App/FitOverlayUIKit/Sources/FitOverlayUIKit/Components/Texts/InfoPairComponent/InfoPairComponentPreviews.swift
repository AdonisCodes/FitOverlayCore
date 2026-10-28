// InfoPairComponentPreviews.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// A preview provider for the InfoPairComponent
/// This struct provides SwiftUI previews for the InfoPairComponent using a wrapper view
internal struct InfoPairComponentPreviews: PreviewProvider {
    /// The preview content showing the InfoPairWrapperView
    /// - Returns: A view containing the InfoPairWrapperView for preview purposes
    public static var previews: some View {
        InfoPairWrapperView()
    }
}

/// A wrapper view for the InfoPairComponent that provides property editing capabilities
/// This view allows for real-time editing of the InfoPairComponent's configuration
internal struct InfoPairWrapperView: View {
    /// The configuration object for the InfoPairComponent
    /// This observed object contains all the configurable properties for the component
    @ObservedObject public var config = InfoPairComponentConfig()

    /// The body of the wrapper view
    /// Provides a property editor interface and displays the InfoPairComponent
    /// - Returns: A view containing the property editor and InfoPairComponent
    public var body: some View {
        // Create a property editor with title and description fields
        PropertyEditor(
            object: config,
            properties: [
                [AnyKeyPath("Title", keyPath: \.title)],
                [AnyKeyPath("Description", keyPath: \.description)],
            ]
        ) {
            // Stack the InfoPairComponent and variant selector vertically
            VStack {
                InfoPairComponent(config: config)
                EnumPropertyView(
                    value: $config.variant,
                    cases: InfoPairVariants.allCases
                )
            }
        }
    }
}
