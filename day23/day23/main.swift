//
//  main.swift
//  day23
//
//  Created by Karsten Huneycutt on 2021-12-23.
//

import Foundation

part1()
part2()

struct Point : Hashable {
    let x, y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

struct Amphipod : Hashable {
    enum AmphipodType : Int {
        case amber = 1
        case bronze = 10
        case copper = 100
        case desert = 1000
    }
    
    let type: AmphipodType
    let location: Point
    let home: Bool
    
    init(type: AmphipodType, location: Point, home: Bool = false) {
        self.type = type
        self.location = location
        self.home = home
    }
}

struct AmphipodHouse : Hashable {
    static let hallwayPoints: Set = [ Point(0,0), Point(1,0), Point(2,0), Point(3,0),
                                      Point(4,0), Point(5,0), Point(6,0), Point(7,0),
                                      Point(8,0), Point(9,0), Point(10,0) ]
    static let pointsOutsideRoom: Set = [ Point(2,0), Point(4,0), Point(6,0), Point(8,0) ]
    static let validTargets = hallwayPoints.subtracting(pointsOutsideRoom)
    
    let amphipods: [Amphipod]
    let homePoints: [Amphipod.AmphipodType:[Point]]
    
    func validMoves() -> [(AmphipodHouse, Int)] {
        // any amphipod that is home doesn't move
        let toMove = amphipods.filter { !$0.home }
        
        return toMove.flatMap { amphipod -> [(AmphipodHouse, Int)] in
            if (AmphipodHouse.hallwayPoints.contains(amphipod.location)) {
                if (!homeOpen(for: amphipod.type)) {
                    return []
                }
                
                // if the amphipod is in the hallway, can move only to its home base
                // prefer the lowest one without something in it.
                let hps = homePoints[amphipod.type]!
                let target = hps.reversed().first { !isAmphipodLocated(at: $0) }!
                if let cost = pathCost(for: amphipod, to: target) {
                    return [ (move(amphipod: amphipod, to: target), cost) ]
                } else {
                    return []
                }
            } else {
                // must be in a home room.
                
                // special case:  if we're already home and home is available (that is,
                // there are no amphipods of a different type in that home), then
                // we have a 0 cost move to set this amphipod as "home".
                if (homeOpen(for: amphipod.type) && isHome(amphipod: amphipod)) {
                    return [ (move(amphipod: amphipod, to: amphipod.location), 0) ]
                }
                
                // can stop at the valid targets.
                return AmphipodHouse.validTargets.compactMap { target -> (AmphipodHouse, Int)? in
                    if let cost = pathCost(for: amphipod, to: target) {
                        return (move(amphipod: amphipod, to: target), cost)
                    } else {
                        return nil
                    }
                }
            }
        }
    }
    
    func solved() -> Bool {
        amphipods.allSatisfy { $0.home }
    }
        
    private func isAmphipodLocated(at point: Point) -> Bool {
        amphipodLocated(at: point) != nil
    }
    
    private func amphipodLocated(at point: Point) -> Amphipod? {
        amphipods.first { $0.location == point }
    }
    
    private func pathCost(for amphipod: Amphipod, to point: Point) -> Int? {
        let initial = amphipod.location
        if (initial == point) {
            return nil
        }
        
        let yRange = initial.y < point.y ? initial.y...point.y : point.y...initial.y
        let xRange = initial.x < point.x ? initial.x...point.x : point.x...initial.x
        
        // start by getting the transit through the hallway
        var intermediatePoints = xRange.map { Point($0,0) }
        
        // if need to get up to the hallway, add that
        if (initial.y != 0) {
            intermediatePoints += yRange.map { Point(initial.x,$0) }
        }
        
        // if need to get down to the final point, add that
        if (point.y != 0) {
            intermediatePoints += yRange.map { Point(point.x,$0) }
        }
        
        if let _ = intermediatePoints.first(where: { amphipod.location != $0 && isAmphipodLocated(at: $0) }) {
            return nil
        }
        
        let spaceCost = amphipod.type.rawValue
        let distance = xRange.count-1 + yRange.count-1
        let cost = spaceCost * distance
        return cost
    }
    
