// InfoPairComponentConfig.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Defines the available visual variants for the InfoPair component
/// Currently supports a generic style that can be extended for future variants
public enum InfoPairVariants: String, CaseIterable {
    /// The default generic styling variant
    case generic
}

/**
 Configuration class for the Info Pair Component that manages the component's content and appearance.

 This class provides a way to configure:
 - The title text displayed in the component
 - The description text displayed below the title
 - The visual variant of the component

 Usage Example:
 ```
 let config = InfoPairComponentConfig(
     title: "My Title",
     description: "My Description",
     variant: .generic
 )
 ```
 */
public class InfoPairComponentConfig: ObservableObject {
    /// The title text to be displayed in the component
    @Published public var title: String

    /// The description text to be displayed below the title
    @Published public var description: String

    /// The visual variant that determines the component's appearance
    @Published public var variant: InfoPairVariants

    /**
     Initializes a new InfoPairComponentConfig instance with customizable parameters.

     - Parameters:
        - title: The title text to display. Defaults to "Enter a title here"
        - description: The description text to display. Defaults to "Enter a 3 line / 2 line description here"
        - variant: The visual variant to use. Defaults to .generic
     */
    public init(
        title: String = "Enter a title here",
        description: String = "Enter a 3 line / 2 line description here",
        variant: InfoPairVariants = .generic
    ) {
        // Initialize the component's properties with the provided or default values
        self.title = title
        self.description = description
        self.variant = variant
    }

    /// Cleanup method called when the instance is being deallocated
    deinit {
        return
    }
}
