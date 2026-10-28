// FitParser.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// A minimal, dependency-free decoder for the binary FIT protocol.
///
/// Scope (deliberately small for the base template):
/// - Full header + CRC validation
/// - Definition messages (both endiannesses, developer fields skipped)
/// - `record` data messages (global message number 20) decoded into `FitRecord`
/// - All other message types are counted and skipped
///
/// TODO: Extend with laps/sessions/events and developer data fields as the product needs them.
public struct FitParser {
    /// Field definition inside a definition message.
    private struct FieldDefinition {
        let fieldNumber: UInt8
        let size: UInt8
        let baseType: UInt8
    }

    /// A stored definition message, keyed by local message type.
    private struct MessageDefinition {
        let globalMessageNumber: UInt16
        let isBigEndian: Bool
        let fields: [FieldDefinition]
        let developerFieldsSize: Int

        var totalFieldSize: Int {
            fields.reduce(0) { $0 + Int($1.size) } + developerFieldsSize
        }
    }

    /// The `record` global message number in the FIT profile.
    public static let recordGlobalMessageNumber: UInt16 = 20

    /// Whether to verify the trailing file CRC. Defaults to true.
    public var validatesFileCRC: Bool

    /// Initializes a parser.
    /// - Parameter validatesFileCRC: Whether the trailing file CRC is enforced.
    public init(validatesFileCRC: Bool = true) {
        self.validatesFileCRC = validatesFileCRC
    }

    /// Parses FIT file contents.
    /// - Parameter data: The complete file contents.
    /// - Returns: The parsed file with all decoded records.
    /// - Throws: `FitParseError` when the file is malformed.
    public func parse(data: Data) throws -> FitFile {
        try parse(bytes: [UInt8](data))
    }

    /// Parses FIT file contents from a byte array.
    /// - Parameter bytes: The complete file contents.
    /// - Returns: The parsed file with all decoded records.
    /// - Throws: `FitParseError` when the file is malformed.
    public func parse(bytes: [UInt8]) throws -> FitFile {
        let header = try FitHeader.parse(from: bytes)

        let dataStart = Int(header.headerSize)
        let dataEnd = dataStart + Int(header.dataSize)
        guard bytes.count >= dataEnd else {
            throw FitParseError.fileTooShort
        }

        try validateFileCRCIfNeeded(bytes: bytes, dataEnd: dataEnd)

        var offset = dataStart
        var definitions: [UInt8: MessageDefinition] = [:]
        var records: [FitRecord] = []
        var skipped = 0

        while offset < dataEnd {
            let recordHeader = bytes[offset]
            offset += 1

            if isCompressedTimestampHeader(recordHeader) {
                // Compressed timestamp data message: local type in bits 5-6.
                let localType = (recordHeader >> 5) & 0x3
                let parsedOffset = try handleDataMessage(
                    bytes: bytes,
                    offset: offset,
                    dataEnd: dataEnd,
                    definition: definitions[localType],
                    localType: localType,
                    records: &records,
                    skipped: &skipped
                )
                offset = parsedOffset
            } else if isDefinitionHeader(recordHeader) {
                let hasDeveloperData = (recordHeader & 0x20) != 0
                let localType = recordHeader & 0x0F
                let (definition, newOffset) = try parseDefinitionMessage(
                    bytes: bytes,
                    offset: offset,
                    dataEnd: dataEnd,
                    hasDeveloperData: hasDeveloperData
                )
                definitions[localType] = definition
                offset = newOffset
            } else {
                // Normal data message: local type in bits 0-3.
                let localType = recordHeader & 0x0F
                let parsedOffset = try handleDataMessage(
                    bytes: bytes,
                    offset: offset,
                    dataEnd: dataEnd,
                    definition: definitions[localType],
                    localType: localType,
                    records: &records,
                    skipped: &skipped
                )
                offset = parsedOffset
            }
        }

        return FitFile(header: header, records: records, skippedMessageCount: skipped)
    }

    // MARK: - Private helpers

    private func validateFileCRCIfNeeded(bytes: [UInt8], dataEnd: Int) throws {
        guard validatesFileCRC, bytes.count >= dataEnd + 2 else {
            return
        }
        let stored = UInt16(bytes[dataEnd]) | (UInt16(bytes[dataEnd + 1]) << 8)
        // A zero CRC means the writer skipped the checksum — accept it.
        guard stored != 0 else { return }
        let computed = FitCRC.compute(bytes[0 ..< dataEnd])
        guard computed == stored else {
            throw FitParseError.fileCRCMismatch
        }
    }

    private func isDefinitionHeader(_ header: UInt8) -> Bool {
        (header & 0x80) == 0 && (header & 0x40) != 0
    }

    private func isCompressedTimestampHeader(_ header: UInt8) -> Bool {
        (header & 0x80) != 0
    }

