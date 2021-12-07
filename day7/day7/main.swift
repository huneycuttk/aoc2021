//
//  main.swift
//  day7
//
//  Created by Karsten Huneycutt on 2021-12-06.
//

import Foundation

let testData = """
16,1,2,0,4,2,7,1,2,14
""".split(separator: "\n")

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day7/input.txt")!
let data = try String(contentsOf: url).components(separatedBy: "\n")

let testPositions = parsePositions(testData)
let positions = parsePositions(data)
print("positions \(testPositions)")

let (testPosition, testCost) = cheapestPositionAndCost(positions: testPositions, costFunction: simpleCost)
print("TEST: position \(testPosition) and cost \(testCost)")
assert(testPosition == 2 && testCost == 37)

let (position, cost) = cheapestPositionAndCost(positions: positions, costFunction: simpleCost)
print("Position \(position) and cost \(cost)")
assert(position == 346 && cost == 359648)

let (testPosition2, testCost2) = cheapestPositionAndCost(positions: testPositions, costFunction: increasingCost)
print("TEST: position \(testPosition2) and cost \(testCost2)")
assert(testPosition2 == 5 && testCost2 == 168)

let (position2, cost2) = cheapestPositionAndCost(positions: positions, costFunction: increasingCost)
print("Position \(position2) and cost \(cost2)")
assert(position2 == 497 && cost2 == 100727924)


func parsePositions<S: StringProtocol>(_ data: [S]) -> [Int] {
    return data.first!.components(separatedBy: ",").map { Int($0)! }
}

func costToAlign(positions: [Int], toPosition: Int, costFunction: (Int) -> Int) -> Int {
    return positions.map { abs(toPosition - $0) }.map(costFunction).reduce(0, +)
}

func cheapestPositionAndCost(positions: [Int], costFunction: (Int) -> Int) -> (Int, Int) {
    return [Int](0..<positions.max()!)
        .map { ($0, costToAlign(positions: positions, toPosition: $0, costFunction: costFunction)) }
        .sorted { $0.1 < $1.1 }
        .first!
}

func increasingCost(distance: Int) -> Int {
    return (distance*(distance+1))/2
}

func simpleCost(distance: Int) -> Int {
    return distance
}
