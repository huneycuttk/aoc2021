//
//  BitStream.swift
//  day16
//
//  Created by Karsten Huneycutt on 2021-12-16.
//

import Foundation

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