    private func parseDefinitionMessage(
        bytes: [UInt8],
        offset: Int,
        dataEnd: Int,
        hasDeveloperData: Bool
    ) throws -> (MessageDefinition, Int) {
        var offset = offset
        guard offset + 5 <= dataEnd else {
            throw FitParseError.truncatedRecord
        }

        // byte 0: reserved, byte 1: architecture
        let architecture = bytes[offset + 1]
        guard architecture <= 1 else {
            throw FitParseError.invalidArchitecture(architecture)
        }
        let isBigEndian = architecture == 1

        let globalMessageNumber: UInt16 = isBigEndian
            ? (UInt16(bytes[offset + 2]) << 8) | UInt16(bytes[offset + 3])
            : UInt16(bytes[offset + 2]) | (UInt16(bytes[offset + 3]) << 8)

        let fieldCount = Int(bytes[offset + 4])
        offset += 5

        guard offset + fieldCount * 3 <= dataEnd else {
            throw FitParseError.truncatedRecord
        }

        var fields: [FieldDefinition] = []
        fields.reserveCapacity(fieldCount)
        for index in 0 ..< fieldCount {
            let base = offset + index * 3
            fields.append(
                FieldDefinition(
                    fieldNumber: bytes[base],
                    size: bytes[base + 1],
                    baseType: bytes[base + 2]
                )
            )
        }
        offset += fieldCount * 3

        var developerFieldsSize = 0
        if hasDeveloperData {
            guard offset < dataEnd else {
                throw FitParseError.truncatedRecord
            }
            let developerFieldCount = Int(bytes[offset])
            offset += 1
            guard offset + developerFieldCount * 3 <= dataEnd else {
                throw FitParseError.truncatedRecord
            }
            for index in 0 ..< developerFieldCount {
                developerFieldsSize += Int(bytes[offset + index * 3 + 1])
            }
            offset += developerFieldCount * 3
        }

        let definition = MessageDefinition(
            globalMessageNumber: globalMessageNumber,
            isBigEndian: isBigEndian,
            fields: fields,
            developerFieldsSize: developerFieldsSize
        )
        return (definition, offset)
    }

    private func handleDataMessage(
        bytes: [UInt8],
        offset: Int,
        dataEnd: Int,
        definition: MessageDefinition?,
        localType: UInt8,
        records: inout [FitRecord],
        skipped: inout Int
    ) throws -> Int {
        guard let definition else {
            throw FitParseError.missingDefinition(localType: localType)
        }
        guard offset + definition.totalFieldSize <= dataEnd else {
            throw FitParseError.truncatedRecord
        }

        if definition.globalMessageNumber == Self.recordGlobalMessageNumber {
            let record = decodeRecord(bytes: bytes, offset: offset, definition: definition)
            records.append(record)
        } else {
            skipped += 1
        }

        return offset + definition.totalFieldSize
    }

    // swiftlint:disable cyclomatic_complexity
    private func decodeRecord(bytes: [UInt8], offset: Int, definition: MessageDefinition) -> FitRecord {
        var record = FitRecord()
        var cursor = offset

        for field in definition.fields {
            let size = Int(field.size)
            let slice = Array(bytes[cursor ..< cursor + size])
            cursor += size

            switch field.fieldNumber {
            case 253: // timestamp (uint32, seconds since FIT epoch)
                if let raw: UInt32 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0xFFFF_FFFF {
                    record.timestamp = FitRecord.date(fromFitTimestamp: raw)
                }
            case 0: // position_lat (sint32, semicircles)
                if let raw: UInt32 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0x7FFF_FFFF {
                    record.latitude = FitRecord.degrees(fromSemicircles: Int32(bitPattern: raw))
                }
            case 1: // position_long (sint32, semicircles)
                if let raw: UInt32 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0x7FFF_FFFF {
                    record.longitude = FitRecord.degrees(fromSemicircles: Int32(bitPattern: raw))
                }
            case 2: // altitude (uint16, scale 5, offset 500)
                if let raw: UInt16 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0xFFFF {
                    record.altitude = Double(raw) / 5.0 - 500.0
                }
            case 3: // heart_rate (uint8, bpm)
                if let raw = slice.first, raw != 0xFF {
                    record.heartRate = Int(raw)
                }
            case 4: // cadence (uint8, rpm)
                if let raw = slice.first, raw != 0xFF {
                    record.cadence = Int(raw)
                }
            case 5: // distance (uint32, scale 100, meters)
                if let raw: UInt32 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0xFFFF_FFFF {
                    record.distance = Double(raw) / 100.0
                }
            case 6: // speed (uint16, scale 1000, m/s)
                if let raw: UInt16 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0xFFFF {
                    record.speed = Double(raw) / 1000.0
                }
            case 7: // power (uint16, watts)
                if let raw: UInt16 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0xFFFF {
                    record.power = Int(raw)
                }
            case 9: // grade (sint16, scale 100, percent)
                if let raw: UInt16 = readUnsigned(slice, bigEndian: definition.isBigEndian), raw != 0x7FFF {
                    record.grade = Double(Int16(bitPattern: raw)) / 100.0
                }
            case 13: // temperature (sint8, °C)
                if let raw = slice.first, raw != 0x7F {
                    record.temperature = Int(Int8(bitPattern: raw))
                }
            default:
                // Unknown record field — ignored in the base template.
                continue
            }
        }

        return record
    }

    // swiftlint:enable cyclomatic_complexity

    private func readUnsigned<T: FixedWidthInteger & UnsignedInteger>(
        _ bytes: [UInt8],
        bigEndian: Bool
    ) -> T? {
        let byteCount = MemoryLayout<T>.size
        guard bytes.count >= byteCount else {
            return nil
        }
        var value: T = 0
        if bigEndian {
            for byte in bytes[0 ..< byteCount] {
                value = (value << 8) | T(byte)
            }
        } else {
            for byte in bytes[0 ..< byteCount].reversed() {
                value = (value << 8) | T(byte)
            }
        }
        return value
    }
}
