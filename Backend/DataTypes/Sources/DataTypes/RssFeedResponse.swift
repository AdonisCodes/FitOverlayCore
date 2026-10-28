// RssFeedResponse.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Response structure containing parsed feed items and metadata.
/// Used to encapsulate the results of an RSS feed parsing operation.
///
/// - Note: Conforms to Vapor's `Content` protocol for easy encoding/decoding.
public struct RssFeedResponse: Content {
    /// The collection of parsed feed items.
    /// Contains all successfully parsed items from the feed source.
    public let items: [GenericRSSFeedItem]

    /// Indicates whether the source was a valid RSS or Atom feed.
    /// Used to verify the validity of the parsed feed.
    public let isRssFeed: Bool

    /// Creates a new RSS feed response.
    /// - Parameters:
    ///   - items: The collection of parsed feed items.
    ///   - isRssFeed: Indicates whether the source was a valid RSS or Atom feed.
    /// - Returns: A fully initialized `RssFeedResponse` instance.
    public init(items: [GenericRSSFeedItem], isRssFeed: Bool) {
        // Store the parsed items and feed validity status
        self.items = items
        self.isRssFeed = isRssFeed
    }
}

/// A standardized representation of an RSS or Atom feed item.
/// This struct normalizes the different formats into a common structure
/// that can be used throughout the application.
///
/// Use this struct to store and manipulate feed items from various RSS and Atom sources
/// in a consistent format across the application.
///
/// - Note: Conforms to Vapor's `Content` protocol for easy encoding/decoding.
public struct GenericRSSFeedItem: Content {
    /// The title of the feed item.
    /// This field typically contains the headline or name of the content.
    public let title: String

    /// URLs associated with this feed item, typically including the permalink.
    /// May contain multiple links such as the main link, media links, or alternate formats.
    public let links: [String]

    /// A summary or brief description of the feed item content.
    /// This usually contains a snippet or excerpt of the full content.
    public let description: String

    /// The date when the feed item was published.
    /// Used for sorting and displaying feed items chronologically.
    public let publishDate: Date

    /// The full content of the feed item, if available.
    /// May contain HTML markup or plain text depending on the feed source.
    public let content: String?

    /// YouTube-specific metadata, if this feed item represents a YouTube video.
    /// Contains additional information specific to YouTube content.
    public let youTubeVideoInfo: RSSFeedItemYouTubeVideoInfo?

    /// Creates a new generic RSS feed item.
    /// - Parameters:
    ///   - title: The title of the feed item.
    ///   - links: URLs associated with this feed item.
    ///   - description: A summary or brief description of the feed item.
    ///   - publishDate: The date when the feed item was published.
    ///   - content: The full content of the feed item, if available.
    ///   - youTubeVideoInfo: YouTube-specific metadata, if applicable.
    /// - Returns: A fully initialized `GenericRSSFeedItem` instance.
    public init(
        title: String,
        links: [String],
        description: String,
        publishDate: Date,
        content: String? = nil,
        youTubeVideoInfo: RSSFeedItemYouTubeVideoInfo? = nil
    ) {
        // Assign all provided values to their corresponding properties
        self.title = title
        self.links = links
        self.description = description
        self.publishDate = publishDate
        self.content = content
        self.youTubeVideoInfo = youTubeVideoInfo
    }
}

/// Contains YouTube-specific metadata for feed items that represent YouTube videos.
/// This struct provides additional context for feed items sourced from YouTube channels.
///
/// - Note: Conforms to Vapor's `Content` protocol for easy encoding/decoding.
public struct RSSFeedItemYouTubeVideoInfo: Content {
    /// The YouTube channel identifier.
    /// Uniquely identifies the channel that published the video.
    public let channelID: String

    /// The YouTube video identifier.
    /// Uniquely identifies the specific video within YouTube's platform.
    public let videoID: String

    /// Creates a new YouTube video info object.
    /// - Parameters:
    ///   - channelID: The YouTube channel identifier.
    ///   - videoID: The YouTube video identifier.
    /// - Returns: A fully initialized `RSSFeedItemYouTubeVideoInfo` instance.
    public init(channelID: String, videoID: String) {
        // Store the channel and video identifiers
        self.channelID = channelID
        self.videoID = videoID
    }
}
