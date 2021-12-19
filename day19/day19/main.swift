//
//  main.swift
//  day19
//
//  Created by Karsten Huneycutt on 2021-12-19.
//

import Foundation
import Algorithms

let simpleTest = try parseBeacons(readFile("file:///Users/kph/Stuff/aoc2021/day19/simple-test-input.txt"))
let testBeacons = try parseBeacons(readFile("file:///Users/kph/Stuff/aoc2021/day19/test-input.txt"))
let beacons = try parseBeacons(readFile("file:///Users/kph/Stuff/aoc2021/day19/input.txt"))

let (testCombined, combined) = part1()
part2()

func parseBeacons(_ data: [String]) -> [ScannerOutput] {
    return data.split(separator: "").map { parseScannerOutput(Array($0)) }
}

func parseScannerOutput(_ data: [String]) -> ScannerOutput {
    let beacons = data[1..<data.count].map { $0.components(separatedBy: ",").map { Int($0)! } }
        .map { Point($0[0], $0[1], $0[2]) }
        .map { ScannedObject(.beacon, location: $0) }
        
    let scanner = ScannedObject(.scanner(Int(data.first!.components(separatedBy: .whitespaces)[2])!), location: Point(0,0,0))
    
    return Set(beacons + [ scanner ])
}

typealias ScannerOutput = Set<ScannedObject>
enum Axis {
    case x, y, z, negX, negY, negZ
}

struct Point : Hashable {
    let x, y, z: Int
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
        
    func moveOrigin(_ newOrigin: Point) -> Point {
        Point(x-newOrigin.x, y-newOrigin.y, z-newOrigin.z)
    }
    
    func rotate(_ rotation: Rotation) -> Point {
        var newX = 0
        var newY = 0
        var newZ = 0
        
        switch (rotation.x) {
        case .x:
            newX = x
        case .y:
            newY = x
        case .z:
            newZ = x
        case .negX:
            newX = -x
        case .negY:
            newY = -x
        case .negZ:
            newZ = -x
        }
        
        switch (rotation.y) {
        case .x:
            newX = y
        case .y:
            newY = y
        case .z:
            newZ = y
        case .negX:
            newX = -y
        case .negY:
            newY = -y
        case .negZ:
            newZ = -y
        }
        
        switch (rotation.z) {
        case .x:
            newX = z
        case .y:
            newY = z
        case .z:
            newZ = z
        case .negX:
            newX = -z
        case .negY:
            newY = -z
        case .negZ:
            newZ = -z
        }

        return Point(newX, newY, newZ)
    }
}

struct Rotation {
    let x, y, z: Axis
}

struct Transform {
    let origin: Point
    let rotate: Rotation
}

struct ScannedObject : Hashable {
    enum ObjectType : Hashable {
        case beacon
        case scanner(Int)
    }

    let type: ObjectType
    let location: Point
    
    init(_ type: ObjectType, x: Int, y: Int, z: Int) {
        self.type = type
        self.location = Point(x, y, z)
    }
    
    init(_ type: ObjectType, location: Point) {
        self.type = type
        self.location = location
    }
    
    func moveOrigin(_ newOrigin: Point) -> ScannedObject {
        ScannedObject(type, location: location.moveOrigin(newOrigin))
    }
    
    func rotate(_ rotation: Rotation) -> ScannedObject {
        ScannedObject(type, location: location.rotate(rotation))
    }
    
    func transform(_ transform: Transform) -> ScannedObject {
        ScannedObject(type,
                      location: location.moveOrigin(transform.origin).rotate(transform.rotate))
    }
    
    func manhattanDistance(from: ScannedObject) -> Int {
        abs(from.location.x - location.x) + abs(from.location.y - location.y) + abs(from.location.z - location.z)
    }
}

extension ScannerOutput {
    func transform(_ transform: Transform) -> ScannerOutput {
        ScannerOutput(map { $0.transform(transform) })
    }

    func combine(with: ScannerOutput, transforms: [Transform]) -> ScannerOutput {
        transforms.reduce(self) { $0.transform($1) }.union(with)
    }
    
