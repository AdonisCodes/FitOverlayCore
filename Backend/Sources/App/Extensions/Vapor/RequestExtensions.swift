// RequestExtensions.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import Temporal
import Vapor

/// Extension on rquest to add DB aliases
internal extension Request {
    /// Write DB
    var dbWrite: Database {
        db(.readOnly)
    }

    /// Read-Only DB
    var dbReadOnly: Database {
        db(.readOnly)
    }
}

internal extension Request {
    var temporalClient: TemporalClient {
        application.temporalClient
    }
}
