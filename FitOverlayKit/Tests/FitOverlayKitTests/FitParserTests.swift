// FitParserTests.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

@testable import FitParser
import Foundation
import Testing

/// Builds minimal synthetic FIT files in memory for parser tests.
internal enum FitFileBuilder {
    /// Encodes a little-endian unsigned integer into bytes.
    static func littleEndianBytes<T: FixedWidthInteger & UnsignedInteger>(_ value: T) -> [UInt8] {
        (0 ..< MemoryLayout<T>.size).map { UInt8(truncatingIfNeeded: value >> (8 * $0)) }
    }

    /// A definition message for `record` (global 20) with timestamp/speed/heart rate/power/altitude.
    static func recordDefinitionMessage(localType: UInt8 = 0) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.append(0x40 | localType) // definition header
        bytes.append(0x00) // reserved
        bytes.append(0x00) // architecture: little endian
        bytes.append(contentsOf: littleEndianBytes(UInt16(20))) // global message number
        bytes.append(5) // field count
        // field number, size, base type
        bytes.append(contentsOf: [253, 4, 0x86]) // timestamp uint32
        bytes.append(contentsOf: [6, 2, 0x84]) // speed uint16 (scale 1000)
        bytes.append(contentsOf: [3, 1, 0x02]) // heart_rate uint8
        bytes.append(contentsOf: [7, 2, 0x84]) // power uint16
        bytes.append(contentsOf: [2, 2, 0x84]) // altitude uint16 (scale 5, offset 500)
        return bytes
    }

    /// A data message matching `recordDefinitionMessage`.
    static func recordDataMessage(
        localType: UInt8 = 0,
        fitTimestamp: UInt32,
        speedMillimetersPerSecond: UInt16,
        heartRate: UInt8,
        power: UInt16,
        rawAltitude: UInt16
    ) -> [UInt8] {
        var bytes: [UInt8] = []
        bytes.append(localType) // data header
        bytes.append(contentsOf: littleEndianBytes(fitTimestamp))
        bytes.append(contentsOf: littleEndianBytes(speedMillimetersPerSecond))
        bytes.append(heartRate)
        bytes.append(contentsOf: littleEndianBytes(power))
        bytes.append(contentsOf: littleEndianBytes(rawAltitude))
        return bytes
    }

    /// Wraps data records in a valid 14-byte header + trailing CRC.
    static func build(dataRecords: [UInt8]) -> [UInt8] {
        var header: [UInt8] = []
        header.append(14) // header size
        header.append(0x20) // protocol version 2.0
        header.append(contentsOf: littleEndianBytes(UInt16(2_140))) // profile version
        header.append(contentsOf: littleEndianBytes(UInt32(dataRecords.count))) // data size
        header.append(contentsOf: Array(".FIT".utf8))
        let headerCRC = FitCRC.compute(header)
        header.append(contentsOf: littleEndianBytes(headerCRC))

        var file = header + dataRecords
        let fileCRC = FitCRC.compute(file)
        file.append(contentsOf: littleEndianBytes(fileCRC))
        return file
    }
}

@Suite("FitParserTests")
internal struct FitParserTests {
    /// A synthetic file with two record messages should decode both with converted units.
    @Test("Parses record messages with unit conversion")
    public func parsesRecords() throws {
        let data = FitFileBuilder.recordDefinitionMessage()
            + FitFileBuilder.recordDataMessage(
                fitTimestamp: 1_000_000_000,
                speedMillimetersPerSecond: 8_333, // 8.333 m/s ≈ 30 km/h
                heartRate: 150,
                power: 250,
                rawAltitude: 7_500 // (7500 / 5) - 500 = 1000 m
            )
            + FitFileBuilder.recordDataMessage(
                fitTimestamp: 1_000_000_001,
                speedMillimetersPerSecond: 9_000,
                heartRate: 155,
                power: 260,
                rawAltitude: 7_505
            )
        let file = try FitParser().parse(bytes: FitFileBuilder.build(dataRecords: data))

        #expect(file.records.count == 2)
        #expect(file.skippedMessageCount == 0)

        let first = try #require(file.records.first)
        #expect(first.heartRate == 150)
        #expect(first.power == 250)
        let speed = try #require(first.speed)
        #expect(abs(speed - 8.333) < 0.001)
        let altitude = try #require(first.altitude)
        #expect(abs(altitude - 1_000) < 0.001)
        let timestamp = try #require(first.timestamp)
        #expect(timestamp == FitRecord.date(fromFitTimestamp: 1_000_000_000))
    }

    /// Files not starting with the `.FIT` marker must be rejected.
    @Test("Rejects non-FIT files")
    public func rejectsNonFit() {
        var bogus = FitFileBuilder.build(dataRecords: FitFileBuilder.recordDefinitionMessage())
        bogus[8] = 0x41 // corrupt the ".FIT" marker

        #expect(throws: FitParseError.missingFitMarker) {
            _ = try FitParser(validatesFileCRC: false).parse(bytes: bogus)
        }
    }

    /// A corrupted body must fail the trailing CRC check.
    @Test("Detects file CRC mismatch")
    public func detectsCRCMismatch() {
        var file = FitFileBuilder.build(
            dataRecords: FitFileBuilder.recordDefinitionMessage()
                + FitFileBuilder.recordDataMessage(
                    fitTimestamp: 1, speedMillimetersPerSecond: 1_000, heartRate: 100, power: 100, rawAltitude: 2_500
                )
        )
        file[20] ^= 0xFF // flip bits inside the data section

        #expect(throws: FitParseError.fileCRCMismatch) {
            _ = try FitParser().parse(bytes: file)
        }
    }

    /// Data messages that reference an undefined local message type must throw.
    @Test("Missing definition throws")
    public func missingDefinition() {
        let data: [UInt8] = [0x02] // data message for local type 2 without definition
        let file = FitFileBuilder.build(dataRecords: data)

        #expect(throws: FitParseError.missingDefinition(localType: 2)) {
            _ = try FitParser().parse(bytes: file)
        }
    }

    /// Semicircle conversion should map the full range to degrees.
    @Test("Semicircle conversion")
    public func semicircles() {
        #expect(FitRecord.degrees(fromSemicircles: 0) == 0)
        #expect(abs(FitRecord.degrees(fromSemicircles: 1_073_741_824) - 90) < 0.000_001)
    }
}
