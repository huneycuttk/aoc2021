//
//  main.swift
//  day12
//
//  Created by Karsten Huneycutt on 2021-12-12.
//

import Foundation

let testGraph = try parseGraph(readFile("file:///Users/kph/Stuff/aoc2021/day12/test-input.txt"))
let graph = try parseGraph(readFile("file:///Users/kph/Stuff/aoc2021/day12/input.txt"))

part1()
part2()

typealias Vertex = String
typealias Graph = [Vertex:Set<Vertex>]
typealias Path = [Vertex]
func parseGraph(_ data: [String]) -> Graph {
    return data.map { $0.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) } }
        .reduce(into: Graph()) { graph, edge in
            graph[edge[0], default: Set<Vertex>()].insert(edge[1])
            graph[edge[1], default: Set<Vertex>()].insert(edge[0])
        }
}
    
func findNumberOfPaths(graph: Graph, from start: Vertex, to end: Vertex, canRevisit: (Vertex, Set<Path>) -> Bool) -> Int {
    return findPaths(graph: graph, from: start, to: end,
                     paths: Set<Path>(arrayLiteral: [ start ]), canRevisit: canRevisit).count
}

func findPaths(graph: Graph, from start: Vertex, to end: Vertex,
               paths: Set<Path>, canRevisit: (Vertex, Set<Path>) -> Bool) -> Set<Path> {
    if (start == end || paths.isEmpty) {
        return paths
    }
        
    return graph[start, default: Set<Vertex>()].map() { nextVertex -> Set<Path> in
        let deadEnds = canRevisit(nextVertex, paths) ? [] : paths.filter { $0.contains(nextVertex) }
        let newPaths = Set(paths.subtracting(deadEnds).map { $0 + [ nextVertex ] })
        
        
        return findPaths(graph: graph, from: nextVertex, to: end, paths: newPaths, canRevisit: canRevisit)
    }.reduce(Set<Path>()) { $0.union($1) }
}

func onlyBigCaves(_ vertex: Vertex, _ paths: Set<Path>) -> Bool {
    return vertex.isUppercase()
}

func canRevisitSingleSmallCaveTwice(_ vertex: Vertex, _ paths: Set<Path>) -> Bool {
    if (vertex.isUppercase()) {
        return true
    }
    
    if (["start", "end"].contains(vertex)) {
        return false
    }
    
    let smallCaves = paths.map { $0.filter { $0.isLowercase() }
        .reduce(into: [Vertex:Int]()) { $0[$1, default: 0] += 1 } }
    if (smallCaves.first(where: { $0.values.contains { $0 > 1 } }) != nil) {
        return false
    }
    
    return true
}

extension String {
    func isUppercase() -> Bool {
        self.uppercased() == self
    }
    
    func isLowercase() -> Bool {
        self.lowercased() == self
    }
}

func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

func part1() {
    let testNumberOfPaths = findNumberOfPaths(graph: testGraph, from: "start", to: "end", canRevisit: onlyBigCaves)
    print("TEST: Number of paths \(testNumberOfPaths)")
    assert(testNumberOfPaths == 226)

    let numberOfPaths = findNumberOfPaths(graph: graph, from: "start", to: "end", canRevisit: onlyBigCaves)
    print("Number of paths \(numberOfPaths)")
    assert(numberOfPaths == 3000)
}

func part2() {
    let testNumberOfPaths2 = findNumberOfPaths(graph: testGraph, from: "start", to: "end", canRevisit: canRevisitSingleSmallCaveTwice)
    print("TEST: Number of paths \(testNumberOfPaths2)")
    assert(testNumberOfPaths2 == 3509)

    let numberOfPaths2 = findNumberOfPaths(graph: graph, from: "start", to: "end", canRevisit: canRevisitSingleSmallCaveTwice)
    print("Number of paths \(numberOfPaths2)")
    assert(numberOfPaths2 == 74222)
}
