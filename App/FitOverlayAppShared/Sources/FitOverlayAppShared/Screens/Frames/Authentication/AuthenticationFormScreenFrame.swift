// AuthenticationFormScreenFrame.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// Layout frame for all authentication screens
/// A reusable view component that provides a consistent layout structure for authentication-related screens
public struct AuthenticationFormScreenFrame<CenterContent: View>: View {
    /// The main title displayed at the top of the screen
    public var title: String = "Enter Title"

    /// The description text displayed below the title
    public var description: String = "Enter Desc"

    /// Configuration object for the title and description section
    @StateObject public var titleConfig: InfoPairComponentConfig = .init()

    /// Configuration object for the action button
    @StateObject public var buttonConfig: IconButtonComponentConfig = .init()

    /// Binding to control the enabled/disabled state of the action button
    @Binding public var isValid: Bool

    /// Content builder for the center section of the screen
    @ViewBuilder public let centerContent: () -> CenterContent

    /// Async action to be performed when the action button is tapped
    public let action: () async -> Void

    /// The main body of the authentication form screen
    /// - Layout:
    ///   - Title and description at the top
    ///   - Custom center content in the middle
    ///   - Action button at the bottom
    public var body: some View {
        VStack(alignment: .leading) {
            InfoPairComponent(config: titleConfig) { config in
                config.title = title
                config.description = description
            }

            Spacer()

            centerContent()

            Spacer()

            IconButtonComponent(
                config: buttonConfig,
                onSelfAppear: { config in
                    print("calling on appear now")
                    config.isDisabled = true
                    config.icon = .arrowRight
                }, action: {
                    await action()
                }
            )
            .onChange(of: isValid) {
                print("is changing \(isValid)")
                buttonConfig.isDisabled = !isValid
            }
        }
        .defaultScreenPadding()
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
    }
}
