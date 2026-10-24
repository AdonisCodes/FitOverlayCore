// RegisterScreen.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import FitOverlayUIKit
import DataTypes
import SwiftUI

/// A view that handles the user registration process through phone number verification
///
/// This screen manages a two-step registration process:
/// 1. Phone number input and verification code request
/// 2. Verification code input and account creation
///
/// The view handles:
/// - Phone number validation
/// - SMS code sending and verification
/// - Timeout management for code resending
/// - Error handling and display
internal struct RegisterScreen: View {
    /// Configuration for the phone number input field
    @StateObject public var phoneInputConfig: PhoneNumberTextInputComponentConfig = .init()

    /// Configuration for the verification code input field
    @StateObject public var verificationInputConfig: VerificationCodeInputComponentConfig = .init()

    /// Countdown timer for code resending timeout
    @State public var timeout: Double = 0

    /// Environment configuration containing API base URL and authentication state
    @EnvironmentObject public var baseEnvironmentConfig: BaseAppEnvironmentObject

    /// Authentication controller for handling API requests
    public var authInteractor: AuthenticationControllerInteractor {
        .init(baseURL: baseEnvironmentConfig.apiBaseURL)
    }

    /// State tracking whether the previous error was a timeout
    @State private var wasPreviousErrorTimeout: Bool = false

    /// Controls whether timeout error messages should be displayed
    @State private var shouldShowTimeoutError: Bool = true

    /// Timer instance for managing countdown
    @State private var timer: Timer?

    /// Indicates whether verification code has been sent
    @State private var didSendCode: Bool = false

    /// Tracks if the verification code input is valid
    @State private var isValidVerificationScreenState: Bool = false

    /// Formats the timeout duration into a user-friendly message
    private var formattedTimeout: String {
        let error = String(format: "%.1f", timeout)
        if !didSendCode {
            return "Please wait \(error)s before trying again!"
        } else {
            return "Please wait \(error)s before resending the code!"
        }
    }

    /// Creates a new instance of the registration screen
    public init() {}

    /// The main view body implementing the registration UI
    ///
    /// Displays either:
    /// - Phone number input screen with validation
    /// - Verification code input screen with resend option
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

    /// Starts the countdown timer for code resending timeout
    ///
    /// Updates the UI every 0.1 seconds and manages error messages
    @MainActor
    private func startTimer() {
        timer?.invalidate() // Invalidate existing timer if it exists

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

    /// Sends authentication code to the provided phone number
    ///
    /// Handles API response and updates UI state based on the result
    public func sendAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        do {
            let response = try await authInteractor.makeRegisterCodeRequest(
                phoneNumber
            )

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
    /// On successful verification:
    /// - Stores authentication tokens in keychain
    /// - Updates login state
    /// - Handles potential errors
    public func verifyAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        let code = verificationInputConfig.text

        do {
            let response = try await authInteractor.makeRegisterRequest(
                phoneNumber,
                code
            )

            _ = [
                KeychainHelper
                    .set(
                        for: .authenticationToken,
                        value: response.accessToken
                    ),
                KeychainHelper
                    .set(for: .refreshToken, value: response.refreshToken),
            ].first { !$0 }

            baseEnvironmentConfig.isLoggedIn = true
            baseEnvironmentConfig.isAccepted = false
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

    /// Creates a binding for phone number validation state
    ///
    /// Returns a computed binding that considers both timeout and phone number validity
    private func createIsValidPhoneNumberBinding() -> Binding<Bool> {
        .init(get: {
            timeout == 0 && phoneInputConfig.isValid
        }, set: { _ in })
    }
}

#Preview {
    RegisterScreen()
}
