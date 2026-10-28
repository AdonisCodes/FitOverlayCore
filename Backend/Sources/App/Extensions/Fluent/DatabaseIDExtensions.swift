// DatabaseIDExtensions.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Fluent

internal extension DatabaseID {
    /// Id for primary (write / read) database
    static let primary = DatabaseID(string: "primary")
    /// Id for the closest geographical readonly database
    static let readOnly = DatabaseID(string: "readOnly")
}
