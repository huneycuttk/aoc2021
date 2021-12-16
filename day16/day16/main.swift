//
//  main.swift
//  day16
//
//  Created by Karsten Huneycutt on 2021-12-16.
//

import Foundation
import Algorithms

let packet = try parseInput(readFile("file:///Users/kph/Stuff/aoc2021/day16/input.txt"))

part1()
part2()

enum PacketType {
    case literal
    case operation(Int)

    static func parseType(_ typeInt: Int) -> PacketType {
        if (typeInt == 4) {
            return .literal
        } else {
            return .operation(typeInt)
        }
    }
}

protocol Packet {
    var version: Int { get }
    var type: PacketType { get }
    
    func evaluate() -> Int
}


struct LiteralPacket : Packet {
    let version: Int
    var type: PacketType { get { .literal } }
    let literal: Int
        
    func evaluate() -> Int {
        return literal
    }
}

struct OperationPacket : Packet {
    enum OperationType: Int {
        case sum = 0
        case product = 1
        case minimum = 2
        case maximum = 3
        case greaterThan = 5
        case lessThan = 6
        case equal = 7
    }
    
    let version: Int
    let operationType: OperationType
    var type: PacketType { get { .operation(operationType.rawValue) } }
    let subPackets: [Packet]

    init(version: Int, operationType: Int, subPackets: [Packet]) {
        self.version = version
        self.subPackets = subPackets
        self.operationType = OperationType.init(rawValue: operationType)!
    }
    
    func evaluate() -> Int {
        let subPacketValues = subPackets.map { $0.evaluate() }
        switch (operationType) {
        case .sum:
            return subPacketValues.reduce(0, +)
        case .product:
            return subPacketValues.reduce(1, *)
        case .minimum:
            return subPacketValues.min()!
        case .maximum:
            return subPacketValues.max()!
        case .greaterThan:
            return (subPacketValues.first! > subPacketValues.last!) ? 1 : 0
        case .lessThan:
            return (subPacketValues.first! < subPacketValues.last!) ? 1 : 0
        case .equal:
            return (subPacketValues.first! == subPacketValues.last!) ? 1 : 0
        }
    }
}

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
    
    static func parseLiteralPacket(version: Int, stream: BitStream) -> LiteralPacket {
        var keepReading = true
        var bytes: [UInt8] = []
        
        while (keepReading) {
            let next = stream.readInt(bitCount: LiteralChunkLength)
            keepReading = (next & LiteralContinuationFlag) != 0
            bytes.append(UInt8(next & LiteralValueMask))
        }
        
        let literal = bytes.reversed().indexed().map { Int($0.1) << ($0.0*4) }.reduce(0) { $0 | $1 }
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

class BitStream {
    let bytes: [Character]
    var position = 0
    
    // UGH.  there's no way to add a 0 padding to the String(x, radix: 2)
    // so UInt8(2) gets turned into "10" rather than "0010" as I need
    // so do this hacky gross thing
    static let CharacterMap: [Character:[Character]] = [
        "0": [ "0", "0", "0", "0" ],
        "1": [ "0", "0", "0", "1" ],
        "2": [ "0", "0", "1", "0" ],
        "3": [ "0", "0", "1", "1" ],
        "4": [ "0", "1", "0", "0" ],
        "5": [ "0", "1", "0", "1" ],
        "6": [ "0", "1", "1", "0" ],
        "7": [ "0", "1", "1", "1" ],
        "8": [ "1", "0", "0", "0" ],
        "9": [ "1", "0", "0", "1" ],
        "A": [ "1", "0", "1", "0" ],
        "B": [ "1", "0", "1", "1" ],
        "C": [ "1", "1", "0", "0" ],
        "D": [ "1", "1", "0", "1" ],
        "E": [ "1", "1", "1", "0" ],
        "F": [ "1", "1", "1", "1" ],
    ]
    
    init(byteString: String) {
        self.bytes = byteString.flatMap { BitStream.CharacterMap[$0]! }
    }
    
    func readInt(bitCount: Int) -> Int {
        let readBytes = Array(bytes[position..<(position+bitCount)])
        let result = Int(String(readBytes), radix: 2)!
        position += bitCount
        return result
    }
}

func parseInput(_ data: [String]) -> Packet {
    let bytes = data.first!.trimmingCharacters(in: .whitespacesAndNewlines)
    return PacketParser.parse(stream: BitStream(byteString: bytes))
}

func sumPacketVersions(packet: Packet) -> Int {
    switch(packet.type) {
    case .literal:
        return packet.version
    case .operation:
        return packet.version +
            (packet as! OperationPacket).subPackets.map { sumPacketVersions(packet: $0) }.reduce(0, +)
    }
}

func part1() {
    let sum = sumPacketVersions(packet: packet)
    print("Sum of versions is \(sum)")
    assert(sum == 957)
}

func test(_ string: String) -> Int {
    return PacketParser.parse(stream: BitStream(byteString: string)).evaluate()
}

func part2() {
    assert(test("C200B40A82") == 3)
    assert(test("04005AC33890") == 54)
    assert(test("880086C3E88112") == 7)
    assert(test("CE00C43D881120") == 9)
    assert(test("D8005AC2A8F0") == 1)
    assert(test("F600BC2D8F") == 0)
    assert(test("9C005AC2F8F0") == 0)
    assert(test("9C0141080250320F1802104A08") == 1)
    
    let evaluate = packet.evaluate()
    print("Evaluate \(evaluate)")
    assert(evaluate == 744953223228)
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}
