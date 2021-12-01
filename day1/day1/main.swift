//
//  main.swift
//  day1
//
//  Created by Karsten Huneycutt on 2021-12-01.
//

import Foundation


let testData = [ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
let testAnswerOne = 7
guard testAnswerOne == countIncreasing(testData) else {
    print("countIncreasing is wrong!!")
    exit(1)
}

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day1/input.txt")!
let depths = try String.init(contentsOf: url).split(separator: "\n").map { Int($0)! }

let increasingDepths = countIncreasing(depths)

print("Count increasing depths answer is \(increasingDepths)")

let windows = triplewise(depths).map { t -> Int in
    let (a,b,c) = t
    return a+b+c
}

let increasingWindows = countIncreasing(windows)

print("Count increasing windows answer is \(increasingWindows)")

func countIncreasing(_ ary: [Int]) -> Int {
    return zip(ary, ary.dropFirst()).reduce(0) { count, tuple in
        let (a, b) = tuple
        return b > a ? count + 1 : count
    }
}

func triplewise<T>(_ ary: [T]) -> [(T,T,T)] {
    var result: [(T,T,T)] = []
    for i in 0..<ary.count-2 {
        result.append((ary[i], ary[i+1], ary[i+2]))
    }
    return result
}
