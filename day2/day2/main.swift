//
//  main.swift
//  day2
//
//  Created by Karsten Huneycutt on 2021-12-02.
//

import Foundation

let testInstructions = [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2"
]

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day2/input.txt")!
let instructions = try String(contentsOf: url).split(separator: "\n")

let parsedTestInstructions = parseInstructions(testInstructions)
let parsedInstructions = parseInstructions(instructions)

func parseInstructions<S: StringProtocol>(_ instructions: [S]) -> [(String, Int)] {
    return instructions
        .map { $0.split(separator: " ").map { String($0) } }
        .map { ($0[0], Int($0[1])!) }
}

let testAnswerOneHorizontal = 15
let testAnswerOneDepth = 10
let testAnswerOne = 150
let (test1H, test1D) = processInstructionsPartOne(parsedTestInstructions)
assert(test1H == testAnswerOneHorizontal && test1D == testAnswerOneDepth)
assert(test1H * test1D == testAnswerOne)

let (part1H, part1D) = processInstructionsPartOne(parsedInstructions)
let answer1 = part1H * part1D

print("Horizontal \(part1H) Depth \(part1D) Product \(answer1)")
assert(answer1 == 1383564)

func processInstructionsPartOne(_ instructions: [(String, Int)]) -> (Int, Int) {
    return instructions.reduce((0,0)) { (result, instruction) in
        switch(instruction.0) {
        case "forward":
            return (result.0 + instruction.1, result.1)
        case "up":
            return (result.0, result.1 - instruction.1)
        case "down":
            return (result.0, result.1 + instruction.1)
        default:
            print("UNKNOWN DIRECTION")
            return result
        }
    }
}

let testAnswerTwoHorizontal = 15
let testAnswerTwoDepth = 60
let testAnswerTwo = 900

let (test2H, test2D, test2A) = processInstructionsPartTwo(parsedTestInstructions)
assert(test2H == testAnswerTwoHorizontal && test2D == testAnswerTwoDepth)
assert(test2H * test2D == 900)

let (part2H, part2D, part2A) = processInstructionsPartTwo(parsedInstructions)
let answer2 = part2H * part2D

print("Horizontal \(part2H) Depth \(part2D) Aim \(part2A) Product \(answer2)")
assert(answer2 == 1488311643)

func processInstructionsPartTwo(_ instructions: [(String, Int)]) -> (Int, Int, Int) {
    return instructions.reduce((0,0,0)) { (result, instruction) in
        switch(instruction.0) {
        case "forward":
            return (result.0 + instruction.1, result.1 + (result.2*instruction.1), result.2)
        case "up":
            return (result.0, result.1, result.2 - instruction.1)
        case "down":
            return (result.0, result.1, result.2 + instruction.1)
        default:
            print("UNKNOWN DIRECTION")
            return result
        }
    }
}

