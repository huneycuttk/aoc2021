//
//  main.swift
//  day8
//
//  Created by Karsten Huneycutt on 2021-12-08.
//

import Foundation

let testData = """
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
""".components(separatedBy: "\n")

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day8/input.txt")!
let data = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")

let testLines = parseLines(testData)
let lines = parseLines(data)

let testAnswer = countSimple(testLines)
print("TEST: Simple digits \(testAnswer)")
assert(testAnswer == 26)
    
let answer = countSimple(lines)
print("Simple digits \(answer)")
assert(answer == 445)

let testOutputAnswer = decodeOutputs(data: testLines)
print("TEST: Output answer \(testOutputAnswer)")
assert(testOutputAnswer == 61229)

let outputAnswer = decodeOutputs(data: lines)
print("Output answer \(outputAnswer)")
assert(outputAnswer == 1043101)

func parseLines<S: StringProtocol>(_ data: [S]) -> [([String], [String])] {
    let x = data.map { $0.components(separatedBy: "|")
                        .map { $0.trimmingCharacters(in: .whitespaces) } }
    return x.map { ($0[0].components(separatedBy: .whitespaces), $0[1].components(separatedBy: .whitespaces))}
}

func countSimple(_ data: [([String], [String])]) -> Int {
    return data.reduce(0) { $0 + $1.1.reduce(0) { [ 2, 3, 4, 7].contains($1.count) ? $0 + 1 : $0 } }
}

func decodeOutputs(data: [([String], [String])]) -> Int {
    data.map { decodeOutput(code: decodeInputs($0.0), output: $0.1) }.reduce(0, +)
}

func decodeOutput(code: [Set<Character>], output: [String]) -> Int {
    return Int(output.map { Set($0) }.map { code.firstIndex(of: $0)! }.map { String($0) }.joined())!
}

func decodeInputs(_ codes: [String]) -> [Set<Character>] {
    let codeSets = codes.map { Set($0) }
    // these are unique length codes
    let one = codeSets.first { $0.count == 2 }!
    let four = codeSets.first { $0.count == 4 }!
    let seven = codeSets.first { $0.count == 3 }!
    let eight = codeSets.first { $0.count == 7 }!
    
    // first deal with the six character codes, 9 0 6
    let lenSix = codeSets.filter { $0.count == 6 }
    // nine is the only six character code that contains everything in four
    let nine = lenSix.first { $0.isSuperset(of: four) }!
    // zero is the six character code that contains all of everything in seven, but does not contain the
    // character that four has that seven does not
    let zero = lenSix.first { $0.isSuperset(of: seven) && !$0.isSuperset(of: four) }!
    // six is the other six character code
    let six = lenSix.first { $0 != nine && $0 != zero }!

    // now the five character codes 3 2 5
    let lenFive = codeSets.filter { $0.count == 5 }
    // three is the only five character code that contains the two characters in one
    let three = lenFive.first { $0.isSuperset(of: one) }!
    // two is the five character code that contains the one character that nine does not
    // (e in the non-jumbled display)
    let e = eight.subtracting(nine).first!
    let two = lenFive.first { $0.contains(e) }!
    // five is the remaining five character code
    let five = lenFive.first { $0 != three && $0 != two }!
        
    return [ zero, one, two, three, four, five, six, seven, eight, nine ]
}
