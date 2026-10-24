// AIPromptFormatterService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import OpenAI
import Vapor

/// Service for formatting AI prompts for generating profile pictures.
internal enum AIPromptFormatterService {
    /// Creates a query for generating a profile picture using OpenAI's image generation model.
    /// - Parameter username: The username to be used as a keyword in the prompt.
    /// - Returns: A `GenerateImageQuery` configured with the prompt and image generation settings.
    public static func createOpenAIProfilePictureQuery(username: String) -> GenerateImageQuery {
        // Define the prompt for generating the image
        let prompt = """
        Generate a cute, \
        emoji-like icon in a minimalistic style with a dark background (#000000) and subtle \
        neon green (#00FF00) accents to match the aesthetic of a sleek and modern design. \
        Incorporate soft and rounded edges, ensuring the character or object is whimsical and playful. \
        Use the keyword \(username) to define the main theme of the icon \
        (e.g., Potato-Plushy, Penguin-Rainbow, Peachy-Carrot, Whimsical-Spoon, Fuzzy-Slinky). \
        Ensure the design feels cohesive, vibrant, and adorable, with a touch of neon glow around the \
        object for added emphasis. The background should remain simple and dark to enhance the contrast. \
        Focus heavily on the visuals, while completely excluding any typogrophy or text.
        """

        // Return the image query with specified settings
        return .init(
            model: .dall_e_3,
            prompt: prompt,
            totalImagesToGenerate: 1,
            quality: .hdQuality,
            imageSize: ._1024,
            imageStyle: .vivid
        )
    }
}
