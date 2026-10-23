// ForceUpdate.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// A view that forces users to update the app when they have an outdated version
/// This view is displayed when a user must update the app to continue using it
public struct ForceUpdate: View {
    /// Initializes a new ForceUpdate view
    /// - Returns: A new ForceUpdate view instance
    public init() {}

    /// Configuration for the title and description text displayed at the top of the view
    /// Initialized with default update notification messages
    @StateObject public var titleConfig: InfoPairComponentConfig = .init(
        title: "It's time for an update!",
        description: "You have an older version of the app!"
    )

    /// Configuration for the update button displayed at the bottom of the view
    /// Initialized with default settings
    @StateObject public var buttonConfig: TextButtonComponentConfig = .init()

    /// The body of the ForceUpdate view
    /// Displays a vertical stack containing an info pair component for the title/description
    /// and a button that opens the App Store update page
    public var body: some View {
        VStack(alignment: .leading) {
            InfoPairComponent(config: titleConfig)
            Spacer()
            TextButtonComponent(config: buttonConfig) { config in
                config.text = "Update Now"
            } action: { _ in
                openUpdateScreen()
            }
        }.defaultScreenPadding()
    }

    /// Opens the download page for the app to allow the user to update.
    /// Opens in the default browser / App Store in a platform-appropriate way.
    /// TODO: Point at the real App Store / download page once published.
    public func openUpdateScreen() {
        if let url = URL(string: "https://fitoverlay.app/download") {
            openExternalURL(url)
        }
    }
}

/// Preview provider for the ForceUpdate view
/// Shows the view in dark mode for development purposes
#Preview {
    ForceUpdate()
        .preferredColorScheme(.dark)
}
