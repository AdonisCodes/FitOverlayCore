// BackendMetric.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// A minimal counter abstraction used by `BackendMetric`.
/// The reference implementation exported Prometheus metrics; FitOverlay keeps the same
/// call sites but ships a no-op counter until a metrics backend is wired up.
/// TODO: Swap for `swift-prometheus` counters once observability infra is decided.
internal struct MetricCounter: Sendable {
    /// Metric name
    public let name: String
    /// Metric status label
    public let status: String

    /// Increments the counter. Currently a no-op placeholder.
    public func increment() {
        // Intentionally empty — see TODO above.
    }
}

/// Enum for managing backend metrics.
internal enum BackendMetric {
    /// Counter for successful verification codes sent.
    public static let totalSuccessfulVerificationCodesSent = MetricCounter(
        name: "total_verification_codes_sent", status: "success"
    )

    /// Counter for failed verification codes sent.
    public static let totalFailedVerificationCodesSent = MetricCounter(
        name: "total_verification_codes_sent", status: "fail"
    )

    /// Counter for total users created.
    public static let totalUsersCreated = MetricCounter(
        name: "total_users_created", status: "success"
    )

    /// Counter for users that already exist.
    public static let totalUsersAlreadyExists = MetricCounter(
        name: "total_users_created", status: "already_exists"
    )

    /// Counter for successful token refresh attempts.
    public static let totalSuccessfulTokensRefreshed = MetricCounter(
        name: "total_token_refresh_attempts", status: "success"
    )

    /// Counter for failed token refresh attempts.
    public static let totalFailedTokensRefreshed = MetricCounter(
        name: "total_token_refresh_attempts", status: "fail"
    )

    /// Counter for logout attempts.
    public static let totalLogoutAttempted = MetricCounter(
        name: "total_logout_attempts", status: "success"
    )

    /// Counter for failed logout attempts.
    public static let totalFailedLogoutAttempted = MetricCounter(
        name: "total_logout_attempts", status: "fail"
    )

    /// Counter for licence activations.
    public static let totalLicenseActivations = MetricCounter(
        name: "total_license_activations", status: "success"
    )

    /// Counter for failed licence activations.
    public static let totalFailedLicenseActivations = MetricCounter(
        name: "total_license_activations", status: "fail"
    )

    /// Counter for purchase webhook events received.
    public static let totalPurchaseWebhooksReceived = MetricCounter(
        name: "total_purchase_webhooks_received", status: "success"
    )
}
