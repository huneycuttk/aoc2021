//
//  main.swift
//  day2
//
//  Created by Karsten Huneycutt on 2021-12-02.
//

import Foundation

let testData = [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2"
]

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day2/input.txt")!
let instructions = try String(contentsOf: url).split(separator: "\n")


let testAnswerOneHorizontal = 15
let testAnswerOneDepth = 10
let testAnswerOne = 150
let (test1H, test1D) = processInstructionsPartOne(testData)
guard test1H == testAnswerOneHorizontal, test1D == testAnswerOneDepth else {
    print("ANSWER INCORRECT")
    exit(1)
}

let (part1H, part1D) = processInstructionsPartOne(instructions)
let answer1 = part1H * part1D

print("Horizontal \(part1H) Depth \(part1D) Product \(answer1)")

func parseInstructions<S: StringProtocol>(_ instructions: [S]) -> [(String, Int)] {
    return instructions
        .map { $0.split(separator: " ").map { x in String(x) } }
        .map { ($0[0], Int($0[1])!) }
}

func processInstructionsPartOne<S: StringProtocol>(_ instructions: [S]) -> (Int, Int) {
    return parseInstructions(instructions).reduce((0,0)) { (result, instruction) in
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

let (test2H, test2D, test2A) = processInstructionsPartTwo(testData)
guard test2H == testAnswerTwoHorizontal, test2D == testAnswerTwoDepth else {
    print("ANSWER INCORRECT")
    exit(1)
}

let (part2H, part2D, part2A) = processInstructionsPartTwo(instructions)
let answer2 = part2H * part2D

print("Horizontal \(part2H) Depth \(part2D) Aim \(part2A) Product \(answer2)")


func processInstructionsPartTwo<S: StringProtocol>(_ instructions: [S]) -> (Int, Int, Int) {
    return parseInstructions(instructions).reduce((0,0,0)) { (result, instruction) in
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