    func beacons() -> ScannerOutput {
        filter { $0.type == .beacon }
    }
    
    func scanners() -> ScannerOutput {
        filter { $0.type != .beacon }
    }
    
    func distanceMap() -> [ScannedObject:[Int]] {
        reduce(into: [ScannedObject:[Int]]()) { hash, beacon in
            hash[beacon] = filter { $0 != beacon }.map { beacon.manhattanDistance(from: $0) }
        }
    }
}

func checkAxis(origin: ScannerOutput, target: ScannerOutput, getCoordinate: (ScannedObject)->Int) -> [(Int, Axis)] {
    var candidates: [(Int, Axis)] = []
    let targetC = target.map(getCoordinate).sorted()
    let originX = origin.map { $0.location.x }.sorted()
    let originY = origin.map { $0.location.y }.sorted()
    let originZ = origin.map { $0.location.z }.sorted()
    for coord in -2000...2000 {
        let moved = targetC.map { $0 - coord }.sorted()
        let rotated = moved.map { -$0 }.sorted()
        if (originX.commonElementCount(with: moved) >= 12) {
            candidates.append((coord, .x))
        }
        if (originX.commonElementCount(with: rotated) >= 12) {
            candidates.append((coord, .negX))
        }
        if (originY.commonElementCount(with: moved) >= 12) {
            candidates.append((coord, .y))
        }
        if (originY.commonElementCount(with: rotated) >= 12) {
            candidates.append((coord, .negY))
        }
        if (originZ.commonElementCount(with: moved) >= 12) {
            candidates.append((coord, .z))
        }
        if (originZ.commonElementCount(with: rotated) >= 12) {
            candidates.append((coord, .negZ))
        }
    }

    return candidates
}


func canTransform(origin: ScannerOutput, target: ScannerOutput, distanceMaps: [ScannerOutput:[ScannedObject:[Int]]]) -> Bool {
    let originDistances = distanceMaps[origin]!
    let targetDistances = distanceMaps[target]!
    
    let sharedBeacon = targetDistances.values.first { targetBeacon in
        originDistances.values.first { targetBeacon.commonElementCount(with: $0) >= 11 } != nil
    }
    return sharedBeacon != nil
}

func findTransform(origin: ScannerOutput, target: ScannerOutput, distanceMaps: [ScannerOutput:[ScannedObject:[Int]]]) -> Transform? {
    let originBeacons = origin.beacons()
    let targetBeacons = target.beacons()
    
    if (!canTransform(origin: origin, target: target, distanceMaps: distanceMaps)) {
        return nil
    }
    
    
    // try one direction first.
    let xCandidates = checkAxis(origin: originBeacons, target: targetBeacons) { $0.location.x }
    if (xCandidates.isEmpty) {
        return nil
    }
    
    let yCandidates = checkAxis(origin: originBeacons, target: targetBeacons) { $0.location.y }
    if (yCandidates.isEmpty) {
        return nil
    }

    let zCandidates = checkAxis(origin: originBeacons, target: targetBeacons) { $0.location.z }
    if (zCandidates.isEmpty) {
        return nil
    }

    for xc in xCandidates {
        for yc in yCandidates {
            for zc in zCandidates {
                let newOrigin = Point(xc.0, yc.0, zc.0)
                let rotate = Rotation(x: xc.1, y: yc.1, z: zc.1)
                
                let transform = Transform(origin: newOrigin, rotate: rotate)
                let transformed = target.transform(transform)
                
                if (origin.beacons().intersection(transformed.beacons()).count >= 12) {
                    return transform
                }
            }
        }
    }
    
    return nil
}

