// ArticleContentScraperServiceError.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

internal enum ArticleContentScraperServiceError: Error {
    case textToArticleFailed(error: Error, message: String? = nil)
}
