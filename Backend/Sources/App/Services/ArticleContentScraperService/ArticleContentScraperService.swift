// ArticleContentScraperService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import Fluent
import SwiftSoup
import Vapor

internal struct ArticleContentScraperService {
    internal let client: any Client
    internal let logger: Logger

    /// Scrape and parse an article in the form of a website
    /// - Parameter payload: FitOverlayWebCoreAPI payload used for configuring article URL
    /// and scraping configuration
    /// - Throws: an error getting website text content or converting website text content to an article
    /// - Returns: Article, structured data structure representing the article and it's contents
    public func scrapeArticle(payload: AutomaWebCoreAPIEndpointPayload) async throws -> Article {
        sendTelemetryDataOnScrapeArticleStarted(payload)
        let article = try await convertWebsiteTextContentToArticle(
            getWebsiteTextContent(payload),
            payload: payload
        )
        sendTelemetryDataOnScrapeArticleSuccess(payload: payload, article: article)
        return article
    }

    private func sendTelemetryDataOnScrapeArticleStarted(_ payload: AutomaWebCoreAPIEndpointPayload) {
        BackendMetric.scrapeArticleContentCall(status: .start, payload: payload).increment()
        logScrapeArticleStarted(payload: payload)
    }

    private func logScrapeArticleStarted(payload: AutomaWebCoreAPIEndpointPayload) {
        logger.info(
            "Scrape article content started.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "webcore_api_payload": .string(String(describing: payload))
            ]
        )
    }

    private func convertWebsiteTextContentToArticle(
        _ textContent: String,
        payload: AutomaWebCoreAPIEndpointPayload
    ) async throws -> Article {
        do {
            let jsonString = try await convertWebsiteTextContentToJSON(textContent)
            let jsonData = try websiteContentJSONStringToData(jsonString)
            return try decodeJSONDataToArticle(jsonData)
        } catch {
            sendTelemetryDataOnConvertWebsiteTextContentToArticleFail(error: error, payload: payload)
            throw ArticleContentScraperServiceError.textToArticleFailed(error: error)
        }
    }

    private func getWebsiteTextContent(_ payload: AutomaWebCoreAPIEndpointPayload) async throws -> String {
        let websiteHTMLString = try await FitOverlayWebCoreClient(client: client)
            .getWebsiteHTML(payload: payload)
        let parsedWebsiteHTML = try SwiftSoup.parse(websiteHTMLString)
        return try parsedWebsiteHTML.text()
    }

    private func convertWebsiteTextContentToJSON(_ textContent: String) async throws -> String {
        let response: String
        do {
            response = try await ChatCompletionClient(logger: logger).createChat(
                .init(
                    model: .gpt4omini,
                    prompt: getConvertWebsiteTextContentToJSONChatCompletionPrompt(textContent: textContent)
                )
            ).message
        } catch {
            throw ArticleContentScraperServiceError.textToArticleFailed(
                error: error,
                message: "Chat completion to convert website text content to formatted json failed."
            )
        }

        logger.info(
            "Length of article json as string.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "length": .string(String(response.count))
            ]
        )

        assert(
            response.starts(with: "{") && response[response.index(before: response.endIndex)] == "}",
            """
            chat completion response for converting article website text content to json format doesn't \
            start and end with dictionary keys.
            """
        )

        return response
    }

    private func getConvertWebsiteTextContentToJSONChatCompletionPrompt(textContent: String) -> String {
        """
        I want to convert an article to this format:

        {
            "title": "article title here",
            "author": "article writer/author here",
            "posted_at": "Date article was posted, don't provide 'posted_at' key if value not found",
            "content_markdown": "**full article content as markdown here**, formatted and well-punctuated; \
            not just a section of it"
        }

        Simply return **only a json code snippet without the snippet signs (```)** in the exact format \
        shown above.

        Here is the text extracted from the article web page:
        \(textContent)
        """
    }

    private func websiteContentJSONStringToData(_ jsonString: String) throws -> Data {
        guard
            let data = jsonString.data(using: .utf8)
        else {
            throw ArticleContentScraperServiceError.textToArticleFailed(
                error: Abort(.internalServerError),
                message: """
                Converting website content as a json string to type `Data` \
                failed -> results to `nil`
                """
            )
        }
        return data
    }

    private func decodeJSONDataToArticle(_ jsonData: Data) throws -> Article {
        do {
            return try JSONDecoder().decode(Article.self, from: jsonData)
        } catch {
            throw ArticleContentScraperServiceError.textToArticleFailed(
                error: error,
                message: "Failed to convert JSON data to `Content` type `Article`."
            )
        }
    }

    private func sendTelemetryDataOnConvertWebsiteTextContentToArticleFail(
        error: any Error,
        payload: AutomaWebCoreAPIEndpointPayload
    ) {
        BackendMetric.scrapeArticleContentCall(status: .fail, payload: payload).increment()
        logScrapeArticleFail(payload: payload, error: error)
    }

    private func logScrapeArticleFail(payload: AutomaWebCoreAPIEndpointPayload, error: any Error) {
        logger.error(
            "Scrape article content failed.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "webcore_api_payload": .string(String(describing: payload)),
                "error": .string(String(reflecting: error))
            ]
        )
    }

    private func sendTelemetryDataOnScrapeArticleSuccess(payload: AutomaWebCoreAPIEndpointPayload, article: Article) {
        BackendMetric.scrapeArticleContentCall(status: .success, payload: payload).increment()
        logScrapeArticleSuccess(payload: payload, article: article)
    }

    private func logScrapeArticleSuccess(payload: AutomaWebCoreAPIEndpointPayload, article: Article) {
        logger.info(
            "Scrape article content success.",
            metadata: [
                "to": .string("\(String(describing: Self.self)).\(#function)"),
                "webcore_api_payload": .string(String(describing: payload)),
                "article_title": .string(article.title),
                "article_content_markdown_length": .string("\(article.contentMarkdown.count)"),
            ]
        )
    }

    public struct Article: Content {
        public let title: String
        public let author: String
        public let postedAt: Date?
        public let contentMarkdown: String

        public init(from decoder: any Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            title = try values.decode(String.self, forKey: .title)
            author = try values.decode(String.self, forKey: .author)
            contentMarkdown = try values.decode(String.self, forKey: .contentMarkdown)
            postedAt = try? values.decode(Date.self, forKey: .postedAt)
        }

        private enum CodingKeys: String, CodingKey {
            case title
            case author
            case postedAt = "posted_at"
            case contentMarkdown = "content_markdown"
        }
    }
}
