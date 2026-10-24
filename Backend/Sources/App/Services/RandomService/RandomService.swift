// RandomService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import Vapor

/// Service for generating random values.
internal enum RandomService {
    /// List of animal names.
    public static let animals = [
        "Dog",
        "Cat",
        "Bird",
        "Elephant",
        "Penguin",
        "Panda",
        "Zebra",
        "Walrus",
        "Otter",
        "Kangaroo",
        "Moose",
        "Donkey",
        "Hedgehog",
    ]

    /// List of object names.
    public static let objects = [
        "Chair",
        "Table",
        "Spoon",
        "Toaster",
        "Cup",
        "Waffle",
        "Lollipop",
        "Bubble",
        "Cupcake",
        "Biscuit",
        "Sprinkle",
        "Banjo",
        "Popsicle",
        "Doodle",
    ]

    /// List of adjectives.
    public static let adjectives = [
        "Whimsical",
        "Cute",
        "Adorable",
        "Funny",
        "Cool",
        "Awesome",
        "Fluffy",
        "Bouncy",
        "Snuggly",
        "Sparkly",
        "Wiggly",
        "Wacky",
        "Bizarre",
        "Cheeky",
        "Peachy",
        "Fizzy",
        "Dizzy",
        "Goofy",
        "Fuzzy",
        "Smiley",
        "Chirpy",
    ]

    /// List of moods.
    public static let moods = [
        "Snappy",
        "Sunny",
        "Quirky",
        "Jolly",
        "Happy",
        "Bright",
        "Playful",
        "Glittery",
        "Dreamy",
        "Friendly",
    ]

    /// Combined list of all words.
    public static let allWords = adjectives + moods + animals + objects

    /// Generates a random username.
    /// - Returns: A string representing a random username.
    public static func randomUsername() -> String {
        // swiftlint:disable force_unwrapping
        let mood = moods.randomElement()!
        let adjective = adjectives.randomElement()!
        let object = objects.randomElement()!
        // swiftlint:enable force_unwrapping

        // Generate a random UUID and take the first 4 characters

        // swiftlint:disable force_unwrapping
        let randomAppend = UUID().uuidString.split(separator: "-").first!.prefix(4)
        // swiftlint:enable force_unwrapping

        return "\(mood)\(adjective)\(object)\(randomAppend)"
    }

    /// Generates a random code.
    /// - Returns: A string representing a random code.
    public static func randomCode() -> String {
        // swiftlint:disable force_unwrapping
        let first = allWords.randomElement()!.lowercased()
        let second = allWords.randomElement()!.lowercased()
        // swiftlint:enable force_unwrapping

        return "\(first)-\(second)"
    }
}
