//
//  main.swift
//  day22
//
//  Created by Karsten Huneycutt on 2021-12-22.
//

import Foundation
import Algorithms

let simplest = """
on x=10..12,y=10..12,z=10..12
on x=11..13,y=11..13,z=11..13
off x=9..11,y=9..11,z=9..11
on x=10..10,y=10..10,z=10..10
""".components(separatedBy: .newlines)
let simplestInstructions = parse(simplest)
let testInstructions1 = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day22/simple-test-input.txt"))
let testInstructions2 = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day22/test-input.txt"))
let instructions = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day22/input.txt"))

let finalReactor = simplestInstructions.reduce(Reactor()) { reactor, instruction in
    let points = reactor.points
    points.forEach { print("\($0)") }
    print("\(points.count)")
    print ("Processing instruction \(instruction)")
        let (range, onoff) = instruction
        if (onoff) {
            return reactor.turnOn(range: range)
        } else {
            return reactor.turnOff(range: range)
        }
    }
let points = finalReactor.points
points.forEach { print("\($0)") }
print("\(points.count) \(finalReactor.count)")


part1()
part2()

typealias Instruction = (CuboidRange, Bool)

struct CuboidRange : Hashable {
    let x, y, z: Range<Int>
    
    static let EmptyRange = CuboidRange(x: 0..<0, y: 0..<0, z: 0..<0)

    var isEmpty: Bool {
        x.isEmpty || y.isEmpty || z.isEmpty
    }
    
    func clamped(to range: CuboidRange) -> CuboidRange {
        CuboidRange(x: x.clamped(to: range.x), y: y.clamped(to: range.y), z: z.clamped(to: range.z))
    }
    
    static func &(lhs: CuboidRange, rhs: CuboidRange) -> CuboidRange {
        if (!lhs.overlaps(rhs)) {
            return EmptyRange
        }
        
        return CuboidRange(x: lhs.x & rhs.x, y: lhs.y & rhs.y, z: lhs.z & rhs.z)
    }
    
    func overlaps(_ other: CuboidRange) -> Bool {
        x.overlaps(other.x) && y.overlaps(other.y) && z.overlaps(other.z)
    }
    
    static func -(lhs: CuboidRange, rhs: CuboidRange) -> [CuboidRange] {
        if (!lhs.overlaps(rhs)) {
            return [lhs]
        }
        
        // if there's an overlap, we have to break this into three different cube ranges
        
        // first get the intersection of each individual coordinate
        let ix = lhs.x & rhs.x
        let iy = lhs.y & rhs.y
        let iz = lhs.z & rhs.z
        
        // then get the difference
        let dx = lhs.x - rhs.x
        let dy = lhs.y - rhs.y
        let dz = lhs.z - rhs.z
        
        return [
            CuboidRange(x: ix, y: iy, z: dz),
            CuboidRange(x: ix, y: dy, z: iz),
            CuboidRange(x: ix, y: dy, z: dz),
            CuboidRange(x: dx, y: iy, z: iz),
            CuboidRange(x: dx, y: iy, z: dz),
            CuboidRange(x: dx, y: dy, z: iz),
            CuboidRange(x: dx, y: dy, z: dz)
        ].filter { !$0.isEmpty }
    }
    
    var count: Int {
        x.count * y.count * z.count
    }
}

struct Reactor {
    struct RangeRecord {
        let range: CuboidRange
        let intersections: [CuboidRange]
        
        init(range: CuboidRange, intersections: [CuboidRange]) {
            self.range = range
            self.intersections = intersections.filter { !$0.isEmpty }
        }
        
        func addToRemoveIntersection(with range: CuboidRange) -> RangeRecord {
            RangeRecord(range: self.range, intersections: intersections + [ range & self.range ])
        }
        
        func evaluate() -> [CuboidRange] {
            print("Processing range \(range) with \(intersections.count) intersections")
            return intersections.filter { !$0.isEmpty }
                .reduce([ range ]) { results, intersection in results.flatMap { $0 - intersection } }
        }
        
        var count: Int {
            return evaluate().map { $0.count }.reduce(0, +)
        }
    }
    let onRanges: [RangeRecord]
    
    init(onRanges: [RangeRecord] = []) {
        // store only non-empty ranges.
        self.onRanges = onRanges
    }
    
    func turnOn(range: CuboidRange) -> Reactor {
        if (range.isEmpty) {
            return self
        }
        let newRanges = onRanges.map { $0.addToRemoveIntersection(with: range) }
        return Reactor(onRanges: newRanges + [ RangeRecord(range: range, intersections: []) ])
    }
    
