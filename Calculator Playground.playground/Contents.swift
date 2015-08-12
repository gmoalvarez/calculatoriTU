//: Playground - noun: a place where people can play

import UIKit
import Foundation

//var str = "2341.222"
//
//
//str.rangeOfString(".")
//NSNumberFormatter().numberFromString("12.12.1"!)?.doubleValue
//
//
//enum Op {
//    case Operand(Double)
//    case UnaryOperation(String,Double -> Double)
//    case BinaryOperation(String, (Double,Double) -> Double)
//}
//
//var opStack = [Op]()
//
//func evaluate(ops: [Op]) -> (result: Double?,remainingOps: [Op]) {
//    if !ops.isEmpty {
//        let op = ops.removeLast()//*I thought ops was immutable?
//        
//    }
//    return (nil,ops)
//}

class Display {
    var text:String?
}
var display = Display()
display.text = "2468"

let displayNumber = "12345"
let digitCount = count(displayNumber)
let substringIndex = digitCount - 1
//displayNumber.substringToIndex(advance(displayNumber.startIndex, substringIndex))
//display.text?.startIndex
//display.text!.substringToIndex(advance(display.text!.startIndex,count(display.text!)-1 ))
advance(display.text!.startIndex, count(display.text!))
//display.text = displayNumber.substringToIndex(advance(displayNumber.startIndex, count(displayNumber))
dropFirst(display.text!)

NSNumberFormatter().numberFromString(display.text!)?.doubleValue

display.text!.rangeOfString("")

let number:Double = 6
let numberAsInteger = Int(number)
(number - Double(numberAsInteger)) != 0



class CalculatorBrain {
    
    var description: String{
        get {
            var (expression,remainingOps) = ("",opStack)
            remainingOps.count
            while remainingOps.count > 0 {
                remainingOps.count
                var current: String?
                (current,remainingOps) = description(remainingOps)
                expression = (expression == "") ? (current!) : (current!  + "," + expression)//this is equivalent to below
//                    if expression == "" {
//                        expression = current!
//                    } else {
//                        expression =   current!  + "," + expression
//                    }
            }
            return expression
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
        
        var description: String {
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
    
    func clearStack() {
        opStack.removeAll()
    }
}

var brain = CalculatorBrain()

//brain.pushOperand(4)
//brain.pushOperand(7)
//brain.performOperation("+")
//brain.pushOperand(10)
//brain.performOperation("−")
//brain.description
//brain.clearStack()
//brain.pushOperand(10)
//brain.performOperation("√")
//brain.pushOperand(3)
//brain.performOperation("+")
//brain.description
//brain.clearStack()
//brain.pushOperand(3)
//brain.pushOperand(5)
//brain.performOperation("+")
//brain.performOperation("√")
//brain.description
//brain.clearStack()
//brain.pushOperand(3)
//brain.pushOperand(5)
//brain.pushOperand(4)
//brain.performOperation("+")
//brain.performOperation("+")
//brain.description
//brain.clearStack()
//brain.pushOperand(3)
//brain.pushOperand(5)
//brain.performOperation("√")
//brain.performOperation("+")
//brain.performOperation("√")
//brain.pushOperand(6)
//brain.performOperation("÷")
//brain.description
//brain.clearStack()
//brain.pushOperand(3)
//brain.performOperation("+")
//brain.description
//brain.clearStack()
//brain.pushOperand(3)
//brain.pushOperand(5)
//brain.performOperation("√")
//brain.performOperation("+")
//brain.performOperation("√")
//brain.pushOperand(6)
//brain.performOperation("÷")
//brain.description
brain.clearStack()
brain.pushOperand(3)

brain.pushOperand(5)

brain.performOperation("+")

brain.performOperation("√")

brain.pushPi()

brain.performOperation("cos")

brain.description

"\(brain.opStack)"




