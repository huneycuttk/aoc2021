//
//  main.swift
//  day15
//
//  Created by Karsten Huneycutt on 2021-12-15.
//

import Foundation
import Collections

let testGrid = try parseGrid(readFile("file:///Users/kph/Stuff/aoc2021/day15/test-input.txt"))
let grid = try parseGrid(readFile("file:///Users/kph/Stuff/aoc2021/day15/input.txt"))

part1()
part2()

struct Point : Hashable {
    let x, y: Int
}

typealias RiskGrid = [[Int]]
extension RiskGrid {
    subscript(x: Int, y: Int) -> Int {
        get {
            self[x][y]
        }
        set(newValue) {
            self[x][y] = newValue
        }
    }
    
    subscript(p: Point) -> Int {
        get {
            self[p.x, p.y]
        }
        set(newValue) {
            self[p.x, p.y] = newValue
        }
    }
    
    var maxRow: Int {
        return self.count-1
    }
    
    var maxCol: Int {
        return self[0].count-1
    }
    
    func neighboringPoints(point p: Point) -> [Point] {
        let points = [ (p.x, p.y+1), (p.x, p.y-1), (p.x+1, p.y), (p.x-1, p.y) ]
            .filter { $0.0 >= 0 && $0.0 <= maxRow && $0.1 >= 0 && $0.1 <= maxCol }
            .map { Point(x: $0.0, y: $0.1) }
        return points
    }
    
    func increment(factor: Int) -> RiskGrid {
        map { $0.map { ($0+factor) > 9 ? ($0+factor-9) : ($0+factor) } }
    }
    
    func tile(count tileCount: Int) -> RiskGrid {
        let tiles = [Int](0...((tileCount-1)*2)).map { increment(factor: $0) }
        let xCount = self.count
        let yCount = self[0].count
        
        var newGrid = RiskGrid(repeating: [Int](repeating: 0, count: self[0].count*tileCount), count: self.count*tileCount)
        
        for xTile in 0..<tileCount {
            for yTile in 0..<tileCount {
                for x in 0...maxRow {
                    for y in 0...maxCol {
                        // the new grid coordinate is the offset (x, y) from the start of the current tile
                        // which is xTile times the size (eg, third tile along x and second tile along y
                        // starts at 3 * number of rows + 0, 2 * number of columns + 0.  The value is the
                        // incremented one in the two tile counts added together (eg, the tile offset by 5)
                        newGrid[x+xTile*xCount, y+yTile*yCount] = tiles[xTile+yTile][x, y]
                    }
                }
            }
        }
        
        return newGrid
    }
    
    struct Path : Comparable {
        static func < (lhs: Array<Element>.Path, rhs: Array<Element>.Path) -> Bool {
            lhs.weight < rhs.weight
        }
        
        let weight: Int
        let path: [Point]
    }
    func lowestWeightPath(from: Point, to: Point) -> Path {
        var visited: Set<Point> = []
        var queue = Heap<Path>()
        queue.insert(Path(weight: 0, path: [from]))
        
        while (!queue.isEmpty) {
            // find the current lowest weight path
            // this would be much faster with a heap/priority queue
            let path = queue.removeMin()
            
            let lastPoint = path.path.last!
            // if we've reached the destination, success!
            if (lastPoint == to) {
                return path
            }
            
            // for each neighboring point, if we haven't been here, add the new
            // path with the calculated weight, and add it to the visited list.
            neighboringPoints(point: lastPoint).forEach { neighbor in
                if (!visited.contains(neighbor)) {
                    let weight = self[neighbor]
                    queue.insert(Path(weight: path.weight + weight, path: path.path + [neighbor]))
                    visited.insert(neighbor)
                }
            }
        }
        
        // should not get here!
        return queue.removeMin()
    }
}

typealias RiskGraph = [Point:[(Int, Point)]]
extension RiskGraph {
    mutating func addEdge(from: Point, to: Point, weight: Int) {
        self[from, default: []] += [ (weight, to) ]
    }
    