    func turnOff(range: CuboidRange) -> Reactor {
        if (range.isEmpty) {
            return self
        }
        return Reactor(onRanges: onRanges.map { $0.addToRemoveIntersection(with: range) })
    }
    
    var count: Int {
        onRanges.map { $0.count }.reduce(0, +)
    }
    
    var points: [(Int,Int,Int)] {
        onRanges.flatMap { $0.evaluate() }.flatMap { range -> [(Int,Int,Int)] in
            var res = [(Int,Int,Int)]()
            for x in range.x {
                for y in range.y {
                    for z in range.z {
                        res.append((x,y,z))
                    }
                }
            }
            return res
        }
    }
    
}

func parse(_ data: [String]) -> [Instruction] {
    return data.map { $0.components(separatedBy: .whitespaces) }.map { line in
        let onoff = line.first! == "on"
        let coordinates = line.last!.split(separator: ",")
            .map { $0.split(separator: "=").last! }
            .map { $0.components(separatedBy: "..").map { Int($0)! } }
            .map { Range($0.first!...$0.last!) }
        return (CuboidRange(x: coordinates[0], y: coordinates[1], z: coordinates[2]), onoff)
    }
}

func doAllInstructions(_ instructions: [Instruction]) -> Int {
    let finalReactor = instructions.reduce(Reactor()) { reactor, instruction in
        print ("Processing instruction \(instruction)")
            let (range, onoff) = instruction
            if (onoff) {
                return reactor.turnOn(range: range)
            } else {
                return reactor.turnOff(range: range)
            }
        }
    return finalReactor.count
}

struct Point : Hashable { let x,y,z: Int }
func doFiftyCubed(instructions: [Instruction]) -> Int {
    let fiftyCubed = CuboidRange(x: -50..<51, y: -50..<51, z: -50..<51)
    return doAllInstructions(instructions.map { ($0.0.clamped(to: fiftyCubed), $0.1) })
//
//    var points = Set<Point>()
//    for instruction in instructions {
//        let (range, onoff) = instruction
//        let clamped = range.clamped(to: fiftyCubed)
//        for x in clamped.x {
//            for y in clamped.y {
//                for z in clamped.z {
//                    let point = Point(x: x, y: y, z: z)
//                    if (onoff) {
//                        points.insert(point)
//                    } else {
//                        points.remove(point)
//                    }
//                }
//            }
//        }
//    }
//    return points.count
}

func part1() {
    let testOnCount = doFiftyCubed(instructions: testInstructions1)
    print("TEST:  On count is \(testOnCount)")
    assert(testOnCount == 590784)
    
    let onCount = doFiftyCubed(instructions: instructions)
    print("On count is \(onCount)")
    assert(onCount == 546724)
}

func part2() {
    let testOnCount = doAllInstructions(testInstructions2)
    print("TEST: On count is \(testOnCount)")
    assert(testOnCount == 2758514936282235)


    let onCount = doAllInstructions(instructions)
    print("On count is \(onCount)")
    //assert(onCount == )
}



// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

extension Range where Bound == Int {
    static func &(lhs: Range, rhs: Range) -> Range {
        if (!lhs.overlaps(rhs)) {
            return 0..<0
        }
        
        let lower, upper: Int
        // need the higher lower bound
        if (lhs.lowerBound < rhs.lowerBound) {
            lower = rhs.lowerBound
        } else {
            lower = lhs.lowerBound
        }
        
        // need the lower higher bound
        if (lhs.upperBound < rhs.upperBound) {
            upper = lhs.upperBound
        } else {
            upper = rhs.upperBound
        }
        
        return lower..<upper
    }
    
    static func -(lhs: Range, rhs: Range) -> Range {
        if (!lhs.overlaps(rhs)) {
            return lhs
        }
        
        // if lhs is contained entirely in rhs, the result is an empty set
        if (lhs.upperBound <= rhs.upperBound && lhs.lowerBound >= rhs.lowerBound) {
            return 0..<0
        }
        
        // if rhs is contained entirely in lhs, can't do this operation
        if (rhs.upperBound < lhs.upperBound && rhs.lowerBound > lhs.lowerBound) {
            return 0..<0 // should throw an error
        }
        
        let newLower, newUpper: Int
        if (lhs.upperBound <= rhs.upperBound && lhs.lowerBound < rhs.lowerBound) {
            newUpper = rhs.lowerBound
            newLower = lhs.lowerBound
        } else {
            newLower = rhs.upperBound-1 // since the rhs range doesn't contain this boundary, can include it in the difference
            newUpper = lhs.upperBound
        }
        return newLower..<newUpper
    }
    
}