func searchForCombinations(origin: ScannerOutput, transformList: [Transform], toCombine: [ScannerOutput],
                           processed: Set<ScannerOutput>, combined: ScannerOutput,
                           combinations: [[ScannerOutput]:Transform]) -> (ScannerOutput, Set<ScannerOutput>)
{
    if (Set(toCombine) == processed) {
        return (combined, processed)
    }
    
    let foundCombinations = combinations.filter { $0.0.first! == origin }.filter { !processed.contains($0.0.last!) }
    if (foundCombinations.isEmpty) {
        return (combined, processed)
    }
    
    var newCombined = combined
    var newProcessed = processed
    
    // first do the combinations
    foundCombinations.forEach { (pair, transform) in
        let found = pair.last!
        newProcessed.insert(found)
        newCombined = found.combine(with: newCombined, transforms: [ transform ] + transformList)
    }
    
    foundCombinations.forEach { (pair, transform) in
        let found = pair.last!
        (newCombined, newProcessed) = searchForCombinations(origin: found, transformList: [ transform ] + transformList,
                                                            toCombine: toCombine, processed: newProcessed,
                                                            combined: newCombined, combinations: combinations)
    }
    
    return (newCombined, newProcessed)
    
}

func mapBeacons(origin: ScannerOutput, scannerOutput: [ScannerOutput]) -> ScannerOutput {
    let distanceMaps = scannerOutput.reduce(into: [ScannerOutput:[ScannedObject:[Int]]]()) { $0[$1] = $1.beacons().distanceMap() }
    let combinations = Array(scannerOutput.permutations(ofCount: 2)).parallelMap { pair -> ([ScannerOutput], Transform)? in
        let first = pair.first!
        let second = pair.last!
        if let transform = findTransform(origin: first, target: second, distanceMaps: distanceMaps) {
            //print("Found transform \(first.scanners()) -> \(second.scanners())")
            return ([first, second], transform)
        } else {
            return nil
        }
    }.compacted().reduce(into: [[ScannerOutput]:Transform]()) { $0[$1.0] = $1.1 }

    
    
    let remaining = scannerOutput.removing(origin)
    let (combined, processed) = searchForCombinations(origin: origin, transformList: [],
                                                      toCombine: remaining, processed: Set([origin]),
                                                      combined: origin, combinations: combinations)
    
    if (Set(scannerOutput) != processed) {
        print("ERROR NOT ALL MAPS COMBINED")
    }
    
    return combined
}

func largestDistanceBetweenScanners(combined: ScannerOutput) -> Int {
    combined.scanners().combinations(ofCount: 2).map { $0.first!.manhattanDistance(from: $0.last!) }.max()!
}

func part1() -> (ScannerOutput, ScannerOutput) {
    let testCombined = mapBeacons(origin: testBeacons.first!, scannerOutput: testBeacons)
    let testBeacons = testCombined.beacons().count
    print("TEST: Number of beacons is \(testBeacons)")
    assert(testBeacons == 79)
    
    let combined = mapBeacons(origin: beacons.first!, scannerOutput: beacons)
    let beacons = combined.beacons().count
    print("Number of beacons is \(beacons)")
    assert(beacons == 330)
    
    return (testCombined, combined)
}

func part2() {
    let testDistance = largestDistanceBetweenScanners(combined: testCombined)
    print("TEST: Largest distance is \(testDistance)")
    assert(testDistance == 3621)
    
    let distance = largestDistanceBetweenScanners(combined: combined)
    print("Largest distance is \(distance)")
    assert(distance == 9634)
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

extension Array where Element : Equatable {
    func removing(_ element: Element) -> Array<Element> {
        if let index = firstIndex(where: { $0 == element }) {
            var copy = self
            copy.remove(at: index)
            return copy
        } else {
            return self
        }
    }
}

extension Array where Element == Int {
    func commonElementCount(with: [Int]) -> Int {
        let sorted = sorted()
        let other = with.sorted()
        var otherIdx = 0
        var commonCount = 0
        
        for idx in 0..<count {
            while (otherIdx < other.count && sorted[idx] > other[otherIdx]) {
                otherIdx += 1
            }
            if (otherIdx >= other.count) {
                break
            }
            if (sorted[idx] == other[otherIdx]) {
                commonCount += 1
                otherIdx += 1
            }
        }
        
        return commonCount
    }
}

extension Collection {
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)

        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }

        return res.map({ $0! })
    }
}
