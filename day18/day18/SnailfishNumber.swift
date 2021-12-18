//
//  SnailfishNumber.swift
//  day18
//
//  Created by Karsten Huneycutt on 2021-12-18.
//

import Foundation

class SnailfishNumber : Hashable {
    indirect enum Value : Hashable {
        case number(Int)
        case pair(SnailfishNumber, SnailfishNumber)
    }
    
    let value: Value
    
    convenience init(_ number: Int) {
        self.init(.number(number))
    }
    
    convenience init(_ left: SnailfishNumber, _ right: SnailfishNumber) {
        self.init(.pair(left, right))
    }
    
    var depth: Int {
        get {
            switch (value) {
            case .number:
                return 1
            case let .pair(left, right):
                
                return [ left.depth+1, right.depth+1 ].max()!
            }
        }
    }
    
    var magnitude: Int {
        get {
            switch (value) {
            case let .number(value):
                return value
            case let .pair(left, right):
                return 3*left.magnitude + 2*right.magnitude
            }
        }
    }
    
    static func +(left: SnailfishNumber, right: SnailfishNumber) -> SnailfishNumber {
        return SnailfishNumber(left, right)
    }
    
    static func == (lhs: SnailfishNumber, rhs: SnailfishNumber) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    func reduce() throws -> SnailfishNumber {
        if let exploded = try explode(topMost: self, depth: 4) {
            return try exploded.reduce()
        } else if let split = try split() {
            return try split.reduce()
        } else {
            return self
        }
    }
    
    init(_ value: Value) {
        self.value = value
    }

    private func explode(topMost: SnailfishNumber, depth: Int) throws -> SnailfishNumber? {
        switch (value) {
        case .number:
            return nil
        case let .pair(left, right):
            if (depth == 0) {
                // to explode, we need to make a list of the number nodes
                // so that we can find the left and right neighbors.
                // numberNodes does a depth first traversal.
                let numberNodes = SnailfishNumber.numberNodes(topMost)
                let leftIdx = numberNodes.firstIndex(of: left)!
                let rightIdx = numberNodes.firstIndex(of: right)!
                
                var subs: [SnailfishNumber: SnailfishNumber] = [:]
                subs[self] = SnailfishNumber(0)
                
                // if we have a left neighbor, add this left number to it and
                // add it to the subs
                if (leftIdx > 0) {
                    let leftSub = numberNodes[leftIdx-1]
                    let newLeft = try SnailfishNumber(leftSub.asNumber() + left.asNumber())
                    subs[leftSub] = newLeft
                }
                
                // same with the right
                if (rightIdx < numberNodes.count-1) {
                    let rightSub = numberNodes[rightIdx+1]
                    let newRight = try SnailfishNumber(rightSub.asNumber() + right.asNumber())
                    subs[rightSub] = newRight
                }
                
                // now rebuild from the top down, performing substitutions as
                // appropriate
                return SnailfishNumber.reconstruct(topMost: topMost, substitutions: subs)
            }
            
            // if the two depths are equal and they both need exploding,
            // explode the left first.
            if (left.depth == right.depth && left.depth >= depth) {
                return try left.explode(topMost: topMost, depth: depth-1)
            }
            
            // otherwise, explode the one that needs exploding.
            let maxChild = [ left, right ].sorted { $0.depth < $1.depth }.last!
            if (maxChild.depth >= depth) {
                return try maxChild.explode(topMost: topMost, depth: depth-1)
            } else {
                return nil
            }
        }
    }
            
    private func split() throws -> SnailfishNumber? {
        switch (value) {
        case let .pair(left, right):
            if let split = try left.split() {
                return split + right
            } else if let split = try right.split() {
                return left + split
            } else {
                return nil
            }
        case let .number(value):
            if (value >= 10) {
                let left = value / 2
                let right = (value % 2) == 0 ? left : left+1
            
                return SnailfishNumber(left) + SnailfishNumber(right)
            }
            
            return nil
        }
    }
}

extension SnailfishNumber {
    private static func numberNodes(_ topMost: SnailfishNumber, nodes: [SnailfishNumber] = []) -> [SnailfishNumber] {
        switch(topMost.value) {
        case .number:
            return nodes + [ topMost ]
        case let .pair(nl, nr):
            let left = numberNodes(nl, nodes: nodes)
            let right = numberNodes(nr, nodes: left)
            return right
        }
    }
    
    private static func reconstruct(topMost: SnailfishNumber,
                                    substitutions: [SnailfishNumber: SnailfishNumber]) -> SnailfishNumber {
        switch(topMost.value) {
        case .number:
            if let sub = substitutions[topMost] {
                return sub
            } else {
                return topMost
            }
        case let .pair(left, right):
            let newLeft, newRight: SnailfishNumber
            if let sub = substitutions[left] {
                newLeft = sub
            } else {
                newLeft = reconstruct(topMost: left, substitutions: substitutions)
            }
            if let sub = substitutions[right] {
                newRight = sub
            } else {
                newRight = reconstruct(topMost: right, substitutions: substitutions)
            }
            
            return newLeft + newRight
        }
    }
    
    private func asNumber() throws -> Int {
        switch (value) {
        case let .number(value):
            return value
        case .pair:
            throw SnailfishNumberError.BadFormatError
        }
    }

}
