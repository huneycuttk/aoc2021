//
//  Parser.swift
//  day18
//
//  Created by Karsten Huneycutt on 2021-12-18.
//

import Foundation

func parseNumbers(_ data: [String]) throws -> [SnailfishNumber] {
    return try data.map(parseNumber(line:))
}

func parseNumber(line: String) throws -> SnailfishNumber {
    enum Token {
        case open
        case number(SnailfishNumber)
    }
    
    var stack: [Token] = [ ]
    for char in Array(line) {
        switch(char) {
        case "[":
            stack.append(.open)
        case ",":
            // do nothing
            break
        case "]":
            let right = stack.removeLast()
            let left = stack.removeLast()
            let open = stack.removeLast()
            
            if case .open = open, case .number(let leftNumber) = left, case .number(let rightNumber) = right {
                stack.append(.number(leftNumber + rightNumber))
            } else {
                throw SnailfishNumberError.ParseError
            }
        default:
            let value = Int(String(char))!
            stack.append(.number(SnailfishNumber(value)))
        }
        
    }
    
    let result = stack.removeLast()
    if (!stack.isEmpty) {
        throw SnailfishNumberError.LeftoverError
    }
    
    if case .number(let resultNumber) = result {
        return resultNumber
    }
    
    throw SnailfishNumberError.ParseError
}

