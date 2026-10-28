// FitHeader.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// Errors thrown while decoding a .FIT file.
public enum FitParseError: Error, Equatable {
    /// The file is shorter than a valid FIT header
    case fileTooShort
    /// The header size byte is not one of the known sizes (12 or 14)
    case invalidHeaderSize(UInt8)
    /// The `.FIT` magic marker is missing from the header
    case missingFitMarker
    /// The header CRC does not match the header bytes
    case headerCRCMismatch
    /// The file CRC does not match the file contents
    case fileCRCMismatch
    /// A data message referenced a local message type with no prior definition
    case missingDefinition(localType: UInt8)
    /// The record payload ended unexpectedly
    case truncatedRecord
    /// The architecture byte in a definition message is invalid
    case invalidArchitecture(UInt8)
}

/// The decoded FIT file header (12 or 14 bytes).
public struct FitHeader: Equatable, Sendable {
    /// Size of the header in bytes (12 or 14)
    public let headerSize: UInt8
    /// FIT protocol version
    public let protocolVersion: UInt8
    /// FIT profile version
    public let profileVersion: UInt16
    /// Number of bytes of data records (excludes header and trailing CRC)
    public let dataSize: UInt32
    /// Header CRC when present (14-byte headers); zero means "not computed"
    public let headerCRC: UInt16?

    /// Parses the header from the start of a FIT byte buffer.
    /// - Parameter data: The full FIT file contents
    /// - Returns: The decoded header
    /// - Throws: `FitParseError` when the header is malformed
    public static func parse(from data: [UInt8]) throws -> FitHeader {
        guard data.count >= 12 else {
            throw FitParseError.fileTooShort
        }

        let headerSize = data[0]
        guard headerSize == 12 || headerSize == 14 else {
            throw FitParseError.invalidHeaderSize(headerSize)
        }
        guard data.count >= Int(headerSize) else {
            throw FitParseError.fileTooShort
        }

        // ".FIT" marker at bytes 8..<12
        guard data[8] == 0x2E, data[9] == 0x46, data[10] == 0x49, data[11] == 0x54 else {
            throw FitParseError.missingFitMarker
        }

        let protocolVersion = data[1]
        let profileVersion = UInt16(data[2]) | (UInt16(data[3]) << 8)
        let dataSize = UInt32(data[4])
            | (UInt32(data[5]) << 8)
            | (UInt32(data[6]) << 16)
            | (UInt32(data[7]) << 24)

        var headerCRC: UInt16?
        if headerSize == 14 {
            let storedCRC = UInt16(data[12]) | (UInt16(data[13]) << 8)
            headerCRC = storedCRC
            // A zero CRC means the writer skipped the checksum — accept it.
            if storedCRC != 0 {
                let computed = FitCRC.compute(data[0 ..< 12])
                guard computed == storedCRC else {
                    throw FitParseError.headerCRCMismatch
                }
            }
        }

        return FitHeader(
            headerSize: headerSize,
            protocolVersion: protocolVersion,
            profileVersion: profileVersion,
            dataSize: dataSize,
            headerCRC: headerCRC
        )
    }
}
