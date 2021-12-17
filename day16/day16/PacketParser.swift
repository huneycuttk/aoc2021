//
//  PacketParser.swift
//  day16
//
//  Created by Karsten Huneycutt on 2021-12-16.
//

import Foundation
import Algorithms

struct PacketParser {
    static let VersionLength = 3
    static let TypeLength = 3

    static func parse(stream: BitStream) -> Packet {
        let version = stream.readInt(bitCount: VersionLength)
        let type = PacketType.parseType(stream.readInt(bitCount: TypeLength))
        switch(type) {
        case .literal:
            return parseLiteralPacket(version: version, stream: stream)
        case .operation(let operationType):
            return parseOperationPacket(version: version, type: operationType, stream: stream)
        }
    }
    
    static let LiteralChunkLength = 5
    static let LiteralContinuationFlag = 0x10
    static let LiteralValueMask = 0x0F
    static let LiteralValueShiftFactor = 4
    static let LiteralValueStopReadingFlag = 0
    
    static func parseLiteralPacket(version: Int, stream: BitStream) -> LiteralPacket {
        var keepReading = true
        var bytes: [UInt8] = []
        
        while (keepReading) {
            let next = stream.readInt(bitCount: LiteralChunkLength)
            keepReading = (next & LiteralContinuationFlag) != LiteralValueStopReadingFlag
            bytes.append(UInt8(next & LiteralValueMask))
        }
        
        let literal = bytes.reversed().indexed().map { Int($0.1) << ($0.0*LiteralValueShiftFactor) }.reduce(0, |)
        return LiteralPacket(version: version, literal: literal)
    }

    static let LengthTypeLength = 1
    static let PacketLengthType = 1
    static let BitLengthType = 0
    static let BitLengthTypeLength = 15
    static let PacketLengthTypeLength = 11
    
    static func parseOperationPacket(version: Int, type: Int, stream: BitStream) -> OperationPacket {
        let lengthType = stream.readInt(bitCount: LengthTypeLength)
        
        var packetCount = 0
        let target: Int
        
        if (lengthType == BitLengthType) {
            let length = stream.readInt(bitCount: BitLengthTypeLength)
            target = stream.position + length
        } else {
            target = stream.readInt(bitCount: PacketLengthTypeLength)
        }
        
        var keepReading = true
        var subPackets: [Packet] = []
        
        while (keepReading) {
            let nextPacket = PacketParser.parse(stream: stream)
            subPackets.append(nextPacket)
            packetCount += 1
            
            if (lengthType == BitLengthType) {
                keepReading = stream.position < target
            } else {
                keepReading = packetCount < target
            }
        }
        
        return OperationPacket(version: version, operationType: type, subPackets: subPackets)
    }

}
