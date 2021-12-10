//
//  main.swift
//  day10
//
//  Created by Karsten Huneycutt on 2021-12-10.
//

import Foundation

let testUrl = URL(string: "file:///Users/kph/Stuff/aoc2021/day10/test-input.txt")!
let testData = try String(contentsOf: testUrl).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day10/input.txt")!
let data = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

let testErrorScore = try scoreForAllErrors(data: testData)
print("TEST:  Error score \(testErrorScore)")
assert(testErrorScore == 26397)

let errorScore = try scoreForAllErrors(data: data)
print("Error score \(errorScore)")
assert(errorScore == 311949)

let testAutocompletionScore = scoreForAutocompletion(data: testData)
print("TEST:  Autocompletion score \(testAutocompletionScore)")
assert(testAutocompletionScore == 288957)

let autocompletionScore = scoreForAutocompletion(data: data)
print("Autocompletion score \(autocompletionScore)")
assert(autocompletionScore == 3042730309)

struct Scores {
    static let errorScores: [Character:Int] = [
        ")": 3,
        "]": 57,
        "}": 1197,
        ">": 25137
    ]
    
    static let completionScores: [Character:Int] = [
        ")": 1,
        "]": 2,
        "}": 3,
        ">": 4
    ]
}

func scoreForAllErrors(data: [String]) throws -> Int {
    return try data.compactMap(getError)
        .compactMap { Scores.errorScores[$0] }
        .reduce(0, +)
}

func getError(_ line: String) throws -> Character? {
    do {
        let _ = try Parser.parse(line)
        return nil
    } catch (Parser.ParseError.InvalidClosingToken(let char)) {
        return char
    }
}
    
func scoreForAutocompletion(data: [String]) -> Int {
    let scores = data.compactMap(autoComplete)
        .map(scoreAutoComplete)
        .filter { $0 > 0 }
        .sorted()
     
    return scores[scores.count/2]
}

func autoComplete(_ line: String) -> [Character]? {
    do {
        return try Parser.parse(line)
    } catch {
        return nil
    }
}

func scoreAutoComplete(_ chars: [Character]) -> Int {
    return chars.reduce(0) { 5*$0 + (Scores.completionScores[$1] ?? 0) }
}

struct Parser {
    enum ParseError : Error {
        case InvalidClosingToken(Character)
        case InvalidCharacter(Character)
    }

    static let tokenPairs: [Character:Character] = [ "(": ")", "[": "]", "{": "}", "<": ">" ]

    static func parse(_ line: String) throws -> [Character] {
        var tokens: [Character] = []

        for char in line {
            if (tokenPairs.keys.contains(char)) {
                tokens.append(char)
            } else if (tokenPairs.values.contains(char)){
                let opener = tokens.removeLast()
                if (char != tokenPairs[opener]) {
                    throw ParseError.InvalidClosingToken(char)
                }
            } else {
                throw ParseError.InvalidCharacter(char)
            }
        }

        return tokens.reversed().map { tokenPairs[$0]! }
    }
}
