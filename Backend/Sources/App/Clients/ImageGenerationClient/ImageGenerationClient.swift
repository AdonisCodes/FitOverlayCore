// ImageGenerationClient.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import DataTypes
import Foundation
import OpenAI
import Vapor

/// A protocol defining the base requirements for an image generation client.
///
/// This protocol requires conforming types to provide a logger and a method for generating images.
public protocol ImageGenerationClientBase {
    /// Logger instance for tracking operations and errors.
    var logger: Logger { get }

    /// Generates images based on the provided query parameters.
    ///
    /// - Parameter query: The query containing generation parameters like prompt, model, etc.
    /// - Returns: A `GenerateImageResult` containing the generated images and metadata.
    /// - Throws: An error if the image generation fails.
    func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult
}

/// A structure representing the query parameters for image generation.
///
/// This struct encapsulates the parameters required for generating images, such as model, prompt, and optional
/// settings.
public struct GenerateImageQuery: Content {
    /// The model to use for image generation.
    public let model: GenerateImageModel

    /// The prompt describing the desired image.
    public let prompt: String

    /// The total number of images to generate.
    public let totalImagesToGenerate: Int?

    /// The quality setting for the generated images.
    public let quality: GenerateImageQuality?

    /// The size of the generated images.
    public let imageSize: GenerateImageSize?

    /// The style of the generated images.
    public let imageStyle: GenerateImageStyle?

    /// Initializes a new instance of `GenerateImageQuery`.
    ///
    /// - Parameters:
    ///   - model: The model to use for image generation.
    ///   - prompt: The prompt describing the desired image.
    ///   - totalImagesToGenerate: The total number of images to generate (optional).
    ///   - quality: The quality setting for the images (optional).
    ///   - imageSize: The size of the images (optional).
    ///   - imageStyle: The style of the images (optional).
    public init(
        model: GenerateImageModel,
        prompt: String,
        totalImagesToGenerate: Int? = nil,
        quality: GenerateImageQuality? = nil,
        imageSize: GenerateImageSize? = nil,
        imageStyle: GenerateImageStyle? = nil
    ) {
        self.model = model
        self.prompt = prompt
        self.totalImagesToGenerate = totalImagesToGenerate
        self.quality = quality
        self.imageSize = imageSize
        self.imageStyle = imageStyle
    }
}

/// An enumeration representing the models available for image generation.
///
/// This enum defines the supported models for generating images, such as DALL-E 2 and DALL-E 3.
public enum GenerateImageModel: String, Codable, Sendable {
    // swiftlint:disable identifier_name
    /// Represents the DALL-E 2 model.
    case dall_e_2 = "dall-e-2"

    /// Represents the DALL-E 3 model.
    case dall_e_3 = "dall-e-3"

    // swiftlint:enable identifier_name

    /// Retrieves the platform-specific client for the model.
    ///
    /// - Parameter logger: The logger instance to use for operation tracking.
    /// - Returns: The corresponding platform client for the model.
    /// - Throws: An error if the client initialization fails.
    public func getPlatformClient(logger: Logger) throws -> any ImageGenerationClientBase {
        switch self {
        case .dall_e_2, .dall_e_3:
            try OpenAIImageGenerationClient(logger: logger)
        }
    }
}

/// A structure representing the result of an image generation operation.
///
/// This struct contains the generated images and associated metadata.
public struct GenerateImageResult: Content {
    /// The generated images as an array of data.
    public let images: [Data]

    /// The metadata associated with the generated images in JSON format.
    public let metadataJSON: Data
}

/// An enumeration representing the quality settings for image generation.
///
/// This enum defines the available quality settings for generated images, such as HD and standard.
public enum GenerateImageQuality: String, Codable, Sendable {
    /// Represents high-definition quality.
    case hdQuality = "hd"

    /// Represents standard quality.
    case standard
}

/// An enumeration representing the size options for image generation.
///
/// This enum defines the available sizes for generated images, including options specific to DALL-E 3 models.
public enum GenerateImageSize: String, Codable, Sendable {
    // swiftlint: disable identifier_name

    /// Represents a size of 1024x1024 pixels.
    case _1024 = "1024x1024"

    /// Represents a size of 1024x1792 pixels, specific to DALL-E 3 models.
    case _1024_1792 = "1024x1792"

    /// Represents a size of 1792x1024 pixels, specific to DALL-E 3 models.
    case _1792_1024 = "1792x1024"

    /// Represents a size of 256x256 pixels.
    case _256 = "256x256"

    /// Represents a size of 512x512 pixels.
    case _512 = "512x512"
    // swiftlint: enable identifier_name
}

/// An enumeration representing the style options for image generation.
///
/// This enum defines the available styles for generated images, such as natural and vivid.
public enum GenerateImageStyle: String, Codable, Sendable {
    /// Represents a natural style.
    case natural

    /// Represents a vivid style.
    case vivid
}

/// A client for generating images using various models.
///
/// This client acts as a facade for different image generation platforms, allowing
/// the generation of images based on specified query parameters.
internal struct ImageGenerationClient: ImageGenerationClientBase {
    /// Logger instance for tracking operations and errors
    public let logger: Logger

    /// Generates images based on the provided query parameters.
    ///
    /// This function delegates the image generation task to the appropriate platform client
    /// based on the model specified in the query. It ensures that at least one image is generated
    /// and logs the operation.
    ///
    /// - Parameter query: The query containing generation parameters like prompt, model, etc.
    /// - Returns: A `GenerateImageResult` containing the generated images and metadata.
    /// - Throws: `GenericErrors.missingImage` if no images are generated.
    public func generateImage(_ query: GenerateImageQuery) async throws -> GenerateImageResult {
        // Obtain the platform-specific client based on the query's model
        let client = try query.model.getPlatformClient(logger: logger)

        // Generate images using the platform client
        let res = try await client.generateImage(query)

        // Ensure that images are generated
        guard !res.images.isEmpty else {
            logger.info(
                "No images generated.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "query": .string(String(reflecting: query)),
                ]
            )
            throw GenericErrors.missingImage
        }

        // Return the result containing images and metadata
        return res
    }
}
