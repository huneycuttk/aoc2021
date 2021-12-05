//
//  main.swift
//  day5
//
//  Created by Karsten Huneycutt on 2021-12-04.
//

import Foundation

let testData = """
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
""".split(separator: "\n")

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day5/input.txt")!
let data = try String(contentsOf: url).split(separator: "\n")

let testLines = parsePoints(testData)
let (testMaxX, testMaxY) = findMax(testLines)

let lines = parsePoints(data)
let (maxX, maxY) = findMax(lines)

// part 1
let testIntersectionsAnswer = 5
var testGrid = Grid(maxX: testMaxX, maxY: testMaxY)
testGrid.plot(lines: testLines.filter { isHorizontalOrVertical($0) })

let testIntersections = testGrid.countIntersections()
print("TEST: Intersections \(testIntersections)")
guard (testIntersections == testIntersectionsAnswer) else {
    print("INCORRECT ANSWER")
    exit(1)
}

var grid = Grid(maxX: maxX, maxY: maxY)
grid.plot(lines: lines.filter { isHorizontalOrVertical($0) })

let intersections = grid.countIntersections()
print("Intersections \(intersections)")

// part 2
let testIntersectionsAnswer2 = 12
var testGrid2 = Grid(maxX: testMaxX, maxY: testMaxY)
testGrid2.plot(lines: testLines)
let testIntersections2 = testGrid2.countIntersections()
print("TEST: Intersections \(testIntersections2)")
guard (testIntersections2 == testIntersectionsAnswer2) else {
    print("INCORRECT ANSWER")
    exit(1)
}

var grid2 = Grid(maxX: maxX, maxY: maxY)
grid2.plot(lines: lines)

let intersections2 = grid2.countIntersections()
print("Intersections \(intersections2)")



func parsePoints<S: StringProtocol>(_ data: [S]) -> [Line] {
   return data.map { Line($0.components(separatedBy: "->")
                            .map { $0.components(separatedBy: ",")
                                     .map { Int($0.trimmingCharacters(in: .whitespacesAndNewlines))! } }
                            .map { Point($0) }) }
}

func findMax(_ lines: [Line]) -> (Int, Int) {
    return (lines.flatMap { [ $0.start.x, $0.end.x ]}.max() ?? 0,
            lines.flatMap { [ $0.start.y, $0.end.y ]}.max() ?? 0)
}

func isHorizontalOrVertical(_ line: Line) -> Bool {
    return line.start.x == line.end.x || line.start.y == line.end.y
}

struct Point : Hashable {
    let x,y: Int
    init(_ point: [Int]) {
        self.x = point[0]
        self.y = point[1]
    }
    init (_ tuple: (Int, Int)) {
        self.x = tuple.0
        self.y = tuple.1
    }
}

struct Line {
    let start, end: Point
    init(_ points: [Point]) {
        self.start = points[0]
        self.end = points[1]
    }
    
    func pointsInLine() -> [Point] {
        var rows: [Int]
        var cols: [Int]
        if (start.x == end.x) {
            let startCol = [ start.y, end.y ].min() ?? 0
            let endCol = [ start.y, end.y ].max() ?? 0
            cols = [Int](startCol...endCol)
            rows = [Int](repeating: start.x, count: cols.count)
        } else if (start.y == end.y) {
            let startRow = [ start.x, end.x ].min() ?? 0
            let endRow = [ start.x, end.x ].max() ?? 0
            rows = [Int](startRow...endRow)
            cols = [Int](repeating: start.y, count: rows.count)
        } else {
            let startRow = [ start.x, end.x ].min() ?? 0
            let endRow = [ start.x, end.x ].max() ?? 0
            rows = [Int](startRow...endRow)
            if start.x < end.x { rows = rows.reversed() }

            let startCol = [ start.y, end.y ].min() ?? 0
            let endCol = [ start.y, end.y ].max() ?? 0
            cols = [Int](startCol...endCol)
            if start.y < end.y { cols = cols.reversed() }
        }
        
        return zip(rows, cols).map { Point($0) }
    }
}

struct Grid {
    var points: [[Int]]
    
    init(maxX: Int, maxY: Int) {
        self.points = [[Int]](repeating: [Int](repeating: 0, count: maxY+1), count: maxX+1)
    }
    
    mutating func plot(lines: [Line]) -> Void {
        lines.forEach { $0.pointsInLine().forEach { points[$0.x][$0.y] += 1 } }
    }
    
    func countIntersections() -> Int {
        return points.reduce(0) { $0 + $1.filter { $0 > 1 }.count }
    }
    
}
