//
//  main.swift
//  day24
//
//  Created by Karsten Huneycutt on 2021-12-24.
//

import Foundation

let testProgram = try readProgram(readFile("file:///Users/kph/Stuff/aoc2021/day24/test-input.txt"))
let monadProgram = try readProgram(readFile("file:///Users/kph/Stuff/aoc2021/day24/input.txt"))

testALU()
//try evaluateSymbolic(monad: monadProgram)
part1()
part2()
try cheat()

typealias Program = [ALU.Instruction]
struct ALU {
    enum Register: String {
        case w = "w"
        case x = "x"
        case y = "y"
        case z = "z"
        case ic = "ic"
    }
    
    enum Instruction {
        enum Operand {
            case Register(Register)
            case Number(Int)
        }
        case Input(Register)
        case Add(Register, Operand)
        case Multiply(Register, Operand)
        case Divide(Register, Operand)
        case Modulo(Register, Operand)
        case Equals(Register, Operand)
    }

    func execute(program: Program, input: [Int]) -> Registers {
        var state = Registers()
        for instruction in program {
            switch (instruction) {
            case let .Input(register):
                let ic = readRegister(.ic, registers: state)
                state = writeRegister(register, value: input[ic], registers: state)
                state = writeRegister(.ic, value: ic+1, registers: state)
            case let .Add(register, operand):
                state = twoOperandInstruction(register: register, operand: operand, state: state, operate: +)
            case let .Multiply(register, operand):
                state = twoOperandInstruction(register: register, operand: operand, state: state, operate: *)
            case let .Divide(register, operand):
                state = twoOperandInstruction(register: register, operand: operand, state: state, operate: /)
            case let .Modulo(register, operand):
                state = twoOperandInstruction(register: register, operand: operand, state: state, operate: %)
            case let .Equals(register, operand):
                state = twoOperandInstruction(register: register, operand: operand, state: state, operate: { $0 == $1 ? 1 : 0 })
            }
        }
        return state
    }
        
    typealias Registers = [Register:Int]
    private func readRegister(_ register: Register, registers: Registers) -> Int {
        registers[register, default: 0]
    }
    
    private func writeRegister(_ register: Register, value: Int, registers: Registers) -> Registers {
        var state = registers
        state[register] = value
        return state
    }
    
    private func twoOperandInstruction(register: Register, operand: Instruction.Operand, state: Registers,
                                       operate: (Int, Int) -> Int) -> Registers
    {
        let lhs = readRegister(register, registers: state)
        let rhs: Int
        switch (operand) {
        case let .Number(number):
            rhs = number
        case let .Register(register):
            rhs = readRegister(register, registers: state)
        }
        let result = operate(lhs, rhs)
        return writeRegister(register, value: result, registers: state)
    }
}

