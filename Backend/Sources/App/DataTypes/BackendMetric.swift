// BackendMetric.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import Foundation
import Prometheus

/// Enum for managing backend metrics.
internal enum BackendMetric {
    /// Counter for successful verification codes sent.
    public static let totalSuccessfulVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": MetricStatus.success.rawValue]
    )

    /// Counter for failed verification codes sent.
    public static let totalFailedVerificationCodesSent = MetricsService.global.makeCounter(
        name: "total_verification_codes_sent",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    /// Counter for total users created.
    public static let totalUsersCreated = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": MetricStatus.success.rawValue]
    )

    /// Counter for users that already exist.
    public static let totalUsersAlreadyExists = MetricsService.global.makeCounter(
        name: "total_users_created",
        labels: ["status": MetricStatus.alreadyExists.rawValue]
    )

    /// Counter for successful token refresh attempts.
    public static let totalSuccessfulTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": MetricStatus.success.rawValue]
    )

    /// Counter for failed token refresh attempts.
    public static let totalFailedTokensRefreshed = MetricsService.global.makeCounter(
        name: "total_token_refresh_attempts",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    /// Counter for logout attempts.
    public static let totalLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": MetricStatus.success.rawValue]
    )

    /// Counter for failed logout attempts.
    public static let totalFailedLogoutAttempted = MetricsService.global.makeCounter(
        name: "total_logout_attempts",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    /// Counter for profile pictures generated.
    public static let totalProfilePicturesGenerated = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    /// Counter for failed profile picture generation.
    public static let totalProfilePicturesGenerationFailed = MetricsService.global.makeCounter(
        name: "total_profile_pictures_generated",
        labels: [
            "status": MetricStatus.fail.rawValue,
        ]
    )

    /// Counter for text messages sent.
    public static let totalTextMessagesSent = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    /// Counter for failed text messages sent.
    public static let totalTextMessagesSentFailed = MetricsService.global.makeCounter(
        name: "total_text_messages_sent",
        labels: [
            "status": MetricStatus.fail.rawValue,
        ]
    )

    /// Counter for OpenAI image generation requests.
    public static let openAIImageGenerationRequests = MetricsService.global.makeCounter(
        name: "openai_image_generation_requests"
    )

    /// Creates a counter for OpenAI image generation requests.
    /// - Parameter status: The status of the request.
    /// - Returns: A `Prometheus.Counter` object.
    public static func openAIImageGenerationRequest(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "openai_image_generation_requests",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter OAuth request metrics.
    /// - Parameter status: The status of the OAuth request (success/fail/etc).
    /// - Returns: A Prometheus counter for Twitter OAuth requests with the given status.
    public static func twitterOAuthRequest(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_oauth_requests",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter user token conversion metrics.
    /// - Parameter status: The status of the token conversion (success/fail/etc).
    /// - Returns: A Prometheus counter for Twitter token conversions with the given status.
    public static func twitterUserTokensConverted(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_user_tokens_converted",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track Twitter post tweet metrics.
    /// - Parameter status: The status of posting the tweet (success/fail/etc).
    /// - Returns: A Prometheus counter for tweet posts with the given status.
    public static func twitterPostTweet(
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "twitter_post_tweet",
            labels: [
                "status": status.rawValue,
            ]
        )
    }

    /// Creates a counter to track RSS feed reader metrics.
    /// - Parameters:
    ///   - status: The status of the RSS feed read.
    ///   - url: The URL of the RSS feed.
    ///   - isRSSFeed: Optional flag indicating if the URL is an RSS feed.
    ///   - didThrowOnFeedInitialization: Flag indicating if an error occurred during feed initialization.
    /// - Returns: A Prometheus counter for RSS feed reads with the given status.
    public static func rssFeedReaderMetric(
        status: MetricStatus,
        url: URL,
        isRSSFeed: Bool? = nil,
        didThrowOnFeedInitialization: Bool = false
    ) -> Prometheus.Counter {
        let labels = [
            "status": status.rawValue,
            "url": url.absoluteString,
            "is_rss_feed": isRSSFeed.map { $0 ? "true" : "false" } ?? "undefined",
            "did_throw_on_feed_initialization": didThrowOnFeedInitialization ? "true" : "false",
        ]

        return MetricsService.global.makeCounter(
            name: "rss_feed_read_call",
            labels: labels
        )
    }

    /// Creates a counter to track chat completion service calls.
    /// - Parameters:
    ///   - platform: The platform used for chat completion.
    ///   - model: The model used for chat completion.
    ///   - status: The status of the service call.
    /// - Returns: A Prometheus counter for chat completion service calls with the given status.
    public static func chatCompletionServiceCall(
        platform: ChatCompletionPlatform,
        model: ChatCompletionModel,
        status: MetricStatus
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "chat_completion_service_call",
            labels: [
                "status": status.rawValue,
                "platform": platform.rawValue,
                "model": model.rawValue,
            ]
        )
    }

    /// Counter for successful licence activations.
    public static let totalLicenseActivations = MetricsService.global.makeCounter(
        name: "total_license_activations",
        labels: ["status": MetricStatus.success.rawValue]
    )

    /// Counter for failed licence activations.
    public static let totalFailedLicenseActivations = MetricsService.global.makeCounter(
        name: "total_license_activations",
        labels: ["status": MetricStatus.fail.rawValue]
    )

    /// Counter for purchase webhook events received.
    public static let totalPurchaseWebhooksReceived = MetricsService.global.makeCounter(
        name: "total_purchase_webhooks_received",
        labels: ["status": MetricStatus.success.rawValue]
    )

    /// Counter for media files uploaded to Tigris.
    public static let totalMediaFilesUploadedToTigris = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": MetricStatus.success.rawValue,
        ]
    )

    /// Counter for failed media file uploads to Tigris.
    public static let totalMediaFilesUploadedToTigrisFailed = MetricsService.global.makeCounter(
        name: "total_media_files_uploaded_to_tigris",
        labels: [
            "status": MetricStatus.fail.rawValue,
        ]
    )

    /// Creates a counter to track Article Content Scraper Service metrics.
    /// - Parameters:
    ///   - status: The status of the scraping.
    ///   - payload: The FitOverlayWebCore API payload
    /// - Returns: A Prometheus counter for article content scraping with the given status.
    public static func scrapeArticleContentCall(
        status: MetricStatus,
        payload: AutomaWebCoreAPIEndpointPayload
    ) -> Prometheus.Counter {
        MetricsService.global.makeCounter(
            name: "scrape_article_content",
            labels: [
                "status": status.rawValue,
                "payload": String(reflecting: payload),
            ]
        )
    }
}
