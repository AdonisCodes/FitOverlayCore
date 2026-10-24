// LoginScreen.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import DataTypes
import SwiftUI

/// A view that handles user login functionality
///
/// This screen provides a two-step login process:
/// 1. Phone number verification where users enter their phone number
/// 2. Code verification where users enter a received verification code
///
/// The screen handles timeouts between verification attempts and displays appropriate error messages.
public struct LoginScreen: View {
    /// Configuration for the phone number input field
    @StateObject public var phoneInputConfig: PhoneNumberTextInputComponentConfig = .init()

    /// Configuration for the verification code input field
    @StateObject public var verificationInputConfig: VerificationCodeInputComponentConfig = .init()

    /// Countdown timer for code resend timeout
    @State public var timeout: Double = 0

    /// Environment object containing base app configuration
    @EnvironmentObject public var baseEnvironmentConfig: BaseAppEnvironmentObject

    /// Authentication interactor used for making API requests
    private var authInteractor: AuthenticationControllerInteractor {
        .init(
            baseURL: baseEnvironmentConfig.apiBaseURL
        )
    }

    /// Tracks if the previous error was a timeout
    @State private var wasPreviousErrorTimeout: Bool = false

    /// Controls whether timeout error messages should be shown
    @State private var shouldShowTimeoutError: Bool = true

    /// Timer used to handle countdown functionality
    @State private var timer: Timer?

    /// Indicates whether verification code has been sent
    @State private var didSendCode: Bool = false

    /// Indicates whether verification code screen input is valid
    @State private var isValidVerificationScreenState: Bool = false

    /// Formats the timeout value into a user-friendly message
    private var formattedTimeout: String {
        let error = String(format: "%.1f", timeout)
        if !didSendCode {
            return "Please wait \(error)s before trying again!"
        } else {
            return "Please wait \(error)s before resending the code!"
        }
    }

    /// Creates a new LoginScreen instance
    public init() {}

    /// The main view body
    public var body: some View {
        VStack {
            if !didSendCode {
                AuthenticationFormScreenFrame(
                    title: "Verify your phone number",
                    description: "What is your phone number?",
                    isValid: createIsValidPhoneNumberBinding(),
                    centerContent: {
                        VStack {
                            PhoneNumberTextInputComponent(config: phoneInputConfig)
                        }
                    },
                    action: {
                        await sendAuthenticationCode()
                    }
                )
            } else {
                AuthenticationFormScreenFrame(
                    title: "Check your Messages",
                    description: "Can you enter the verification code?",
                    isValid: $isValidVerificationScreenState,
                    centerContent: {
                        VStack {
                            VerificationCodeInputComponent(
                                config: verificationInputConfig
                            ) { config in
                                config.title = "Verification Code"
                            }.onChange(of: verificationInputConfig.text) {
                                isValidVerificationScreenState = verificationInputConfig.text.count > 3
                            }

                            Text("Resend Code")
                                .fontTableFont(FontTable.SFPro.Body.body1)
                                .padding()
                                .onTapGesture {
                                    Task {
                                        print("Resending Code")
                                        await sendAuthenticationCode()
                                        print("Resending Code Done")
                                    }
                                }
                                .opacity(timeout == 0 ? 1 : 0)
                        }
                    },
                    action: {
                        await verifyAuthenticationCode()
                    }
                )
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    /// Starts the countdown timer for code resend timeout
    ///
    /// This method runs on the main actor to ensure UI updates are thread-safe
    @MainActor
    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                if timeout > 0 {
                    timeout -= timeout > 0.1 ? 0.1 : timeout
                    if shouldShowTimeoutError {
                        verificationInputConfig.errorMessage = formattedTimeout
                        phoneInputConfig.errorMessage = formattedTimeout
                    }
                } else {
                    timeout = 0
                    if wasPreviousErrorTimeout {
                        verificationInputConfig.errorMessage = ""
                        phoneInputConfig.errorMessage = ""
                        wasPreviousErrorTimeout = false
                        shouldShowTimeoutError = true
                    }
                }
            }
        }
    }

    /// Stops and invalidates the countdown timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Sends an authentication code to the provided phone number
    ///
    /// Makes an API request to send a verification code and handles the response,
    /// including any errors or timeout values received
    public func sendAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        do {
            let response = try await authInteractor.makeLoginCodeRequest(phoneNumber)

            if response.success {
                didSendCode = true
            }

            timeout = response.timeout
            wasPreviousErrorTimeout = true
            shouldShowTimeoutError = true
        } catch let error as GenericErrors {
            phoneInputConfig.errorMessage = error.message
            verificationInputConfig.errorMessage = error.message
            shouldShowTimeoutError = false
        } catch {
            phoneInputConfig.errorMessage = GenericErrors.unknownError.message
            verificationInputConfig.errorMessage = GenericErrors.unknownError.message
            shouldShowTimeoutError = false
        }
    }

    /// Verifies the entered authentication code
    ///
    /// Makes an API request to verify the code and handles the response,
    /// including storing authentication tokens on success
    public func verifyAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        let code = verificationInputConfig.text

        do {
            let response = try await authInteractor.makeLoginRequest(
                phoneNumber,
                code
            )

            _ = [
                KeychainHelper
                    .set(for: .authenticationToken, value: response.accessToken),
                KeychainHelper
                    .set(for: .refreshToken, value: response.refreshToken),
            ].first { !$0 }

            baseEnvironmentConfig.isLoggedIn = true
        } catch let error as GenericErrors {
            phoneInputConfig.errorMessage = error.message
            verificationInputConfig.errorMessage = error.message
            shouldShowTimeoutError = false
        } catch {
            phoneInputConfig.errorMessage = GenericErrors.unknownError.message
            verificationInputConfig.errorMessage = GenericErrors.unknownError.message
            shouldShowTimeoutError = false
        }
    }

    /// Creates a binding for phone number validation
    ///
    /// Returns a binding that combines the timeout status and phone input validation
    /// - Returns: A binding to a Boolean indicating if the phone number input is valid
    private func createIsValidPhoneNumberBinding() -> Binding<Bool> {
        .init(
            get: {
                timeout == 0 && phoneInputConfig.isValid
            },
            set: { _ in }
        )
    }
}

/// SwiftUI preview provider for LoginScreen
#Preview {
    LoginScreen()
        .preferredColorScheme(.dark)
}