struct SymbolicALU {
    func execute(program: Program, input: [Value]) throws -> Registers {
        var state = Registers()
        
        for instruction in program {
            switch (instruction) {
            case let .Input(register):
                guard case let .Numeric(ic) = readRegister(.ic, registers: state) else { throw ALUError.InvalidStateError }
                state = writeRegister(register, value: input[ic], registers: state)
                state = writeRegister(.ic, value: .Numeric(ic+1), registers: state)
                
            case let .Add(register, operand):
                state = try twoOperandInstruction(register: register, operand: operand, state: state) {
                    switch ($0, $1) {
                    case let (.Numeric(lhs), .Numeric(rhs)):
                        return .Numeric(lhs + rhs)
                    case let (.Numeric(lhs), .Symbolic(rhs)):
                        if (lhs == 0) {
                            return .Symbolic(rhs)
                        } else {
                            return .Symbolic("(\(String(lhs))+\(rhs))")
                        }
                    case let (.Symbolic(lhs), .Numeric(rhs)):
                        if (rhs == 0) {
                            return .Symbolic(lhs)
                        } else {
                            return .Symbolic("(\(lhs)+\(String(rhs)))")
                        }
                    case let (.Symbolic(lhs), .Symbolic(rhs)):
                        return .Symbolic("(\(lhs)+\(rhs))")
                    }
                }
                
            case let .Multiply(register, operand):
                state = try twoOperandInstruction(register: register, operand: operand, state: state) {
                    switch ($0, $1) {
                    case let (.Numeric(lhs), .Numeric(rhs)):
                        return .Numeric(lhs + rhs)
                    case let (.Numeric(lhs), .Symbolic(rhs)):
                        if (lhs == 0) {
                            return .Numeric(0)
                        } else if (lhs == 1) {
                            return .Symbolic(rhs)
                        } else {
                            return .Symbolic("\(String(lhs))*\(rhs)")
                        }
                    case let (.Symbolic(lhs), .Numeric(rhs)):
                        if (rhs == 0) {
                            return .Numeric(0)
                        } else if (rhs == 1) {
                            return .Symbolic(lhs)
                        } else {
                            return .Symbolic("\(lhs)*\(String(rhs))")
                        }
                    case let (.Symbolic(lhs), .Symbolic(rhs)):
                        return .Symbolic("\(lhs)*\(rhs)")
                    }
                }

            case let .Divide(register, operand):
                state = try twoOperandInstruction(register: register, operand: operand, state: state) {
                    switch ($0, $1) {
                    case let (.Numeric(lhs), .Numeric(rhs)):
                        return .Numeric(lhs / rhs)
                    case let (.Numeric(lhs), .Symbolic(rhs)):
                        if (lhs == 0) {
                            return .Numeric(0)
                        } else {
                            return .Symbolic("\(String(lhs))/\(rhs)")
                        }
                    case let (.Symbolic(lhs), .Numeric(rhs)):
                        if (rhs == 0) {
                            throw ALUError.DivideByZeroError
                        } else if (rhs == 1) {
                            return .Symbolic(lhs)
                        } else {
                            return .Symbolic("\(lhs)/\(String(rhs))")
                        }
                    case let (.Symbolic(lhs), .Symbolic(rhs)):
                        return .Symbolic("\(lhs)/\(rhs)")
                    }
                }
                
            case let .Modulo(register, operand):
                state = try twoOperandInstruction(register: register, operand: operand, state: state) {
                    switch ($0, $1) {
                    case let (.Numeric(lhs), .Numeric(rhs)):
                        return .Numeric(lhs % rhs)
                    case let (.Numeric(lhs), .Symbolic(rhs)):
                        if (lhs == 0) {
                            return .Numeric(0)
                        } else {
                            return .Symbolic("\(String(lhs))%\(rhs)")
                        }
                    case let (.Symbolic(lhs), .Numeric(rhs)):
                        if (rhs == 0) {
                            throw ALUError.DivideByZeroError
                        } else if (rhs == 1) {
                            return .Symbolic(lhs)
                       } else {
                            return .Symbolic("\(lhs)%\(String(rhs))")
                        }
                    case let (.Symbolic(lhs), .Symbolic(rhs)):
                        return .Symbolic("\(lhs)%\(rhs)")
                    }
                }
                
            case let .Equals(register, operand):
                state = try twoOperandInstruction(register: register, operand: operand, state: state) {
                    switch ($0, $1) {
                    case let (.Numeric(lhs), .Numeric(rhs)):
                        return .Numeric(lhs == rhs ? 1 : 0)
                    case let (.Numeric(lhs), .Symbolic(rhs)):
                        return .Symbolic("(\(String(lhs)) == \(rhs) ? 1:0)")
                    case let (.Symbolic(lhs), .Numeric(rhs)):
                        return .Symbolic("(\(lhs) == \(String(rhs)) ? 1:0)")
                    case let (.Symbolic(lhs), .Symbolic(rhs)):
                        return .Symbolic("(\(lhs) == \(rhs) ? 1:0)")
                    }
                }
            }
        }
        return state
    }
    
    enum Value : Equatable {
        case Numeric(Int)
        case Symbolic(String)
    }
    typealias Registers = [ALU.Register:Value]
    private func readRegister(_ register: ALU.Register, registers: Registers) -> Value {
        registers[register, default: .Numeric(0)]
    }
    
    private func writeRegister(_ register: ALU.Register, value: Value, registers: Registers) -> Registers {
        var state = registers
        state[register] = value
        return state
    }
    
    private func twoOperandInstruction(register: ALU.Register, operand: ALU.Instruction.Operand, state: Registers,
                                       operate: (Value, Value) throws -> Value) throws -> Registers
    {
        let lhs = readRegister(register, registers: state)
        let rhs: Value
        switch (operand) {
        case let .Number(number):
            rhs =  .Numeric(number)
        case let .Register(register):
            rhs = readRegister(register, registers: state)
        }
        let result = try operate(lhs, rhs)
        return writeRegister(register, value: result, registers: state)
    }

}

enum ALUError : Error {
    case ParseError
    case InvalidStateError
    case DivideByZeroError
}

