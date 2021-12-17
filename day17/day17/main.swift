//
//  main.swift
//  day17
//
//  Created by Karsten Huneycutt on 2021-12-17.
//

import Foundation

let (testXtarget, testYtarget) = try parseTargetArea(readFile("file:///Users/kph/Stuff/aoc2021/day17/test-input.txt"))
let (xTarget, yTarget) = try parseTargetArea(readFile("file:///Users/kph/Stuff/aoc2021/day17/input.txt"))

part1()
part2()

func part1() {
    let testHeight = findMaxHeight(xRange: testXtarget, yRange: testYtarget)
    print("TEST: Height is \(testHeight)")
    assert(testHeight == 45)
    
    let height = findMaxHeight(xRange: xTarget, yRange: yTarget)
    print("Height is \(height)")
    assert(height == 3003)
}
                                  
func part2() {
    let testCandidateCount = getAllVelocities(xRange: testXtarget, yRange: testYtarget).count
    print("TEST: Number of candidates is \(testCandidateCount)")
    assert(testCandidateCount == 112)
    
    let candidateCount = getAllVelocities(xRange: xTarget, yRange: yTarget).count
    print("Number of candidates is \(candidateCount)")
    
}

func parseTargetArea(_ data: [String]) -> (Range<Int>, Range<Int>) {
    let line = data.first!.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces)
    let ranges = line[2...3].map { line -> Range<Int> in
        let rangeComponents = line.components(separatedBy: "=")
            .last!
            .components(separatedBy: "..")
            .map { Int($0.replacingOccurrences(of: ",", with: ""))! }
        let lhs = rangeComponents.first!
        let rhs = rangeComponents.last!
        return lhs < rhs ? Range(lhs...rhs) : Range(rhs...lhs)
    }

    return (ranges.first!, ranges.last!)
}

typealias Point = (Int, Int)
typealias Velocity = (Int, Int)

func getAllVelocities(xRange: Range<Int>, yRange: Range<Int>) -> [Velocity] {
    return [Int](-xRange.upperBound...xRange.upperBound).flatMap { xVelocity in
        [Int](yRange.lowerBound...abs(yRange.lowerBound)).compactMap { yVelocity in
            attempt(velocity: (xVelocity, yVelocity), xRange: xRange, yRange: yRange) ?
            (xVelocity, yVelocity) :
            nil
        }
    }
}

func findMaxHeight(xRange: Range<Int>, yRange: Range<Int>) -> Int {
    let candidates = getAllVelocities(xRange: xRange, yRange: yRange)
    let maxY = candidates.sorted { $0.1 < $1.1 }.last!.1
    return (maxY*(maxY+1))/2
}

func attempt(velocity: Velocity, xRange: Range<Int>, yRange: Range<Int>) -> Bool {
    var currentPosition = (0,0)
    var currentVelocity = velocity
    var previousPosition = currentPosition
    
    // if we didn't overshoot (x > upper bound, y < lower bound) or didn't stall
    // outside the target x range (since when vx goes to 0 it doesn't change)
    while (currentPosition.0 < xRange.upperBound &&
           currentPosition.1 > yRange.lowerBound &&
           (currentVelocity.0 > 0 || xRange.contains(currentPosition.0)))
    {
        previousPosition = currentPosition
        (currentPosition, currentVelocity) = step(position: currentPosition, velocity: currentVelocity)
    }
    
    return (xRange.contains(currentPosition.0) && yRange.contains(currentPosition.1)) ||
        (xRange.contains(previousPosition.0) && yRange.contains(previousPosition.1))
}

func step(position: Point, velocity: Velocity) -> (Point, Velocity) {
    let newX = position.0+velocity.0
    let newY = position.1+velocity.1
    
    let newVy = velocity.1-1
    let newVx: Int
    if (velocity.0 == 0) {
        newVx = 0
    } else if (velocity.0 < 0) {
        newVx = velocity.0+1
    } else {
        newVx = velocity.0-1
    }
    
    return ( (newX, newY), (newVx, newVy) )
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}
