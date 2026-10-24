// NoNetworkConnectionView.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

//
//  NoNetworkConnection.swift
//  FitOverlayAppShared
//
//  Created by Simon Ferns on 2/23/25.
//
import FitOverlayUIKit
import SwiftUI

/// A view that displays a message when there is no internet connection available
///
/// This view presents a simple interface to inform users about their connection status,
/// using an `InfoPairComponent` to show a title and description about the network state.
///
/// Example usage:
/// ```
/// NoNetworkConnectionView()
/// ```
public struct NoNetworkConnectionView: View {
    /// Creates a new instance of `NoNetworkConnectionView`
    ///
    /// - Returns: A new `NoNetworkConnectionView` instance
    public init() {}

    /// Configuration for the information display component
    ///
    /// This object contains the title and description text that will be shown to the user
    /// when there is no network connection available.
    @StateObject public var titleConfig: InfoPairComponentConfig = .init(
        title: "You're not connected!",
        description: "Please ensure you have an active internet connection!"
    )

    /// The body of the view
    ///
    /// Constructs the view hierarchy using a vertical stack containing an `InfoPairComponent`
    /// that displays the connection status message.
    public var body: some View {
        VStack {
            InfoPairComponent(
                config: titleConfig
            )
        }
    }
}
