//
//  main.swift
//  day21
//
//  Created by Karsten Huneycutt on 2021-12-21.
//

import Foundation
import Algorithms

// no need to read the two numbers in
let testPlayers = (4,8)
let players = (7,1)

part1()
part2()

protocol Die {
    var rollCount: Int { get }
    mutating func roll() -> Int
}

struct DeterministicDie : Die {
    let maxRoll: Int
    var rollCount = 0
    var nextRoll = 1
    
    mutating func roll() -> Int {
        rollCount += 1

        let result = nextRoll
        nextRoll += 1
        if (nextRoll > maxRoll) {
            nextRoll = 1
        }
        
        return result
    }
}

struct Player : Hashable {
    let position, score: Int
    init(position: Int, score: Int = 0) {
        self.position = position
        self.score = score
        //self.rollSequence = rollSequence
    }
    
    func move(spaces: Int) -> Player {
        var newPosition = self.position + spaces
        if (newPosition > 10) {
            newPosition = (newPosition % 10) == 0 ? 10 : (newPosition % 10)
        }
        return Player(position: newPosition, score: score+newPosition)
    }
}

struct DiracDiceGame {
    var players: [Player]
    var die: Die
    let winningScore: Int
    let maxPosition = 10
    
    init(players: [Int], die: Die, winningScore: Int) {
        self.players = players.map { Player(position: $0)}
        self.die = die
        self.winningScore = winningScore
    }
    
    mutating func play() {
        while (players.first { $0.score >= winningScore } == nil) {
            let currentPlayer = players.removeFirst()
            let move = [ die.roll(), die.roll(), die.roll() ].reduce(0, +)
            
            let newPlayer = currentPlayer.move(spaces: move)
            players.append(newPlayer)
        }
    }
}

extension DiracDiceGame {
    func part1Value() -> Int {
        return die.rollCount * players.first { $0.score < winningScore }!.score
    }
}

func playBasicGame(player1: Int, player2: Int) -> Int {
    var game = DiracDiceGame(players: [ player1, player2 ],
                             die: DeterministicDie(maxRoll: 100), winningScore: 1000)
    game.play()
    return game.part1Value()
}

struct PlayerPair : Hashable {
    let player1, player2: Player
    let turnCount: Int
}

func calculateMaxUniverses(player1: Int, player2: Int, winningScore: Int = 21) -> Int {
    var ongoingGames = [PlayerPair:Int]()
    var p1Won = 0
    var p2Won = 0
    
    let movePossibilities = [
        3: 1,
        4: 3,
        5: 6,
        6: 7,
        7: 6,
        8: 3,
        9: 1
    ]
    
    ongoingGames[PlayerPair(player1: Player(position: player1), player2: Player(position: player2), turnCount: 1)] = 1
    
    while (!ongoingGames.isEmpty) {
        let newGames = ongoingGames.flatMap { (pair, currentGames) -> [(PlayerPair, Int)] in
            let turnCount = (pair.turnCount) % 2
            return [Int](3...9).compactMap { roll -> (PlayerPair, Int)? in
                let newPair: PlayerPair
                let newGames = currentGames * movePossibilities[roll]!
                if (turnCount == 0) {
                    let newP2 = pair.player2.move(spaces: roll)
                    if (newP2.score >= winningScore) {
                        p2Won += newGames
                        return nil
                    }
                    newPair = PlayerPair(player1: pair.player1, player2: newP2, turnCount: turnCount+1)
                } else {
                    let newP1 = pair.player1.move(spaces: roll)
                    if (newP1.score >= winningScore) {
                        p1Won += newGames
                        return nil
                    }
                    newPair = PlayerPair(player1: newP1, player2: pair.player2, turnCount: turnCount+1)
                }
                
                return (newPair, newGames)
            }
        }
        var newGamesHash = [PlayerPair:Int]()
        newGames.forEach { (pair, games) in newGamesHash[pair, default:0] += games }
        ongoingGames = newGamesHash
    }
    
    print("P1 won \(p1Won) P2 won \(p2Won)")
    return p1Won > p2Won ? p1Won : p2Won
}

func part1() {
    let testResult = playBasicGame(player1: testPlayers.0, player2: testPlayers.1)
    print("TEST: result is \(testResult)")
    assert(testResult == 739785)
    
    let result = playBasicGame(player1: players.0, player2: players.1)
    print("Result is \(result)")
    assert(result == 684495)
}


func part2() {
    let testResult = calculateMaxUniverses(player1: testPlayers.0, player2: testPlayers.1)
    print("TEST: max universes is \(testResult)")
    assert(testResult == 444356092776315)

    let result = calculateMaxUniverses(player1: players.0, player2: players.1)
    print("Max universes is \(result)")
    assert(result == 152587196649184)

}

extension Array where Element : Hashable {
    func countUnique() -> [Element:Int] {
        return reduce(into: [Element:Int]()) { $0[$1, default: 0] += 1 }
    }
}
