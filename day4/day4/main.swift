//
//  main.swift
//  day4
//
//  Created by Karsten Huneycutt on 2021-12-04.
//

import Foundation
let BOARD_SIZE = 5

let testData = """
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
""".split(separator: "\n")

let url = URL(string: "file:///Users/kph/Stuff/aoc2021/day4/input.txt")!
let data = try String(contentsOf: url).split(separator: "\n")

let (testMoves, testBoards) = try parseData(testData)
let (moves, boards) = try parseData(data)

let testScoreAnswer = 4512
let testScore = playGame(boards: testBoards, moves: testMoves, winnerNumber: 1)
print("TEST: Score \(testScore)")
guard testScore == testScoreAnswer else {
    print("INCORRECT ANSWER")
    exit(1)
}

let score = playGame(boards: boards, moves: moves, winnerNumber: 1)
print("Score: \(score)")

testBoards.forEach { $0.reset() }
boards.forEach { $0.reset() }

let testSquidGameScoreAnswer = 1924
let testSquidGameScore = playGame(boards: testBoards, moves: testMoves, winnerNumber: testBoards.count)
print("TEST: Squid Game Score \(testSquidGameScore)")
guard testSquidGameScore == testSquidGameScoreAnswer else {
    print("INCORRECT ANSWER")
    exit(1)
}

let squidGameScore = playGame(boards: boards, moves: moves, winnerNumber: boards.count)
print("Squid Game Score: \(squidGameScore)")


func parseData<S: StringProtocol>(_ data: [S]) throws -> ([Int], [BingoBoard]) {
    let moves = data[0].split(separator: ",").map { Int($0) ?? 0 }
    
    let boardCount = (data.count - 1)/BOARD_SIZE
    
    let boards = try [Int](0..<boardCount).map { idx -> BingoBoard in
        let beginIdx = idx*BOARD_SIZE+1
        let endIdx = beginIdx + BOARD_SIZE
        let numbers = data[beginIdx..<endIdx].map { $0 .split(separator: " ").map { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 } }
        return try BingoBoard(numbers: numbers)
    }
    
    return (moves, boards)
}

func playGame(boards: [BingoBoard], moves: [Int], winnerNumber: Int) -> Int {
    var moveIdx = -1
    var lastWinnerIdx = boards.endIndex
    var boardsInPlay: [BingoBoard] = boards
    let actualWinnerIdx = boards.endIndex - winnerNumber
    
    while moveIdx < moves.count-1 && lastWinnerIdx != actualWinnerIdx {
        moveIdx += 1
        lastWinnerIdx = boardsInPlay[0..<lastWinnerIdx].partition { $0.mark(moves[moveIdx]) && $0.winner() }
    }
    
    return boardsInPlay[lastWinnerIdx].score() * moves[moveIdx]
}

class BingoBoard {
    enum BingoBoardError : Error {
        case WrongSizeError
    }
    private var numbers: [[Int]]
    private var marked: [[Bool]]
    
    convenience init(numbers: [[Int]]) throws {
        try self.init(numbers: numbers, marked: BingoBoard.makeMarked())
    }
    
    init(numbers: [[Int]], marked: [[Bool]]) throws {
        self.numbers = numbers
        self.marked = marked
        if !(numbers.count == BOARD_SIZE && numbers.allSatisfy { $0.count == BOARD_SIZE }) {
            throw BingoBoardError.WrongSizeError
        }
    }
    
    func mark(_ number: Int) -> Bool {
        if let (row, col) = find(number) {
            marked[row][col] = true
            return true
        } else {
            return false
        }
    }
    
    func score() -> Int {
        return numbers.enumerated().reduce(0) { sum, pair in
            let (rowIdx, row) = pair
            return sum + row.enumerated().reduce(0) { rowSum, columnPair in
                let (columnIdx, number) = columnPair
                return marked[rowIdx][columnIdx] ? rowSum : rowSum+number
            }
        }
    }
    
    func reset() -> Void {
        self.marked = BingoBoard.makeMarked()
    }
    
    func winner() -> Bool {
        return marked.contains { row in row.allSatisfy { $0 } } ||
            [Int](0..<BOARD_SIZE).contains { idx in marked.allSatisfy { $0[idx] } }
    }
        
    private func find(_ number: Int) -> (Int, Int)? {
        if let row = numbers.firstIndex(where: { r in r.contains { $0 == number } }) {
            if let col = numbers[row].firstIndex(of: number) {
                return (row, col)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func makeMarked() -> [[Bool]] {
        return [[Bool]](repeating: [Bool](repeating: false, count: BOARD_SIZE), count: BOARD_SIZE)
    }
    
}

