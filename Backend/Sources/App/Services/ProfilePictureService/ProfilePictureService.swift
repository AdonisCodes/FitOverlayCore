// ProfilePictureService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Fluent
import OpenAI
import Vapor

/// Service for managing profile picture generation.
internal struct ProfilePictureService {
    /// Logger for logging messages.
    public let logger: Logger

    /// Creates a profile picture for a user.
    /// - Parameters:
    ///   - user: The user data transfer object.
    ///   - totalRegenerationAttempts: The total number of regeneration attempts.
    ///   - excludeText: Flag indicating whether to exclude text from the image.
    /// - Returns: A string representing the S3 URL of the generated profile picture.
    /// - Throws: Throws an error if profile picture generation fails.
    public func createProfilePicture(
        for user: UserDTO,
        totalRegenerationAttempts: Int = 3,
        excludeText: Bool = true
    ) async throws -> String {
        do {
            let tigrisService = try TigrisService(logger: logger)
            let messageService = MessageService()

            // Create a query for generating the profile picture
            let query = AIPromptFormatterService.createOpenAIProfilePictureQuery(
                username: user.username
            )
            let queryString = String(reflecting: query)

            guard let userId = user.id?.uuidString else {
                throw GenericErrors.invalidUserId
            }

            // Log the start of profile picture generation
            logger.info(
                "Generating profile picture",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(userId),
                    "username": .string(user.username),
                    "query": .string(queryString),
                ]
            )

            // Send a Discord webhook event for profile picture generation
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "generating profile picture for \(userId) - \(user.username)",
                    event: queryString,
                    logger: logger
                )

            // Generate the image
            let result = try await generateImage(
                totalRegenerationAttempts: totalRegenerationAttempts,
                query: query,
                excludeText: excludeText
            )

            // Generate the S3 URL for the image
            let s3Url = try generateImageKey(for: user)

            let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")
            let openaiOutputs3Url = "s3://\(bucket)/openai/\(user.username)-\(UUID().uuidString).json"

            let jsonEncoder = JSONEncoder()

            // Upload the image and metadata to S3
            _ = try await (
                tigrisService
                    .put(
                        input: s3Url,
                        content: .init(data: result.images[0]),
                        acl: .publicRead,
                        contentType: "image/jpeg"
                    ),
                tigrisService.put(
                    input: openaiOutputs3Url,
                    content: .init(
                        string: jsonEncoder.encode(result.metadataJSON).base64EncodedString()
                    ),
                    acl: .private,
                    contentType: "application/json"
                )
            )

            // Get the Tigris URL for the image
            let url = try tigrisService.getTigrisUrl(s3Url)

            // Send a Discord webhook event for successful profile picture generation
            try messageService
                .sendDiscordWebhookAppEvent(
                    input: "generated profile picture for \(userId) - \(user.username)",
                    event: queryString,
                    imageUrl: url,
                    logger: logger
                )

            // Log the successful generation of the profile picture
            logger.info(
                "Successfully generated profile picture for user",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "userId": .string(userId),
                    "username": .string(user.username),
                    "imageKey": .string(s3Url),
                    "cacheKey": .string(openaiOutputs3Url),
                    "tigrisUrl": .string(url),
                ]
            )

            BackendMetric.totalProfilePicturesGenerated.increment()
            return s3Url
        } catch {
            // Log the error for failed profile picture generation
            logger.error(
                "Failed to generate profile picture",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "user": .string("\(user)"),
                    "error": .string("\(error.localizedDescription)"),
                ]
            )

            BackendMetric.totalProfilePicturesGenerationFailed.increment()

            throw error
        }
    }

    /// Generates an image based on the provided query.
    /// - Parameters:
    ///   - totalRegenerationAttempts: The total number of regeneration attempts.
    ///   - query: The query for generating the image.
    ///   - excludeText: Flag indicating whether to exclude text from the image.
    /// - Returns: A `GenerateImageResult` object containing the generated image.
    /// - Throws: Throws an error if image generation fails.
    private func generateImage(
        totalRegenerationAttempts: Int,
        query: GenerateImageQuery,
        excludeText: Bool
    ) async throws -> GenerateImageResult {
        let textExtractionService = TextExtractionService(logger: logger)
        let imageClient = ImageGenerationClient(logger: logger)

        var hasText = false
        var totalAttemptsLeft = totalRegenerationAttempts

        var result: GenerateImageResult?
        // If there is still text on the image after 3 attempts, we will ignore the text and continue generating the
        // image
        repeat {
            let res = try await imageClient.generateImage(query)
            result = res

            hasText = try await !textExtractionService
                .getTextToSimpleString(
                    from: res.images[0]
                ).isEmpty

            totalAttemptsLeft -= 1
        } while excludeText && hasText && totalAttemptsLeft > 0

        guard let result else {
            throw GenericErrors.missingImage
        }

        // Log the attempt to generate an image without text
        logger.info(
            "Attempted to generate an image without text",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "totalAttempts": .string("\(totalRegenerationAttempts - totalAttemptsLeft)"),
                "hasText": .string("\(hasText)"),
            ]
        )

        return result
    }

    /// Generates an image key for a user.
    /// - Parameter user: The user data transfer object.
    /// - Returns: A string representing the S3 URL of the image.
    /// - Throws: Throws an error if the user ID is invalid.
    public func generateImageKey(for user: UserDTO) throws -> String {
        let bucket = try Environment.getOrThrow("TIGRIS_MEDIA_BUCKET_NAME")

        guard let userId = user.id?.uuidString else {
            throw GenericErrors.invalidUserId
        }

        return "s3://\(bucket)/profile-picture/v1/\(userId).jpg"
    }
}
