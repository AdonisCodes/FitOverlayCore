// DebugMenu.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

//
//  DebugMenu.swift
//  FitOverlayAppShared
//
//  Created by Simon Ferns on 12/16/24.
//

import FitOverlayUIKit
import SwiftUI

/// Represents the available base environment URLs for the application
/// Used to switch between different API environments
internal enum BaseEnvironmentUrl: String, CaseIterable {
    /// Local development environment (docker compose backend)
    case localhost = "http://127.0.0.1:8080"
    /// Production environment
    case production = "https://api-production.fitoverlay.app"
    /// Sandbox testing environment
    case sandbox = "https://api-sandbox.fitoverlay.app"
    /// Staging environment
    case staging = "https://api-staging.fitoverlay.app"
}

/// Debug menu view for the application
/// Provides interface for changing app behavior, environment and other configuration options
public struct DebugMenu: View {
    /// Environment object for managing base application configuration
    @EnvironmentObject public var baseEnvironmentConfig: BaseAppEnvironmentObject

    /// Configuration for the close button in the debug menu
    @StateObject public var closeButtonConfig: IconButtonComponentConfig = .init()

    /// Configuration for the environment URL picker text input
    @StateObject public var environmentPickerConfig: TextInputFrameComponentConfig = .init(
        text: BaseEnvironmentUrl.sandbox.rawValue
    )

    /// Configuration for the environment picker confirmation button
    @StateObject public var environmentPicketButtonConfig: TextButtonComponentConfig = .init()

    /// Initializes a new instance of the debug menu
    public init() {}

    /// The body of the debug menu view
    /// Displays sections for profile actions and API configuration
    public var body: some View {
        Form {
            Section {
                HStack {
                    Text("Debug Menu")
                        .fontTableFont(
                            FontTable.Crimson.Headings.head5,
                            DesignTokens.colors.primaryText
                        )
                    Spacer()
                    IconButtonComponent(
                        config: closeButtonConfig,
                        onSelfAppear: { config in
                            config.icon = .other
                            config.defaultPadding = DesignTokens.padding.minimal
                            config.isCircular = true
                            config.fillSpace = false
                        },
                        action: {
                            baseEnvironmentConfig.isDebugMenuActive = false
                        }
                    )
                }
            }

            Section(header: Text("Profile Actions")) {
                Text("🍃 Log Out")
            }.onTapGesture {
                baseEnvironmentConfig.logout()
                baseEnvironmentConfig.isDebugMenuActive = false
            }

            Section(header: Text("Api Configuration")) {
                VStack {
                    Picker(
                        "API URL",
                        selection: $environmentPickerConfig.text
                    ) {
                        ForEach(
                            BaseEnvironmentUrl.allCases,
                            id: \.rawValue
                        ) { url in
                            Text(url.rawValue)
                        }
                    }

                    TextInputFrameComponent(
                        config: environmentPickerConfig
                    ) {
                        environmentPickerConfig.text = baseEnvironmentConfig.apiBaseURL
                    }

                    TextButtonComponent(
                        config: environmentPicketButtonConfig,
                        onSelfAppear: { config in
                            config.text = "Set URL"
                        },
                        action: { _ in
                            setBaseEnvUrl()
                        }
                    )
                }
            }
        }
        Spacer()
    }

    private func setBaseEnvUrl() {
        let url = URL(string: environmentPickerConfig.text)

        if let url {
            baseEnvironmentConfig.apiBaseURL = url.absoluteString
            baseEnvironmentConfig.logout()
            baseEnvironmentConfig.isDebugMenuActive = false
        } else {
            print(
                "HANDLE ERRORS INVALID URL \(environmentPickerConfig.text)"
            )
        }
    }
}

/// SwiftUI preview provider for the DebugMenu view
#Preview {
    DebugMenu()
        .preferredColorScheme(.dark)
}
