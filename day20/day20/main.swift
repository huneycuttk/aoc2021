//
//  main.swift
//  day20
//
//  Created by Karsten Huneycutt on 2021-12-20.
//

import Foundation
import Algorithms


let (testEnhancer, testImage) = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day20/test-input.txt"))
let (enhancer, image) = try parse(readFile("file:///Users/kph/Stuff/aoc2021/day20/input.txt"))

part1()
part2()

func parse(_ data: [String]) -> (ImageEnhancer, InfiniteImage) {
    let enhancer = ImageEnhancer(resultPixels: Array(data.first!).map { $0 == "#" ? true : false } )
    
    let pixels = Dictionary(uniqueKeysWithValues: data[2..<data.count].enumerated().flatMap { (rowIdx, row) in
        Array(row).enumerated().map { (colIdx, col) in
            return (Point(rowIdx, colIdx), col == "#")
        }
    })
                            
    return (enhancer, InfiniteImage(pixels: pixels, defaultValue: false))
}

struct ImageEnhancer {
    let resultPixels: [Bool]
    
    func enhance(image: InfiniteImage) -> InfiniteImage {
        var newPixels = [Point:Bool]()
        
        let min = image.min
        let max = image.max
        
        // up to two pixels away in each direction can be changed by the
        // enhancer, so just extend outward that much.
        for x in min.x-2...max.x+2 {
            for y in min.y-2...max.y+2 {
                let idx = Int(String(Point(x,y).neighborhood()
                                        .map { image[$0] }
                                        .map { $0 ? "1" : "0" }), radix: 2)!
                let newPixel = resultPixels[idx]
                newPixels[Point(x, y)] = newPixel
            }
        }
        
        // if the old default is false, then take what's at 0.  if it is true, then
        // take what's at the end (511).
        let newDefault = image.defaultValue ? resultPixels.last! : resultPixels.first!
        
        return InfiniteImage(pixels: newPixels, defaultValue: newDefault)
    }
    
}

struct Point: Hashable {
    let x,y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    func neighborhood() -> [Point] {
        [ Point(x-1,y-1), Point(x-1,y), Point(x-1,y+1),
          Point(x,y-1),   Point(x,y),   Point(x,y+1),
          Point(x+1,y-1), Point(x+1,y), Point(x+1,y+1) ]
    }
}

struct InfiniteImage {
    let pixels: [Point:Bool]
    let defaultValue: Bool
    
    init (pixels: [Point:Bool], defaultValue: Bool) {
        self.pixels = pixels.filter { $0.value != defaultValue }
        self.defaultValue = defaultValue
    }
    
    var min: Point {
        let x = pixels.keys.map { $0.x }.min()!
        let y = pixels.keys.map { $0.y }.min()!
        return Point(x, y)
    }
    
    var max: Point {
        let x = pixels.keys.map { $0.x }.max()!
        let y = pixels.keys.map { $0.y }.max()!
        return Point(x, y)
    }

    subscript(x: Int, y: Int) -> Bool {
        get {
            self[Point(x, y)]
        }
    }
    
    subscript(_ point: Point) -> Bool {
        get {
            pixels[point, default: defaultValue]
        }
    }
    
    func toString() -> String {
        let min = min
        let max = max
        
        return [Int](min.x...max.x).map { x in
            [Int](min.y...max.y).map { y in
                self[x, y] ? "#" : "."
            }.joined()
        }.joined(separator: "\n")
    }
}

func enhanceAndCountTruePixels(image: InfiniteImage, enhancer: ImageEnhancer, count: Int) -> Int {
    let result = [Int](0..<count).reduce(image) { img, _ in enhancer.enhance(image: img) }
    return result.pixels.values.filter { $0 }.count
}

func part1() {
    let testPixelCount = enhanceAndCountTruePixels(image: testImage, enhancer: testEnhancer, count: 2)
    print("TEST: Pixel count is \(testPixelCount)")
    assert(testPixelCount == 35)
    
    let pixelCount = enhanceAndCountTruePixels(image: image, enhancer: enhancer, count: 2)
    print("Pixel count is \(pixelCount)")
    assert(pixelCount == 5425)
}

func part2() {
    let testPixelCount = enhanceAndCountTruePixels(image: testImage, enhancer: testEnhancer, count: 50)
    print("TEST: Pixel count is \(testPixelCount)")
    assert(testPixelCount == 3351)
    
    let pixelCount = enhanceAndCountTruePixels(image: image, enhancer: enhancer, count: 50)
    print("Pixel count is \(pixelCount)")
    assert(pixelCount == 14052)
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

