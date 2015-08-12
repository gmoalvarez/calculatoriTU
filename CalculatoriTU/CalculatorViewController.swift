//
//  ViewController.swift
//  CalculatoriTU
//
//  Created by Guillermo on 4/25/15.
//  Copyright (c) 2015 guillermo. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navcon = destination as? UINavigationController {
            destination = navcon.visibleViewController
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                    case "Show Graph":
                        gvc.program = brain.program
                        gvc.title = brain.description == "" ? "Graph" : brain.description.componentsSeparatedByString(", ").last
                    
                    //                gvc.property1 = ...
                    //                gvc.callMethodToSetItUp(...)
                    default:
                        break
                }
            }

        }
            }
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var historyLabel: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    var numberIsPositive = true
    private var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                display.text! += digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
    }

    @IBAction func deleteDigit(sender: UIButton) {
        if let displayNumber = display.text {
            let digitCount = count(displayNumber)
            if digitCount > 1 {
                let substringIndex = digitCount - 1
                display.text = dropLast(displayNumber)
            } else {
                display.text = "0"
                willEnterNewNumber()
            }
        } else {
            clearDisplay(self)
        }
    }
    
    @IBAction func changeSign(sender: AnyObject) {
        if let displayNumber = display.text {
            if numberIsPositive {
                display.text = "-\(displayNumber)"
                numberIsPositive = false
            } else {
                let digitCount = count(displayNumber)
                display.text = dropFirst(displayNumber)
            }
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if let operation = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                enter()
            }
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
            updateHistoryLabel(displayValue)
        }
    }

    @IBAction func enter() {
        if let disp = displayValue {
            if let result = brain.pushOperand(disp) {
                displayValue = result
            } else {
                displayValue = nil
            }
            willEnterNewNumber()
        } else {
            display.text = "ERROR"
        }
    }
    

    @IBAction func appendConstant(sender: UIButton) {
        if let disp = displayValue {
            if userIsInTheMiddleOfTypingANumber {
                brain.pushOperand(disp)
            }
            if let constant = sender.currentTitle {
                brain.pushPi()
                display.text = "π"
            }
        } else {
            clearDisplay(self)
        }
        willEnterNewNumber()
    }
    
    @IBAction func clearDisplay(sender: AnyObject) {
        brain.clear()
        historyLabel.text! = " "
        display.text! = " "
        willEnterNewNumber()
    }

    @IBAction func setMemory(sender: UIButton) {
        if let display = displayValue {
            let result = brain.setVariable("M",toValue: display)
            displayValue = result
        }
        updateHistoryLabel(displayValue)
        willEnterNewNumber()
    }
    
    @IBAction func getMemory(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        display.text = "M"
        brain.pushOperand("M")
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            if let currentValue = newValue {
                if hasDecimal(currentValue) {
                    display.text = String(format: "%.8f", currentValue)
                } else {
                    display.text = String(format: "%.0f", currentValue)
                }
            } else {
                display.text = " "
            }
            willEnterNewNumber()
        }
    }
    
    private func updateHistoryLabel(withResult: Double?) {
        if let result = withResult {
            historyLabel.text! += "\(brain.description) = \(result)\n"
        } else {
            historyLabel.text! += "\(brain.description)\n"
        }
    }
    
    private func hasDecimal(number: Double) -> Bool {
        let numberAsInteger = Int(number)
        return (number - Double(numberAsInteger)) != 0
    }
    
    private func willEnterNewNumber() {
        userIsInTheMiddleOfTypingANumber = false
        numberIsPositive = true
    }

}

