// OnboardingScreenFrame.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import SwiftUI

/// A view that provides a standardized layout frame for onboarding screens.
/// This component splits the screen into two main sections:
/// - A top section with a primary background color (60% of available height)
/// - A bottom section with a black background (40% of available height)
///
/// The layout adapts based on the platform, using a vertical stack on iOS and horizontal stack
/// on macOS, so the same screens work in a resizable window.
///
/// Usage:
/// ```
/// OnboardingScreenFrame {
///     Text("Welcome")  // Title content
/// } footerContent: {
///     Button("Get Started") { }  // Footer content
/// }
/// ```
public struct OnboardingScreenFrame<TitleContent: View, FooterContent: View>: View {
    /// Closure that provides the title content to be displayed in the frame.
    /// This content will be positioned at the top of the bottom section.
    public let titleContent: () -> TitleContent

    /// Closure that provides the footer content to be displayed in the frame.
    /// This content will be positioned at the bottom of the bottom section.
    public let footerContent: () -> FooterContent

    /// Initializes a new onboarding screen frame with customizable title and footer content.
    /// - Parameters:
    ///   - titleContent: A closure returning the view to be displayed as the title content.
    ///     This view will be aligned to the leading edge of the screen.
    ///   - footerContent: A closure returning the view to be displayed as the footer content.
    ///     This view will be positioned at the bottom of the screen.
    public init(
        @ViewBuilder titleContent: @escaping () -> TitleContent,
        @ViewBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.titleContent = titleContent
        self.footerContent = footerContent
    }

    /// The body of the view that defines the onboarding screen layout.
    /// Uses a `GeometryReader` (instead of `UIScreen`) so the split layout works in resizable
    /// macOS windows as well as on iOS.
    public var body: some View {
        GeometryReader { proxy in
            AnyOrientationStackComponent(
                config: .init(variant: determineStackType())
            ) {
                VStack {
                    Spacer()
                }
                .frame(
                    width: isVerticalLayout ? nil : proxy.size.width * 0.6,
                    height: isVerticalLayout ? proxy.size.height * 0.6 : nil
                )
                .frame(maxWidth: isVerticalLayout ? .infinity : nil, maxHeight: isVerticalLayout ? nil : .infinity)
                .background(DesignTokens.colors.primary)

                VStack(alignment: .leading) {
                    HStack {
                        titleContent()
                        Spacer()
                    }
                    Spacer()

                    HStack(alignment: .bottom) {
                        footerContent()
                    }
                }
                .defaultScreenPadding()
                .frame(
                    width: isVerticalLayout ? nil : proxy.size.width * 0.4,
                    height: isVerticalLayout ? proxy.size.height * 0.4 : nil
                )
                .frame(maxWidth: isVerticalLayout ? .infinity : nil, maxHeight: isVerticalLayout ? nil : .infinity)
                .background(.black)
            }
        }
        .ignoresSafeArea()
    }

    private var isVerticalLayout: Bool {
        determineStackType() == .vstack
    }

    /// Determines the appropriate stack type based on the current platform.
    /// This method ensures the layout adapts correctly across different devices.
    /// - Returns: The stack variant to use for layout:
    ///   - `.vstack` for iOS devices (vertical layout)
    ///   - `.hstack` for other platforms (horizontal layout)
    public func determineStackType() -> AnyOrientationStackComponentVariants {
        #if os(iOS)
            return .vstack
        #else
            return .hstack
        #endif
    }
}

/// Provides a preview of the OnboardingScreenFrame in SwiftUI's preview canvas
#Preview {
    OnboardingScreen()
}
