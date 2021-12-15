//
//  main.swift
//  day14
//
//  Created by Karsten Huneycutt on 2021-12-14.
//

import Foundation
import Algorithms

let (testTemplate, testRules) = try parsePolymerAndRules(readFile("file:///Users/kph/Stuff/aoc2021/day14/test-input.txt"))
let (template, rules) = try parsePolymerAndRules(readFile("file:///Users/kph/Stuff/aoc2021/day14/input.txt"))

part1()
part2()

typealias Pair = (Character, Character)
typealias Rule = (Pair, Character)
typealias Rules = [Rule]
typealias Polymer = [Character]
typealias RulePairMap = [[Character]:[[Character]]]
typealias PolymerPairMap = [[Character]:Int]

func parsePolymerAndRules(_ data: [String]) -> (Polymer, Rules) {
    let rules = data[2..<data.count].map { line -> Rule in
        let parts = line.components(separatedBy: " -> ")
        
        return ((parts[0].first!, parts[0].last!), parts[1].first!)
    }
    return (Array(data[0]), rules)
}

extension Rules {
    subscript(_ pair: Pair) -> Character? {
        return first { $0.0 == pair }?.1
    }
    
    func toPairMap() -> RulePairMap {
        // each rule maps from one pair to two pairs:  AB->C maps AB to AC, CB
        reduce(into: RulePairMap()) { $0[[$1.0.0, $1.0.1]] = [[$1.0.0, $1.1], [$1.1, $1.0.1]] }
    }
}

extension Polymer {
    func polymerExpansion(rules: Rules) -> Polymer {
        windows(ofCount: 2).flatMap { window -> [Character] in
            let pair = (window.first!, window.last!)
            if let add = rules[pair] {
                return [ pair.0, add ]
            } else {
                return [ pair.0 ]
            }
        } + [ self.last! ]
    }
    
    func toPairMap() -> PolymerPairMap {
        return windows(ofCount: 2)
            .map { [ $0.first!, $0.last! ] }
            .countUnique()
    }
}

extension PolymerPairMap {
    func polymerExpansion(rulePairs: RulePairMap) -> PolymerPairMap {
        return self.reduce(into: PolymerPairMap()) { hash, pairCount in
            let (pair, count) = pairCount
            if let mapped = rulePairs[pair] {
                mapped.forEach { hash[$0, default: 0] += count }
            } else {
                hash[pair, default: 0] += count
            }
        }
    }
}

func mostCommonMinusLeastCommonByExpansion(polymer: Polymer, rules: Rules, count: Int) -> Int {
    let finalPolymer = [Int](0..<count).reduce(polymer) { polymer, _ in polymer.polymerExpansion(rules: rules) }
    let counts = finalPolymer.countUnique()
    return counts.values.max()! - counts.values.min()!
}

func mostCommonMinusLeastCommonByPairs(polymer: Polymer, rules: Rules, count: Int) -> Int {
    let rulePairMap = rules.toPairMap()
    let finalPairCounts = [Int](0..<count)
        .reduce(polymer.toPairMap()) { pairMap, _ in pairMap.polymerExpansion(rulePairs: rulePairMap) }
    
    var counts = finalPairCounts.reduce(into: [Character:Int]()) { counts, pairCount in
        let (pair, count) = pairCount
        // count only the first letter; otherwise we'll double count
        counts[pair.first!, default: 0] += count
    }
    // because we counted only the first letter, need to add one to the count of the final letter
    counts[polymer.last!, default: 0] += 1
    return counts.values.max()! - counts.values.min()!
}

func part1() {
    let testAnswer = mostCommonMinusLeastCommonByExpansion(polymer: testTemplate, rules: testRules, count: 10)
    let testAnswer2 = mostCommonMinusLeastCommonByPairs(polymer: testTemplate, rules: testRules, count: 10)
    assert(testAnswer == testAnswer2)
    print("TEST: Answer is \(testAnswer)")
    assert(testAnswer == 1588)
    
    let answer = mostCommonMinusLeastCommonByExpansion(polymer: template, rules: rules, count: 10)
    let answer2 = mostCommonMinusLeastCommonByPairs(polymer: template, rules: rules, count: 10)
    assert(answer == answer2)
    print("Answer is \(answer)")
    assert(answer == 4244)
}

func part2() {
    let testAnswer = mostCommonMinusLeastCommonByPairs(polymer: testTemplate, rules: testRules, count: 40)
    print("TEST: Answer is \(testAnswer)")
    assert(testAnswer == 2188189693529)
    
    let answer = mostCommonMinusLeastCommonByPairs(polymer: template, rules: rules, count: 40)
    print("Answer is \(answer)")
    assert(answer == 4807056953866)
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
