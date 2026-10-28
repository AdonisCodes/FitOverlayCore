// FitOverlayKit.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

// Umbrella module: importing `FitOverlayKit` gives access to the whole engine.

@_exported import FitDataModel
@_exported import FitParser
@_exported import OverlayLayout
@_exported import OverlayRender
@_exported import OverlayTimeSync

/// Namespace with package-level metadata.
public enum FitOverlayKitInfo {
    /// Semantic version of the engine package
    public static let version = "0.1.0"
}
