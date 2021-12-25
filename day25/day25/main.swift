//
//  main.swift
//  day25
//
//  Created by Karsten Huneycutt on 2021-12-25.
//

import Foundation

let testGrid = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day25/test-input.txt"))
let grid = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day25/input.txt"))

part1()
part2()

enum Cucumber {
    case south
    case east
}

typealias CucumberGrid = [[Cucumber?]]
extension CucumberGrid {
    var rowCount: Int {
        self.count
    }
    var colCount: Int {
        self[0].count
    }
    
    subscript(x: Int, y: Int) -> Cucumber? {
        get {
            self[x][y]
        }
        set(newValue) {
            self[x][y] = newValue
        }
    }
    
    func step() -> (Int, CucumberGrid) {
        var copy = self
        var numMoves = 0
        
        for (rowIdx, row) in self.enumerated() {
            for (colIdx, cucumber) in row.enumerated() {
                if (cucumber == .east) {
                    let nextColIdx = (colIdx+1) % colCount
                    if self[rowIdx, nextColIdx] == nil {
                        copy[rowIdx, nextColIdx] = .east
                        copy[rowIdx, colIdx] = nil
                        numMoves += 1
                    }
                }
            }
        }
        
        var copy2 = copy
        for (rowIdx, row) in copy.enumerated() {
            for (colIdx, cucumber) in row.enumerated() {
                if (cucumber == .south) {
                    let nextRowIdx = (rowIdx+1) % rowCount
                    if copy[nextRowIdx, colIdx] == nil {
                        copy2[nextRowIdx, colIdx] = .south
                        copy2[rowIdx, colIdx] = nil
                        numMoves += 1
                    }
                }
            }
        }
        
        return (numMoves, copy2)
    }
    
}

func stepsUntilStasis(cucumbers: CucumberGrid) -> Int {
    var steps = 0
    var grid = cucumbers
    var count: Int
    repeat {
        (count, grid) = grid.step()
        steps += 1
    } while (count > 0)
    
    return steps
}

func part1() {
    let testSteps = stepsUntilStasis(cucumbers: testGrid)
    print("Test steps \(testSteps)")
    assert(testSteps == 58)
    
    let steps = stepsUntilStasis(cucumbers: grid)
    print("Steps \(steps)")
}

func part2() {
    
}

func parse(_ data: [String]) -> CucumberGrid {
    return data.map { line in
        line.map { char -> Cucumber? in
            if (char == "v") {
                return .south
            } else if (char == ">") {
                return .east
            } else {
                return nil
            }
        }
    }
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

