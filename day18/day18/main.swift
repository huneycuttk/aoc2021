//
//  main.swift
//  day18
//
//  Created by Karsten Huneycutt on 2021-12-18.
//

import Foundation
import Algorithms

let simpleTestNumbers = try parseNumbers(readFile("file:///Users/kph/Stuff/aoc2021/day18/simple-test-input.txt"))
let testNumbers = try parseNumbers(readFile("file:///Users/kph/Stuff/aoc2021/day18/test-input.txt"))
let numbers = try parseNumbers(readFile("file:///Users/kph/Stuff/aoc2021/day18/input.txt"))

try part1()
try part2()

enum SnailfishNumberError : Error {
    case ParseError
    case LeftoverError
    case BadFormatError
}

func addList(numbers: [SnailfishNumber]) throws -> SnailfishNumber {
    return try numbers[1..<numbers.count].reduce(numbers[0]) { try ($0 + $1).reduce() }
}

func maxSumOfPair(numbers: [SnailfishNumber]) throws -> Int {
    try numbers.permutations(ofCount: 2)
        .map { try ($0.first! + $0.last!).reduce().magnitude }
        .max()!
}

func part1() throws {
    let simpleTestFinal = try addList(numbers: simpleTestNumbers).magnitude
    print("TEST: Simple test final magnitude is \(simpleTestFinal)")
    assert(simpleTestFinal == 3488)
    
    let testFinal = try addList(numbers: testNumbers).magnitude
    print("TEST: final magnitude is \(testFinal)")
    assert(testFinal == 4140)
    
    let final = try addList(numbers: numbers).magnitude
    print("Final magnitude is \(final)")
    assert(final == 4457)
}

func part2() throws {
    let testMax = try maxSumOfPair(numbers: testNumbers)
    print("TEST: Max sum is \(testMax)")
    assert(testMax == 3993)
    
    let max = try maxSumOfPair(numbers: numbers)
    print("Max sum is \(max)")
    assert(max == 4784)
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}
