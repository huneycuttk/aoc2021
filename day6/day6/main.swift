//
//  main.swift
//  day6
//
//  Created by Karsten Huneycutt on 2021-12-05.
//

import Foundation

let testData = """
3,4,3,1,2
""".split(separator: "\n")

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day6/input.txt")!
let data = try String(contentsOf: url).split(separator: "\n")

let testAges = parseAges(testData)
let ages = parseAges(data)

let testCountAnswer = 5934
let testCount = simulate(ages: testAges, days: 80)
print("TEST: Count \(testCount)")
assert(testCount == testCountAnswer)

let count = simulate(ages: ages, days: 80)
print("Count \(count)")
assert(count == 396210)

let testCount2Answer = 26984457539
let testCount2 = simulate(ages: testAges, days: 256)
print("TEST: Count2 \(testCount2)")
assert(testCount2 == testCount2Answer)

let count2 = simulate(ages: ages, days: 256)
print("Count2 \(count2)")
assert(count2 == 1770823541496)

func parseAges<S: StringProtocol>(_ data: [S]) -> [Int] {
    return data[0].components(separatedBy: ",").map { Int($0)! }
}

func simulate(ages: [Int], days: Int) -> Int {
    var ageCounts = ages.reduce(into: [Int](repeating:0, count: 9)) { $0[$1] += 1 }
    for _ in 1...days {
        let newFish = ageCounts.rotate()
        ageCounts[6] += newFish
    }
    return ageCounts.reduce(0, +)
}

extension Array {
    mutating func rotate() -> Element {
        let x = removeFirst()
        append(x)
        return x
    }
}
