// VerificationCodeInputComponent.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import SwiftUI

/// Represents the possible focus states for verification code input fields
public enum FocusedField {
    /// First input field
    case input1
    /// Second input field
    case input2
}

/// A SwiftUI view component that handles verification code input with two fields
public struct VerificationCodeInputComponent: View {
    /// Configuration object containing all the styling and behavior properties
    @ObservedObject public var config: VerificationCodeInputComponentConfig

    /// Tracks which input field currently has focus
    @FocusState public var focusedText: FocusedField?

    /// Callback triggered when the view appears
    public let onSelfAppear: (VerificationCodeInputComponentConfig) -> Void

    /// Initializes a new verification code input component
    /// - Parameters:
    ///   - config: Configuration object for styling and behavior
    ///   - focusedText: Initial focus state of the input fields
    ///   - onSelfAppear: Callback triggered when the view appears
    public init(
        config: VerificationCodeInputComponentConfig,
        focusedText: FocusedField? = nil,
        onSelfAppear: @escaping (VerificationCodeInputComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onSelfAppear = onSelfAppear
        self.focusedText = focusedText
    }

    /// Creates a binding for text input at the specified index
    /// - Parameter index: Index of the input field (0 or 1)
    /// - Returns: A binding that handles text input and formatting
    private func createTextBinding(index: Int) -> Binding<String> {
        .init(get: {
            // Split the text by separator and clean each component
            let splits = config.text.split(separator: "-", omittingEmptySubsequences: false).map { $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .illegalCharacters)
            }

            // Return the text at the specified index or empty string if index is out of bounds
            return splits.count >= index + 1 ? splits[index] : ""
        }, set: { new in
            // Split and clean existing text
            var splits = config.text.split(separator: "-", omittingEmptySubsequences: false).map { $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .illegalCharacters)
            }

            // Clean and format new input
            let newCleaned = new
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .symbols)
                .trimmingCharacters(in: .illegalCharacters)
                .replacingOccurrences(of: "-", with: "")

            // Update the text at the specified index
            splits[index] = newCleaned
            config.text = splits.joined(separator: "-")
        })
    }

    /// The body of the verification code input component
    public var body: some View {
        VStack(alignment: .leading) {
            // Display title if not empty
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(config.titleContentFont, config.titleSegmentColor)
            }

            HStack {
                // First input field
                TextField(config.ghostText, text: createTextBinding(index: 0))
                    .focused($focusedText, equals: .input1)
                    .onSubmit {
                        if focusedText == .input1 {
                            focusedText = .input2
                        }
                    }
                    .disabled(config.isDisabled)
                    .padding(config.padding)
                    .background(
                        config.currentBackgroundColor
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerSize: config.cornerRadius
                        )
                    )
                    .textCase(.lowercase)

                // Separator between input fields
                config.separatorIcon.image

                // Second input field
                TextField(config.ghostText, text: createTextBinding(index: 1))
                    .focused($focusedText, equals: .input2)
                    .onSubmit {
                        if focusedText == .input1 {
                            focusedText = .input2
                        }
                    }
                    .disabled(config.isDisabled)
                    .padding(config.padding)
                    .background(
                        config.currentBackgroundColor
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerSize: config.cornerRadius
                        )
                    )
                    .textCase(.lowercase)

            }.onAppear {
                onSelfAppear(config)
            }

            // Error message display
            Text("\(config.errorMessage) ")
                .fontTableFont(
                    config.titleContentFont,
                    config.errorSegmentColor
                )
        }
    }
}