    private func homeOpen(for type: Amphipod.AmphipodType) -> Bool {
        homePoints[type]!.allSatisfy { point in
            if let amphipod = amphipodLocated(at: point) {
                return amphipod.type == type
            } else {
                return true
            }
        }
    }
    
    private func isHome(amphipod: Amphipod) -> Bool {
        homePoints[amphipod.type]!.contains(amphipod.location)
    }
    
    private func move(amphipod: Amphipod, to point: Point) -> AmphipodHouse {
        var amphipodsCopy = amphipods
        amphipodsCopy.remove(at: amphipodsCopy.firstIndex(of: amphipod)!)
        
        let home = homePoints[amphipod.type]!.contains(point)
        let newLocation = Amphipod(type: amphipod.type, location: point, home: home)
        amphipodsCopy.append(newLocation)

        return AmphipodHouse(amphipods: amphipodsCopy, homePoints: homePoints)
    }
}

func allPathCosts(_ house: AmphipodHouse, cache: inout [AmphipodHouse:[Int]]) -> [Int] {
    if let cached = cache[house] {
        return cached
    }
    
    if (house.solved()) {
        return [0]
    }
    
    let pathCosts = house.validMoves().flatMap { (move, cost) in allPathCosts(move, cache: &cache).map { $0 + cost } }
    cache[house] = pathCosts
    return pathCosts
}

func shortestPathCostRecursive(_ house: AmphipodHouse, cache: inout [AmphipodHouse:Int?]) -> Int? {
    if let cached = cache[house] {
        return cached
    }
    
    if (house.solved()) {
        return 0
    }

    let shortestPath = house.validMoves().compactMap { (move, cost) -> Int? in
        if let subcost = shortestPathCostRecursive(move, cache: &cache) {
            return subcost + cost
        } else {
            return nil
        }
    }.min()
    cache[house] = shortestPath
    return shortestPath
}

func shortestPathCost(_ house: AmphipodHouse) -> Int {
    var toProcess = [ (house, 0) ]
    var shortest = Int.max
    
    while (!toProcess.isEmpty) {
        let (current, currentCost) = toProcess.removeLast()
        if (currentCost > shortest) {
            continue
        }
        for (move, cost) in current.validMoves() {
            // if the cost of this path does not exceed the current shortest
            // we can continue down this path
            let newCost = cost+currentCost
            if (newCost < shortest) {
                if (move.solved()) {
                    print("Found new shortest \(newCost) previous \(shortest)")
                    shortest = newCost
                } else {
                    toProcess.append((move, newCost))
                }
            }
        }
    }

    return shortest
}

func part1House(_ amphipods: [Amphipod]) -> AmphipodHouse {
    let homePoints: [Amphipod.AmphipodType:[Point]] = [
        .amber: [ Point(2,1), Point(2,2) ],
        .bronze: [ Point(4,1), Point(4,2) ],
        .copper: [ Point(6,1), Point(6,2) ],
        .desert: [ Point(8,1), Point(8,2) ]
    ]

    return AmphipodHouse(amphipods: amphipods, homePoints: homePoints)
}

func part2House(_ amphipods: [Amphipod]) -> AmphipodHouse {
    let homePoints: [Amphipod.AmphipodType:[Point]] = [
        .amber: [ Point(2,1), Point(2,2), Point(2,3), Point(2,4) ],
        .bronze: [ Point(4,1), Point(4,2), Point(4,3), Point(4,4) ],
        .copper: [ Point(6,1), Point(6,2), Point(6,3), Point(6,4) ],
        .desert: [ Point(8,1), Point(8,2), Point(8,3), Point(8,4) ]
    ]
    
    let additionalPods = [
        Amphipod(type: .desert, location: Point(2,2)),
        Amphipod(type: .desert, location: Point(2,3)),
        Amphipod(type: .copper, location: Point(4,2)),
        Amphipod(type: .bronze, location: Point(4,3)),
        Amphipod(type: .bronze, location: Point(6,2)),
        Amphipod(type: .amber,  location: Point(6,3)),
        Amphipod(type: .amber,  location: Point(8,2)),
        Amphipod(type: .copper, location: Point(8,3))
    ]

    return AmphipodHouse(amphipods: amphipods + additionalPods, homePoints: homePoints)
}

func part1() {
    let testPods = [
        Amphipod(type: .bronze, location: Point(2,1)),
        Amphipod(type: .amber,  location: Point(2,2)),
        Amphipod(type: .copper, location: Point(4,1)),
        Amphipod(type: .desert, location: Point(4,2)),
        Amphipod(type: .bronze, location: Point(6,1)),
        Amphipod(type: .copper, location: Point(6,2)),
        Amphipod(type: .desert, location: Point(8,1)),
        Amphipod(type: .amber,  location: Point(8,2))
    ]
    let pods = [
        Amphipod(type: .bronze, location: Point(2,1)),
        Amphipod(type: .copper, location: Point(2,2)),
        Amphipod(type: .amber,  location: Point(4,1)),
        Amphipod(type: .desert, location: Point(4,2)),
        Amphipod(type: .bronze, location: Point(6,1)),
        Amphipod(type: .desert, location: Point(6,2)),
        Amphipod(type: .copper, location: Point(8,1)),
        Amphipod(type: .amber,  location: Point(8,2))
    ]
    
//    var cache = [AmphipodHouse:[Int]]()
//    let testPaths = allPathCosts(part1House(testPods), cache: &cache)
//    let testShortest = testPaths.min()!
//    let testShortest = shortestPathCost(part1House(testPods))
    var cache = [AmphipodHouse:Int?]()
    let testShortest = shortestPathCostRecursive(part1House(testPods), cache: &cache)!
    print("TEST: Shortest path is \(testShortest)")
    assert(testShortest == 12521)

//    let paths = allPathCosts(part1House(pods), cache: &cache)
//    let shortest = paths.min()!
    let shortest = shortestPathCostRecursive(part1House(pods), cache: &cache)!
    print("Shortest path is \(shortest)")
    assert(shortest == 14510)
}

func part2() {
    let testPods = [
        Amphipod(type: .bronze, location: Point(2,1)),
        Amphipod(type: .amber,  location: Point(2,4)),
        Amphipod(type: .copper, location: Point(4,1)),
        Amphipod(type: .desert, location: Point(4,4)),
        Amphipod(type: .bronze, location: Point(6,1)),
        Amphipod(type: .copper, location: Point(6,4)),
        Amphipod(type: .desert, location: Point(8,1)),
        Amphipod(type: .amber,  location: Point(8,4))
    ]
    let pods = [
        Amphipod(type: .bronze, location: Point(2,1)),
        Amphipod(type: .copper, location: Point(2,4)),
        Amphipod(type: .amber,  location: Point(4,1)),
        Amphipod(type: .desert, location: Point(4,4)),
        Amphipod(type: .bronze, location: Point(6,1)),
        Amphipod(type: .desert, location: Point(6,4)),
        Amphipod(type: .copper, location: Point(8,1)),
        Amphipod(type: .amber,  location: Point(8,4))
    ]

//    var cache = [AmphipodHouse:[Int]]()
//    let testPaths = allPathCosts(part2House(testPods), cache: &cache)
//    let testShortest = testPaths.min()!
//    let testShortest = shortestPathCost(part2House(testPods))
    var cache = [AmphipodHouse:Int?]()
    let testShortest = shortestPathCostRecursive(part2House(testPods), cache: &cache)!
    print("TEST: Shortest path is \(testShortest)")
    assert(testShortest == 44169)

//    let paths = allPathCosts(part2House(pods), cache: &cache)
//    let shortest = paths.min()!
//    let shortest = shortestPathCost(part2House(pods))
    let shortest = shortestPathCostRecursive(part2House(pods), cache: &cache)!
    print("Shortest path is \(shortest)")
    assert(shortest == 49180)
}
