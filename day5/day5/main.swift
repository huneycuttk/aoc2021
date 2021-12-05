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

let lines = parsePoints(data)

// part 1
let testIntersectionsAnswer = 5
let testIntersections = countIntersections(lines: testLines.filter { isHorizontalOrVertical($0) })
print("TEST: Intersections \(testIntersections)")
guard (testIntersections == testIntersectionsAnswer) else {
    print("INCORRECT ANSWER")
    exit(1)
}

let intersections = countIntersections(lines: lines.filter { isHorizontalOrVertical($0) })
print("Intersections \(intersections)")

// part 2
let testIntersectionsAnswer2 = 12
let testIntersections2 = countIntersections(lines: testLines)
print("TEST: Intersections \(testIntersections2)")
guard (testIntersections2 == testIntersectionsAnswer2) else {
    print("INCORRECT ANSWER")
    exit(1)
}

let intersections2 = countIntersections(lines: lines)
print("Intersections \(intersections2)")


func parsePoints<S: StringProtocol>(_ data: [S]) -> [Line] {
   return data.map { Line($0.components(separatedBy: "->")
                            .map { $0.components(separatedBy: ",")
                                     .map { Int($0.trimmingCharacters(in: .whitespacesAndNewlines))! } }
                            .map { Point($0) }) }
}

func isHorizontalOrVertical(_ line: Line) -> Bool {
    return line.start.x == line.end.x || line.start.y == line.end.y
}

func countIntersections(lines: [Line]) -> Int {
   return lines.flatMap { $0.pointsInLine() }
        .reduce(into: [:]) { $0[$1, default: 0] += 1}
        .filter { $0.1 > 1 }.keys.count
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
            if start.x > end.x { rows = rows.reversed() }

            let startCol = [ start.y, end.y ].min() ?? 0
            let endCol = [ start.y, end.y ].max() ?? 0
            cols = [Int](startCol...endCol)
            if start.y > end.y { cols = cols.reversed() }
        }
        
        return zip(rows, cols).map { Point($0) }
    }
}
