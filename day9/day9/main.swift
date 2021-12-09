//
//  main.swift
//  day9
//
//  Created by Karsten Huneycutt on 2021-12-09.
//

import Foundation

let testUrl = URL(string: "file:///Users/kph/Stuff/aoc2021/day9/test-input.txt")!
let testData = try String(contentsOf: testUrl).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")


let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day9/input.txt")!
let data = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

let testHeightMap = parseHeightMap(testData)
let testRisk = testHeightMap.findRiskFromLowPoints()
print("TEST: Risk \(testRisk)")
assert(testRisk == 15)

let heightMap = parseHeightMap(data)
let risk = heightMap.findRiskFromLowPoints()
print("Risk \(risk)")
assert(risk == 512)

let testLargestBasins = testHeightMap.threeLargestBasins()
print("TEST: Basins \(testLargestBasins)")
assert(testLargestBasins == 1134)

let largestBasins = heightMap.threeLargestBasins()
print("Basins \(largestBasins)")
assert(largestBasins == 1600104)

func parseHeightMap(_ data: [String]) -> HeightMap {
    return HeightMap(data.map { $0.map { Int(String($0))! } })
}

struct HeightMap {
    let values: [[Int]]
    let maxRow: Int
    let maxCol: Int
    
    let MAX = 9
    
    init(_ values: [[Int]]) {
        self.values = values
        self.maxRow = values.count-1
        self.maxCol = values.first!.count-1
    }
    
    func findRiskFromLowPoints() -> Int {
        return findLowPoints().map { values[$0.0][$0.1] + 1 }.reduce(0, +)
    }
    
    func threeLargestBasins() -> Int {
        return findLowPoints().map(findBasinSize(lowPoint:)).sorted().reversed()[0..<3].reduce(1, *)
    }
    
    func findBasinSize(lowPoint: (Int, Int)) -> Int {
        return findBasin(lowPoint).count
    }
        
    private func findLowPoints() -> [(Int, Int)] {
        [Int](0...maxRow).flatMap { row in [Int](0...maxCol).map { col in (row, col) } }.filter { isLowPoint($0) }
    }
    
    private func isLowPoint(_ point: (Int, Int)) -> Bool {
        return neighboringPoints(point).allSatisfy { values[point.0][point.1] < values[$0.0][$0.1] }
    }
        
    private func findBasin(_ point: (Int, Int)) -> [(Int, Int)] {
        var basin = [(Int, Int)]()
        neighboringPointsInBasin(point, basin: &basin)
        return basin
    }
    
    private func neighboringPointsInBasin(_ point: (Int, Int), basin: inout [(Int, Int)]) -> Void {
        // base cases are edge of basin (max value at location) or this point's already in the basin
        if (values[point.0][point.1] == MAX || basin.contains(where: { $0 == point })) {
            return
        }
        
        basin.append(point)
        
        neighboringPoints(point).forEach { neighboringPointsInBasin($0, basin: &basin) }
    }

    private func neighboringPoints(_ point: (Int, Int)) -> [(Int, Int)] {
        let (row, col) = point
        let points = [ (row, col+1), (row, col-1), (row+1, col), (row-1, col) ]
            .filter { $0.0 >= 0 && $0.0 <= maxRow && $0.1 >= 0 && $0.1 <= maxCol }
        return points
    }

}
