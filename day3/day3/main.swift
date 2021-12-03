//
//  main.swift
//  day3
//
//  Created by Karsten Huneycutt on 2021-12-03.
//

import Foundation

extension Int {
    func isBitSet(_ position: Int) -> Bool {
        return (self & (1<<position)) != 0
    }
}

let testData = [
    "00100",
    "11110",
    "10110",
    "10111",
    "10101",
    "01111",
    "00111",
    "11100",
    "10000",
    "11001",
    "00010",
    "01010"
]

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day3/input.txt")!
let data = try String(contentsOf: url).split(separator: "\n")

let (testBitCount, testParsedData) = parseData(testData)
let (bitCount, parsedData) = parseData(data)

let testGammaAnswer = 22
let testEpsilonAnswer = 9

let (testGamma, testEpsilon) = gammaAndEpsilon(diagnosticData: testParsedData, bitCount: testBitCount)
let testAnswer1 = testGamma * testEpsilon
print("TEST: Gamma \(testGamma), Epsilon \(testEpsilon), Answer \(testAnswer1)")
guard testGamma == testGammaAnswer, testEpsilon == testEpsilonAnswer else {
    print("INCORRECT ANSWER")
    exit(1)
}

let (gamma, epsilon) = gammaAndEpsilon(diagnosticData: parsedData, bitCount: bitCount)
let answer1 = gamma * epsilon
print("Gamma \(gamma), Epsilon \(epsilon), Answer \(answer1)")


let testO2GeneratorRatingAnswer = 23
let testCO2ScrubberRatingAnswer = 10
let testO2GeneratorRating = o2GeneratorRating(diagnosticData: testParsedData, bitCount: testBitCount)
let testCO2ScrubberRating = co2ScrubberRating(diagnosticData: testParsedData, bitCount: testBitCount)
let testAnswer2 = testO2GeneratorRating * testCO2ScrubberRating
print("TEST: O2 Generator \(testO2GeneratorRating), CO2 Scrubber \(testCO2ScrubberRating), Answer \(testAnswer2)")
guard testO2GeneratorRating == testO2GeneratorRatingAnswer, testCO2ScrubberRating == testCO2ScrubberRatingAnswer else {
    print("INCORRECT ANSWER")
    exit(1)
}

let o2GeneratorRatingAnswer = o2GeneratorRating(diagnosticData: parsedData, bitCount: bitCount)
let co2ScrubberRatingAnswer = co2ScrubberRating(diagnosticData: parsedData, bitCount: bitCount)
let answer2 = o2GeneratorRatingAnswer * co2ScrubberRatingAnswer
print("O2 Generator \(o2GeneratorRatingAnswer), CO2 Scrubber \(co2ScrubberRatingAnswer), Answer \(answer2)")

func parseData<S: StringProtocol>(_ data: [S]) -> (Int, [Int]) {
    let bitCount = data.map { $0.count }.max() ?? 0
    let ints = data.map { Int($0, radix: 2) ?? 0 }
    return (bitCount, ints)
}

func gammaAndEpsilon(diagnosticData: [Int], bitCount: Int) -> (Int, Int) {
    let half = diagnosticData.count/2
    let gamma = diagnosticData.reduce([Int](repeating: 0, count: bitCount)) { bits, datum in
        bits.enumerated().map { datum.isBitSet($0) ? $1 + 1 : $1 }
    }.enumerated().reduce(Int(0)) { $1.1 < half ? $0 : $0 | (1<<$1.0) }
    
    return (gamma, ~gamma & ((1<<bitCount)-1))
}

func filterDataBitwise(diagnosticData: [Int], bitCount: Int, filter: ((Int,Int), Bool) -> Bool) -> Int {
    [Int](0..<bitCount).reversed().reduce(diagnosticData) { filtered, currentBit in
        if filtered.count == 1 {
            return filtered
        } else {
            let currentBitCount = filtered.reduce((0,0)) { $1.isBitSet(currentBit) ? ($0.0, $0.1 + 1) : ($0.0 + 1, $0.1) }
            return filtered.filter { filter(currentBitCount, $0.isBitSet(currentBit)) }
        }
    }[0]
    
//    var filtered = diagnosticData
//    var currentBit = bitCount - 1
//    while filtered.count > 1 {
//        let currentBitCount = filtered.reduce((0,0)) { $1.isBitSet(currentBit) ? ($0.0, $0.1 + 1) : ($0.0 + 1, $0.1) }
//        filtered = filtered.filter { filter(currentBitCount, $0.isBitSet(currentBit)) }
//        currentBit = currentBit - 1
//    }
//    return filtered[0]
}

func o2GeneratorRating(diagnosticData: [Int], bitCount: Int) -> Int {
    return filterDataBitwise(diagnosticData: diagnosticData, bitCount: bitCount) { bitCount, bitSet in
        (bitCount.0 > bitCount.1) != bitSet
    }
}

func co2ScrubberRating(diagnosticData: [Int], bitCount: Int) -> Int {
    return filterDataBitwise(diagnosticData: diagnosticData, bitCount: bitCount) { bitCount, bitSet in
        (bitCount.0 > bitCount.1) == bitSet
    }
}
