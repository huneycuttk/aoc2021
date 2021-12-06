//
//  main.swift
//  day1
//
//  Created by Karsten Huneycutt on 2021-12-01.
//

import Foundation


let testDepths = [ 199, 200, 208, 210, 200, 207, 240, 269, 260, 263]
let testIncreasingDepths = countIncreasing(testDepths)
assert(testIncreasingDepths == 7)

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day1/input.txt")!
let depths = try String(contentsOf: url).split(separator: "\n").map { Int($0)! }

let increasingDepths = countIncreasing(depths)
print("Count increasing depths answer is \(increasingDepths)")
assert(increasingDepths == 1713)

let testIncreasingWindows = countIncreasing(windows(testDepths))
assert(testIncreasingWindows == 5)

let increasingWindows = countIncreasing(windows(depths))
print("Count increasing windows answer is \(increasingWindows)")
assert(increasingWindows == 1734)

func countIncreasing(_ ary: [Int]) -> Int {
    return zip(ary, ary.dropFirst()).reduce(0) { count, tuple in
        let (a, b) = tuple
        return b > a ? count + 1 : count
    }
}

func windows(_ ary: [Int]) -> [Int] {
    return triplewise(ary).map { t -> Int in
        let (a,b,c) = t
        return a+b+c
    }
}

func triplewise<T>(_ ary: [T]) -> [(T,T,T)] {
    var result: [(T,T,T)] = []
    for i in 0..<ary.count-2 {
        result.append((ary[i], ary[i+1], ary[i+2]))
    }
    return result
}
