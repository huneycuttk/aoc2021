//
//  Packet.swift
//  day16
//
//  Created by Karsten Huneycutt on 2021-12-16.
//

import Foundation

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
