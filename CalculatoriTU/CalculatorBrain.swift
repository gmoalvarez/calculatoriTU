//
//  CalculatorBrain.swift
//  CalculatoriTU
//
//  Created by Guillermo on 4/29/15.
//  Copyright (c) 2015 guillermo. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var description: String{ //This is kind of like toString in Java
        get {
            if let desc = description(opStack).result {
                return desc
            } else {
                return ""
            }
        }
    }
    
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)",remainingOps)
            case .Variable(let symbol):
                    return (symbol,remainingOps)
            case .UnaryOperation(let symbol, let operation):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))",operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, let operation):
                let op1Evaluation = description(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        let expression = "\(operand2) \(symbol) \(operand1)"
                        return (expression,op2Evaluation.remainingOps)
                    }
                }
            case .Pi(_):
                return ("π",remainingOps)
            }
        }
        return ("?",ops)
    }


    private enum Op: Printable {
        case Operand(Double)  //In the parenthesis is the associated value
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double)
        case Pi(Double)
        
        var description: String {//this is a computed property
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Pi(_):
                    return "\(M_PI)"
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×",*))
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+",+)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["^"] = Op.BinaryOperation("^") { pow($1,$0) }
        knownOps["√"] = Op.UnaryOperation("√",sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin") { sin($0) }
        knownOps["cos"] = Op.UnaryOperation("cos") { cos($0) }
        knownOps["tan"] = Op.UnaryOperation("tan") { tan($0) }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { //guaranteed to be a PropertyList
        get {
            return opStack.map{ $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    } else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?,remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand,remainingOps)
            case .Variable(let symbol):
                if let currentVariable = variableValues[symbol] {
                    return (currentVariable,remainingOps)
                } else {
                    return (nil,remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2),op2Evaluation.remainingOps)
                    }
                }
            case .Pi(_):
                return (M_PI,remainingOps)
            }
        }
        return (nil,ops)
    }
    
    private func evaluateAndReportErrors(ops: [Op]) -> (result: Double?,remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand,remainingOps)
            case .Variable(let symbol):
                if let currentVariable = variableValues[symbol] {
                    return (currentVariable,remainingOps)
                } else {
                    return (nil,remainingOps)
                }
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand),operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1,operand2),op2Evaluation.remainingOps)
                    }
                }
            case .Pi(_):
                return (M_PI,remainingOps)
            }
        }
        return (nil,ops)
    }

    func evaluateAndReportErrors() -> Double? {
        let (result,remainder) = evaluate(opStack) //this is another way of calling a function that returns a tuple instead of dot notation
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func evaluate() -> Double? {
        let (result,remainder) = evaluate(opStack) //this is another way of calling a function that returns a tuple instead of dot notation
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand)) //push enum type Op case Operand
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func pushPi() -> Double? {
        opStack.append(Op.Pi(M_PI))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func setVariable(variable: String, toValue: Double) -> Double?{
        variableValues[variable] = toValue
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll()
        variableValues.removeValueForKey("M")
    }
}