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

func processInstructionsPartOne<S: StringProtocol>(_ instructions: [S]) -> (Int, Int) {
    var depth = 0
    var horizontal = 0
    
    instructions.map { $0.split(separator: " ") }.forEach { instruction in
        let amount = Int(instruction[1])!
        switch(instruction[0]) {
        case "forward":
            horizontal += amount
        case "up":
            depth -= amount
        case "down":
            depth += amount
        default:
            print("UNKNOWN DIRECTION")
        }
    }
    
    return (horizontal, depth)
}

let testAnswerTwoHorizontal = 15
let testAnswerTwoDepth = 60
let testAnswerTwo = 900

let (test2H, test2D) = processInstructionsPartTwo(testData)
guard test2H == testAnswerTwoHorizontal, test2D == testAnswerTwoDepth else {
    print("ANSWER INCORRECT")
    exit(1)
}

let (part2H, part2D) = processInstructionsPartTwo(instructions)
let answer2 = part2H * part2D

print("Horizontal \(part2H) Depth \(part2D) Product \(answer2)")


func processInstructionsPartTwo<S: StringProtocol>(_ instructions: [S]) -> (Int, Int) {
    var depth = 0
    var horizontal = 0
    var aim = 0
    
    instructions.map { $0.split(separator: " ") }.forEach { instruction in
        let amount = Int(instruction[1])!
        switch(instruction[0]) {
        case "forward":
            horizontal += amount
            depth += (aim*amount)
        case "up":
            aim -= amount
        case "down":
            aim += amount
        default:
            print("UNKNOWN DIRECTION")
        }
    }
    
    return (horizontal, depth)

}

