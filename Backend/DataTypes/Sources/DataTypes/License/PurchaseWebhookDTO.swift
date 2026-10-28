// PurchaseWebhookDTO.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// The payment provider a purchase event originated from.
public enum PurchaseProvider: String, Codable, Sendable, CaseIterable {
    /// Stripe (web checkout — primary channel for the one-time lifetime licence)
    case stripe
    /// Apple App Store (StoreKit — Mac App Store / iOS in-app purchase)
    case appStore
    /// Any other provider (e.g. Paddle, LemonSqueezy) added later
    case other
}

/// A normalized purchase event, decoded from provider-specific webhook payloads.
/// NOTE: This is a stub shape — provider payload verification (Stripe signatures,
/// App Store server notifications JWS) is performed in the backend before this
/// DTO is constructed.
public struct PurchaseWebhookEventDTO: Content {
    /// The provider that emitted the event
    public let provider: PurchaseProvider

    /// Provider-specific event type (e.g. `checkout.session.completed`)
    public let eventType: String

    /// The purchased plan
    public let plan: LicensePlan

    /// Customer email, used to deliver the licence key
    public let customerEmail: String?

    /// Provider-side transaction/subscription identifier for reconciliation
    public let providerTransactionId: String?

    /// Initializes a new normalized purchase event.
    public init(
        provider: PurchaseProvider,
        eventType: String,
        plan: LicensePlan,
        customerEmail: String? = nil,
        providerTransactionId: String? = nil
    ) {
        self.provider = provider
        self.eventType = eventType
        self.plan = plan
        self.customerEmail = customerEmail
        self.providerTransactionId = providerTransactionId
    }
}

/// Response acknowledging a processed (or stubbed) purchase webhook.
public struct PurchaseWebhookResponseDTO: Content {
    /// Whether the event was accepted
    public let received: Bool

    /// The licence key that was generated, when applicable
    public let licenseKey: String?

    /// Initializes a new purchase webhook response.
    public init(received: Bool, licenseKey: String? = nil) {
        self.received = received
        self.licenseKey = licenseKey
    }
}
