//
//  main.swift
//  day11
//
//  Created by Karsten Huneycutt on 2021-12-11.
//

import Foundation

let testUrl = URL(string: "file:///Users/kph/Stuff/aoc2021/day11/test-input.txt")!
let testData = try String(contentsOf: testUrl).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")


let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day11/input.txt")!
let data = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

var testGrid = parseOctopusGrid(testData)
let testFlashCount = findFlashCount(grid: testGrid, steps: 100)
print("TEST: Flash count \(testFlashCount)")
assert(testFlashCount == 1656)

var grid = parseOctopusGrid(data)
let flashCount = findFlashCount(grid: grid, steps: 100)
print("Flash count \(flashCount)")
assert(flashCount == 1721)

let testSynchronizeStep = findSynchronizedStep(grid: testGrid)+100
print("TEST: Synchronize step \(testSynchronizeStep)")
assert(testSynchronizeStep == 195)

let synchronizeStep = findSynchronizedStep(grid: grid)+100
print("Synchronize step \(synchronizeStep)")
assert(synchronizeStep == 298)

func parseOctopusGrid(_ data: [String]) -> OctopusGrid {
    return OctopusGrid(data.map { $0.map { Int(String($0))! } })
}

func findFlashCount(grid: OctopusGrid, steps: Int) -> Int {
    [Int](0..<steps).map { _ in return grid.step() }.reduce(0, +)
}

func findSynchronizedStep(grid: OctopusGrid) -> Int {
    var flashCount = 0
    var stepCount = 0
    
    repeat {
        stepCount += 1
        flashCount = grid.step()
    } while (flashCount != grid.octopusCount())
                
    return stepCount
}


class OctopusGrid {
    var octopuses: [[Int]]
    let maxRow, maxCol: Int
    let allPoints: [(Int, Int)]
    
    let FLASH_POINT = 9
    
    init(_ values: [[Int]]) {
        self.octopuses = values
        self.maxRow = octopuses.count-1
        self.maxCol = octopuses[0].count-1
        self.allPoints = [Int](0..<values.count).flatMap { row in [Int](0..<values[0].count).map { col in (row, col) } }
    }
    
    func octopusCount() -> Int {
        return (maxRow+1)*(maxCol+1)
    }
    
    func step() -> Int {
        octopuses = octopuses.map { $0.map { $0 + 1 } }
        
        let flashes = allPoints.filter(readyToFlash).reduce([]) { flash(point: $1, processed: $0) }
        flashes.forEach { octopuses[$0.0][$0.1] = 0 }
        
        return flashes.count
    }
    
    private func readyToFlash(_ point: (Int, Int)) -> Bool {
        return octopuses[point.0][point.1] > 9
    }
                    
    private func flash(point: (Int, Int), processed: [(Int, Int)]) -> [(Int, Int)] {
        if (processed.contains { $0 == point }) {
            return processed
        }
        
        let neighboringPoints = neighboringPoints(point)

        neighboringPoints.forEach { octopuses[$0.0][$0.1] += 1 }
        
        return neighboringPoints.filter(readyToFlash).reduce(processed + [ point ]) { flash(point: $1, processed: $0) }
    }
    
    private func neighboringPoints(_ point: (Int, Int)) -> [(Int, Int)] {
        let (row, col) = point
        return [ (row, col+1), (row, col-1), (row+1, col), (row-1, col),
                 (row+1, col+1), (row+1, col-1), (row-1, col+1), (row-1, col-1) ]
            .filter { $0.0 >= 0 && $0.0 <= maxRow && $0.1 >= 0 && $0.1 <= maxCol }
    }
    

}
