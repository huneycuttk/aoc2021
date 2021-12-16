//
//  main.swift
//  day16
//
//  Created by Karsten Huneycutt on 2021-12-16.
//

import Foundation

let packet = try parseInput(readFile("file:///Users/kph/Stuff/aoc2021/day16/input.txt"))

part1()
part2()

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
