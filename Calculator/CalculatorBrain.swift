//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gloria Martinez on 3/31/17.
//  Copyright © 2017 Gloria Martinez. All rights reserved.
//

import Foundation

struct CalculatorBrain{
    
    private var accumulator: Double?
    private var internalProgram = [AnyObject]()
    private var description: String = ""
    private var isPartialResult: Bool = true
    
//    func setOperand(variableName: String){
//        
//    }
//    
//    var variableValues: Dictionary<String, Double>
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        description += String(operand)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "ln" : Operation.unaryOperation({log2($0)}),
        "±": Operation.unaryOperation({ -$0 }),
        "x²": Operation.unaryOperation({ $0 * $0 }),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "−": Operation.binaryOperation({$0 - $1}),
        "+": Operation.binaryOperation({$0 + $1}),
        "＝": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String){
        internalProgram.append(symbol as AnyObject)
        if let operation  = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                isPartialResult = true
            case .unaryOperation(let function):
                if accumulator != nil{
                    accumulator = function(accumulator!)
                    isPartialResult = true
                }
            case .binaryOperation(let function):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    print("\(String(describing: accumulator))")
                    accumulator = nil
                    isPartialResult = true
                }
            case .equals:
                performPendingBinaryOperation()
                isPartialResult = false
            }
        }
    }
    
    mutating func performClear(){
        pendingBinaryOperation = nil
        description = ""
        accumulator = 0.0
        internalProgram.removeAll()
    }
    
    mutating func describeCalculation(_ input: String) -> String {
        if input == "√" {
            return input + "(" + description + ")"
        }
        else if isPartialResult == true
        {
            description = description + input
            return description + "..."
        }
        else{
            return description + "="
        }
    }
    
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil{
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            performClear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    
    var result: Double? {
        get{
            return accumulator
        }
    }

}