func readProgram(_ data: [String]) throws -> Program {
    return try data.map { line in
        var parts = line.components(separatedBy: .whitespaces)
        let instruction = parts.removeFirst()
        if (instruction == "inp") {
            let register = ALU.Register.init(rawValue: parts.removeFirst())!
            return ALU.Instruction.Input(register)
        } else {
            let register = ALU.Register.init(rawValue: parts.removeFirst())!
            
            let second = parts.removeFirst()
            let operand: ALU.Instruction.Operand
            if let int = Int(second) {
                operand = ALU.Instruction.Operand.Number(int)
            } else {
                operand = ALU.Instruction.Operand.Register(ALU.Register.init(rawValue: second)!)
            }
            
            switch (instruction) {
            case "add":
                return ALU.Instruction.Add(register, operand)
            case "mul":
                return ALU.Instruction.Multiply(register, operand)
            case "div":
                return ALU.Instruction.Divide(register, operand)
            case "mod":
                return ALU.Instruction.Modulo(register, operand)
            case "eql":
                return ALU.Instruction.Equals(register, operand)
            default:
                throw ALUError.ParseError
            }
        }
    }
}

func validNumber(_ number: Int) -> Bool {
    !String(number).contains("0")
}

func tryNumber(_ number: Int, alu: ALU, monad: Program) -> Bool {
    let input = Array(String(number)).map { Int(String($0))! }
    let result = alu.execute(program: monad, input: input)
    return result[.z] == 0
}

func evaluateSymbolic(monad: Program) throws {
    let input = (0..<14).map { SymbolicALU.Value.Symbolic("d[\($0)]") }
    let result = try SymbolicALU().execute(program: monad, input: input)
    if case let .Symbolic(expression) = result[.z] {
        print("func monad(_ d: [Int]) -> Int {")
        print(expression)
        print("}")
    }
}

func acceptedNumbers(alu: ALU, monad: Program) -> [Int] {
    let results = (1..<9).parallelMap { digit -> [Int] in
        let lower = Int((1...14).map { _ in String(digit) }.joined())!
        let upper = Int((1...14).map { _ in String(digit+1) }.joined())!
        var numbers: [Int] = []
        for number in lower...upper {
            if (validNumber(number) && tryNumber(number, alu: alu, monad: monad)) {
                numbers.append(number)
            }
        }
        return numbers
    }.compactMap { $0 }
    return results.flatMap { $0 }
}


func testALU() {
    let alu = ALU()

    var result = alu.execute(program: testProgram, input: [0])
    assert(result[.z] == 0)
    assert(result[.y] == 0)
    assert(result[.x] == 0)
    assert(result[.w] == 0)
    
    result = alu.execute(program: testProgram, input: [1])
    assert(result[.z] == 1)
    assert(result[.y] == 0)
    assert(result[.x] == 0)
    assert(result[.w] == 0)

    result = alu.execute(program: testProgram, input: [5])
    assert(result[.z] == 1)
    assert(result[.y] == 0)
    assert(result[.x] == 1)
    assert(result[.w] == 0)

    result = alu.execute(program: testProgram, input: [7])
    assert(result[.z] == 1)
    assert(result[.y] == 1)
    assert(result[.x] == 1)
    assert(result[.w] == 0)
    
    result = alu.execute(program: testProgram, input: [15])
    assert(result[.z] == 1)
    assert(result[.y] == 1)
    assert(result[.x] == 1)
    assert(result[.w] == 1)
}

func part1() {
    
//    let numbers = acceptedNumbers(alu: ALU(), monad: monadProgram)
//    print("Largest number is \(numbers.max()!), smallest is \(numbers.min()!)")
//    //assert(largestNumber ==)
}

func part2() {
    
}

extension ALU.Instruction {
    func operand() throws -> Operand {
        switch (self) {
        case let .Input(_):
            throw ALUError.InvalidStateError
        case let .Add(_, operand):
            return operand
        case let .Multiply(_, operand):
            return operand
        case let .Divide(_, operand):
            return operand
        case let .Modulo(_, operand):
            return operand
        case let .Equals(_, operand):
            return operand
        }

    }
}


func cheat() throws {
    var p = 99999999999999
    var q = 11111111111111
    
    var stack: [(Int,Int)] = []
    for i in 0..<14 {
        guard case let .Number(a) = try monadProgram[18*i + 5].operand(),
              case let .Number(b) = try monadProgram[18*i + 15].operand() else {
                  throw ALUError.InvalidStateError
              }

        if (a > 0) {
            stack.append((i, b))
        } else {
            let (j, b) = stack.removeLast()
                        
            p -= abs( (a + b)*10 ** (13 - [i,j][ a > -b ? 1 : 0]) )
            q += abs( (a + b)*10 ** (13 - [i,j][ a < -b ? 1 : 0]) )
        }
    }
    
    print("Min \(q), max \(p)")
}

// UTILITY
func readFile(_ file: String) throws -> [String] {
    let url = URL(string: file)!
    return try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
}

extension Collection {
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)

        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }

        return res.map({ $0! })
    }
}

precedencegroup ExponentialPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : ExponentialPrecedence
extension Int {
    static func **(lhs: Int, rhs: Int) -> Int {
        Int(pow(Double(lhs), Double(rhs)))
    }
}
