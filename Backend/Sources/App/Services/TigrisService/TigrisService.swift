// TigrisService.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import AutomaUtilities
import DataTypes
import Fluent
import SotoS3
import Vapor

/// Service for interacting with Tigris S3 storage.
internal struct TigrisService: ~Copyable {
    /// The S3 client for interacting with Tigris.
    public let client: S3
    /// Logger to log messages
    public let logger: Logger

    /// Initializes a new instance of `TigrisService`.
    /// - Throws: Throws an error if initialization fails.
    public init(logger: Logger) throws {
        let clientAuth = try AWSClient(
            credentialProvider: .static(
                accessKeyId: Environment.getOrThrow("TIGRIS_ACCESS_KEY_ID"),
                secretAccessKey: Environment.getOrThrow("TIGRIS_ACCESS_KEY_SECRET")
            )
        )

        client = try S3(
            client: clientAuth,
            region: .init(rawValue: "auto"),
            endpoint: Environment.getOrThrow("TIGRIS_BASE_URL")
        )

        self.logger = logger
    }

    /// Deinitializes the `TigrisService` and shuts down the client.
    deinit {
        do {
            try client.client.syncShutdown()
        } catch {}
    }

    /// Retrieves a string from Tigris.
    /// - Parameter _: The input string.
    /// - Returns: An empty string.
    /// - Throws: Throws an error if retrieval fails.
    public func get(_: String) throws -> String {
        ""
    }

    /// Retrieves a public URL from Tigris.
    /// - Parameter _: The input string.
    /// - Returns: An empty string.
    /// - Throws: Throws an error if retrieval fails.
    public func publicUrl(_: String) throws -> String {
        ""
    }

    /// Signs a URL for access.
    /// - Parameters:
    ///   - input: The input string.
    ///   - expiresIn: The expiration time for the signed URL.
    /// - Returns: A signed URL string.
    /// - Throws: Throws an error if signing fails.
    public func sign(input: String, expiresIn: TimeAmount) async throws -> String {
        let tigrisUrl = try getTigrisUrl(input)
        guard
            let urlObj = URL(string: tigrisUrl)
        else {
            logger.error(
                "Could not convert tigris URL string to URL. This should never happen.",
                metadata: [
                    "to": .string("\(String(describing: Self.self)).\(#function)"),
                    "tigris_url": .string(tigrisUrl),
                ]
            )
            throw Abort(.internalServerError)
        }

        let url = try await client
            .signURL(
                url: urlObj,
                httpMethod: .GET,
                expires: expiresIn
            )

        return url.absoluteString
    }

    /// Uploads content to Tigris.
    /// - Parameters:
    ///   - input: The input string.
    ///   - content: The content to upload.
    ///   - acl: The access control list for the object.
    ///   - metadata: Optional metadata for the object.
    ///   - expires: Optional expiration date for the object.
    ///   - contentType: Optional content type for the object.
    /// - Returns: An optional `S3.PutObjectOutput` object.
    /// - Throws: Throws an error if upload fails.
    public func put(
        input: String,
        content: ByteBuffer,
        acl: S3.ObjectCannedACL = .private,
        metadata: [String: String]? = nil,
        expires: Date? = nil,
        contentType: String? = nil
    ) async throws -> S3.PutObjectOutput? {
        do {
            let path = try decodeS3Path(input)

            let output = try await client
                .putObject(
                    acl: acl,
                    body: .init(buffer: content),
                    bucket: path.bucket,
                    contentType: contentType,
                    expires: expires?.formatted(),
                    key: path.key,
                    metadata: metadata
                )

            BackendMetric.totalMediaFilesUploadedToTigris.increment()
            return output
        } catch {
            BackendMetric.totalMediaFilesUploadedToTigrisFailed.increment()
            throw error
        }
    }

    /// Decodes an S3 path into a bucket and key.
    /// - Parameter s3Path: The S3 path to decode.
    /// - Returns: An `S3Path` object containing the bucket and key.
    /// - Throws: Throws an error if the path is too short.
    public func decodeS3Path(_ s3Path: String) throws -> Self.S3Path {
        var pathComponents = s3Path.pathComponents

        if pathComponents.count < 3 {
            throw GenericErrors.s3PathTooShort
        }

        let bucket = pathComponents[1].description
        pathComponents.removeFirst(2)

        let key = pathComponents.map(\.description).joined(separator: "/")

        return .init(bucket: bucket, key: key)
    }

    /// Retrieves the Tigris URL for an S3 path.
    /// - Parameter s3Path: The S3 path.
    /// - Returns: A string representing the Tigris URL.
    /// - Throws: Throws an error if the URL is invalid.
    public func getTigrisUrl(
        _ s3Path: String
    ) throws -> String {
        let path = try decodeS3Path(s3Path)

        let tigrisUrl = client.endpoint

        let environment = try Environment.getOrThrow("ENVIRONMENT")

        let url = URL(string: tigrisUrl)

        guard let url, let host = url.host() else {
            throw GenericErrors.invalidUrl
        }

        if environment == "local" {
            return url
                .appending(path: path.bucket)
                .appending(path: path.key).absoluteString
        } else {
            guard let returnableUrl = URL(
                string: "https://\(path.bucket).\(host)/\(path.key)"
            )?.absoluteString else {
                throw GenericErrors.invalidUrl
            }

            return returnableUrl
        }
    }

    /// Represents an S3 path with a bucket and key.
    public struct S3Path {
        /// The bucket name.
        public let bucket: String
        /// The key within the bucket.
        public let key: String
    }
}
