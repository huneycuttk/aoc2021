//
//  main.swift
//  day13
//
//  Created by Karsten Huneycutt on 2021-12-13.
//

import Foundation

let (testGrid, testInstructions) = try parsePaper(readFile("file:///Users/kph/Stuff/aoc2021/day13/test-input.txt"))
let (grid, instructions) = try parsePaper(readFile("file:///Users/kph/Stuff/aoc2021/day13/input.txt"))

part1()
part2()

typealias Grid = [[Bool]]
typealias Point = (Int, Int)
typealias Instruction = (Grid.Axis, Int)
enum FoldError : Error {
    case InvalidInstructionError
}

func parsePaper(_ data: [String]) throws -> (Grid, [Instruction]) {
    let instructionStart = data.firstIndex { $0.starts(with: "fold along") }!
    
    let grid = Grid(data[0..<instructionStart-1].map { $0.components(separatedBy: ",")
                                                        .map { Int($0)! }}
                                                .map { ($0[0], $0[1]) })
    
    let instructions = try data[instructionStart..<data.count].map {
            $0.components(separatedBy: .whitespaces)[2].components(separatedBy: "=")
    }.map { instruction -> Instruction in
        let along = Int(instruction[1])!
        switch(instruction[0]) {
        case "x":
            return (.x, along)
        case "y":
            return (.y, along)
        default:
            throw FoldError.InvalidInstructionError
        }
    }
    
    return (grid, instructions)
}

extension Grid {
    enum Axis { case x, y }
    
    init(_ points: [Point]) {
        let xCount = points.map { $0.0 }.max()! + 1
        let yCount = points.map { $0.1 }.max()! + 1
        
        self.init(repeating: [Bool](repeating: false, count: yCount), count: xCount)
        points.forEach { self[$0.0][$0.1] = true }
    }
    
    func fold(_ instruction: Instruction) -> Grid {
        switch (instruction.0) {
        case .x:
            return foldVertical(along: instruction.1)
        case .y:
            return foldHorizontal(along: instruction.1)
        }
    }
    
    private func foldHorizontal(along: Int) -> Grid {
        var copy = self.map { x -> [Bool] in
            var c = x
            c.removeSubrange(along..<x.count)
            return c
        }

        for offset in 1..<self[0].count-along {
            [Int](0..<self.count).forEach { x in
                copy[x][along-offset] = self[x][along-offset] || self[x][along+offset]
            }
        }
        
        return copy
    }
    
    private func foldVertical(along: Int) -> Grid {
        var copy = self
        copy.removeSubrange(along..<copy.count)
        
        for offset in 1..<self.count-along {
            [Int](0..<self[0].count).forEach { y in
                copy[along-offset][y] = self[along-offset][y] || self[along+offset][y]
            }
        }
        
        return copy
    }
    
    var dotCount: Int {
        get {
            reduce(0) { $0 + $1.reduce(0) { $1 ? $0 + 1 : $0 } }
        }
    }
    
    func toString() -> String {
        return [Int](0..<self[0].count).map { y in
            [Int](0..<count).map { x in
                self[x][y] ? "#" : "."
            }.joined()
        }.joined(separator: "\n")
    }
}

func findNumberOfDotsAfterFold(grid: Grid, instruction: Instruction) -> Int {
    return grid.fold(instruction).dotCount
}

func foldAndPrint(grid: Grid, instructions: [Instruction]) -> String {
    return instructions.reduce(grid) { $0.fold($1) }.toString()
}

func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

func part1() {
    let testNumberOfDots = findNumberOfDotsAfterFold(grid: testGrid, instruction: testInstructions.first!)
    print("TEST: Number of dots after first fold \(testNumberOfDots)")
    assert(testNumberOfDots == 17)

    let numberOfDots = findNumberOfDotsAfterFold(grid: grid, instruction: instructions.first!)
    print("Number of dots after first fold \(numberOfDots)")
    assert(numberOfDots == 618)
}

func part2() {
    let testPatternAnswer = """
#####
#...#
#...#
#...#
#####
.....
.....
"""
    let testPattern = foldAndPrint(grid: testGrid, instructions: testInstructions)
    print("TEST PATTERN")
    print(testPattern)
    assert(testPattern == testPatternAnswer)
    
    let patternAnswer = """
.##..#....###..####.#..#.####.#..#.#..#.
#..#.#....#..#.#....#.#..#....#.#..#..#.
#..#.#....#..#.###..##...###..##...#..#.
####.#....###..#....#.#..#....#.#..#..#.
#..#.#....#.#..#....#.#..#....#.#..#..#.
#..#.####.#..#.####.#..#.#....#..#..##..
"""
    let pattern = foldAndPrint(grid: grid, instructions: instructions)
    print("PATTERN")
    print(pattern)
    assert(pattern == patternAnswer)
    
    //ALREKFKU
}