    init(grid: RiskGrid) {
        self.init()
        for x in 0...grid.maxRow {
            for y in 0...grid.maxCol {
                let point = Point(x: x, y: y)
                let weight = grid[point]
                // grid specifies the weight of _incoming_ edges
                grid.neighboringPoints(point: point).forEach {
                    addEdge(from: $0, to: point, weight: weight)
                }
            }
        }
    }
    
    func lowestWeightPath(from: Point, to: Point) -> Int {
        var distance: [Point:Int] = [:]
        distance[from] = 0

        var queue = [ from ]
        
        // Dijkstra's (no need to bother keeping the path, though)
        while (!queue.isEmpty) {
            // this would probably be somewhat faster with a priority queue/heap
            queue.sort { distance[$0] ?? Int.max < distance[$1] ?? Int.max}
            let nextNode = queue.removeFirst()
            let nextDistance = distance[nextNode] ?? Int.max
            
            for edge in self[nextNode]! {
                let (weight, neighbor) = edge
                let newDistance = nextDistance + weight
                if (newDistance < distance[neighbor] ?? Int.max) {
                    distance[neighbor] = newDistance
                    if (!queue.contains(neighbor)) {
                        queue.append(neighbor)
                    }
                }
            }
        }
        
        return distance[to]!
    }
}

func parseGrid(_ data: [String]) -> RiskGrid {
    let grid = data.map { $0.map { Int(String($0))! } }
    return grid
}

func part1() {
    let testGraph = RiskGraph(grid: testGrid)
    let testWeight = testGraph.lowestWeightPath(from: Point(x: 0, y: 0),
                                                to: Point(x: testGrid.maxRow, y: testGrid.maxCol))
    let testWeightGridPath = testGrid.lowestWeightPath(from: Point(x: 0, y: 0),
                                                       to: Point(x: testGrid.maxRow, y: testGrid.maxCol))
    assert(testWeight == testWeightGridPath.weight)
    print("TEST: Lowest weight is \(testWeight)")
    assert(testWeight == 40)
    
    
    let graph = RiskGraph(grid: grid)
    let weight = graph.lowestWeightPath(from: Point(x: 0, y: 0),
                                        to: Point(x: grid.maxRow, y: grid.maxCol))
    let weightGridPath = grid.lowestWeightPath(from: Point(x: 0, y: 0),
                                               to: Point(x: grid.maxRow, y: grid.maxCol))
    assert(weight == weightGridPath.weight)
    print("Lowest weight is \(weight)")
    assert(weight == 583)
}

func part2() {
    let testTiledGrid = testGrid.tile(count: 5)
    let testTiledGraph = RiskGraph(grid: testTiledGrid)
    let testWeight = testTiledGraph.lowestWeightPath(from: Point(x: 0, y: 0),
                                                     to: Point(x: testTiledGrid.maxRow, y: testTiledGrid.maxCol))
    let testWeightGridPath = testTiledGrid.lowestWeightPath(from: Point(x: 0, y: 0),
                                                            to: Point(x: testTiledGrid.maxRow, y: testTiledGrid.maxCol))
    assert(testWeight == testWeightGridPath.weight)
    print("TEST: Lowest weight is \(testWeight)")
    assert(testWeight == 315)

    
    let tiledGrid = grid.tile(count: 5)
    let tiledGraph = RiskGraph(grid: tiledGrid)
    let weight = tiledGraph.lowestWeightPath(from: Point(x: 0, y: 0),
                                             to: Point(x: tiledGrid.maxRow, y: tiledGrid.maxCol))
    let weightGridPath = tiledGrid.lowestWeightPath(from: Point(x: 0, y: 0),
                                                    to: Point(x: tiledGrid.maxRow, y: tiledGrid.maxCol))
    assert(weight == weightGridPath.weight)
    print("Lowest weight is \(weightGridPath.weight)")
    assert(weight == 2927)
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

extension Array where Element : Hashable {
    func countUnique() -> [Element:Int] {
        return reduce(into: [Element:Int]()) { $0[$1, default: 0] += 1 }
    }
}

