// ProfilePictureActivities.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Foundation
import Temporal
import Vapor

internal struct CreateProfilePictureActivityInput: Sendable, Codable {
    let payload: UserDTO
}

/// Temporal activity for user profile picture creation.
@ActivityContainer
internal struct ProfilePictureActivities {
    /// Create
    /// - Parameters:
    ///   - input: The input for creating a profile picture.
    /// - Throws: Throws an error if the profile picture creation fails.
    @Sendable @Activity
    public func createPicture(input: CreateProfilePictureActivityInput) async throws {
        let payload = input.payload
        let logger = Logger(label: "temporal")
        let profilePictureService = ProfilePictureService(logger: logger)

        do {
            // Create a profile picture for the user
            let profilePictureKey = try await profilePictureService.createProfilePicture(
                for: payload
            )
            // Log the successful creation of the profile picture
            logger.info(
                "Profile picture created",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(payload.id?.uuidString ?? ""),
                    "username": .string(payload.username),
                    "profilePictureKey": .string(profilePictureKey),
                ]
            )
        } catch {
            // Capture the current stack trace
            let stackTrace = Thread.callStackSymbols.joined(separator: "\n")

            // Log the error details
            logger.error(
                "Failed to create profile picture",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(payload.id?.uuidString ?? ""),
                    "username": .string(payload.username),
                    "error": .string(error.localizedDescription),
                    "stackTrace": .string(stackTrace),
                ]
            )
        }
    }
}
