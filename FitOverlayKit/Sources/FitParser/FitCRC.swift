// FitCRC.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Foundation

/// Implements the CRC-16 algorithm used by the FIT protocol to checksum
/// the file header and the data records.
public enum FitCRC {
    private static let table: [UInt16] = [
        0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,
        0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400,
    ]

    /// Updates a running CRC with a single byte, as specified by the FIT SDK.
    /// - Parameters:
    ///   - crc: The current CRC value
    ///   - byte: The next byte of the stream
    /// - Returns: The updated CRC value
    public static func update(_ crc: UInt16, byte: UInt8) -> UInt16 {
        var crc = crc

        // Compute checksum of lower four bits of byte
        var tmp = table[Int(crc & 0xF)]
        crc = (crc >> 4) & 0x0FFF
        crc = crc ^ tmp ^ table[Int(byte & 0xF)]

        // Now compute checksum of upper four bits of byte
        tmp = table[Int(crc & 0xF)]
        crc = (crc >> 4) & 0x0FFF
        crc = crc ^ tmp ^ table[Int((byte >> 4) & 0xF)]

        return crc
    }

    /// Computes the CRC of an entire byte sequence.
    /// - Parameter bytes: The bytes to checksum
    /// - Returns: The CRC-16 value
    public static func compute<S: Sequence>(_ bytes: S) -> UInt16 where S.Element == UInt8 {
        bytes.reduce(UInt16(0)) { update($0, byte: $1) }
    }
}
