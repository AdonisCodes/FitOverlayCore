// RequestExtensions.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent
import Vapor

/// Extension on request to add DB aliases
internal extension Request {
    /// Write DB
    var dbWrite: Database {
        db(.primary)
    }

    /// Read-Only DB
    var dbReadOnly: Database {
        db(.readOnly)
    }
}
