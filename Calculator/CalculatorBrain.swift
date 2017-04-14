//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gloria Martinez on 3/31/17.
//  Copyright © 2017 Gloria Martinez. All rights reserved.
//

import Foundation

struct CalculatorBrain{
    
    mutating func addUnaryOperation( named symbol: String, _ operation: @escaping (Double) -> Double ) {
        operations[symbol] = Operation.unaryOperation(operation)
    }
    
    private var accumulator: Double?
    private var internalProgram = [AnyObject]()
    var description: String = ""
    private var isPartialResult: Bool = true
    var variableValues: Dictionary<String, Double>=[:]
    var descriptionArray = [String]()
    private var isUndoActive: Bool = false
    
    mutating func setOperand(variableName: String){
        result = variableValues[variableName]
        descriptionArray.append(variableName)
        internalProgram.append(variableName as AnyObject)
    }
    
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionArray.append(String(operand))
        internalProgram.append(operand as AnyObject)
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
                }
            case .binaryOperation(let function):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
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
        descriptionArray.removeAll()
        accumulator = 0.0
        internalProgram.removeAll()
        variableValues.removeAll()
    }
    
    mutating func describeCalculation(_ input: String) -> String {
        if input == "√" && isPartialResult == false{
            loopThroughDescriptionArray()
            if description.contains("M")
            {
                description = input + "(" + description + ")"
            }
            else
            {
                description = input + "(" + description + ")="
            }
            
            return description
        }
        else if input == "√" && isPartialResult == true{
            description = ""
            for index in 0..<descriptionArray.count-1
            {
                description += descriptionArray[index]
            }
            description =  description + input + "(" + descriptionArray[descriptionArray.count-1] + ")"
            return description
        }
            
        else if input == "sin" || input == "cos" || input == "tan"{
            let number = descriptionArray[descriptionArray.count-1]
            descriptionArray.remove(at: descriptionArray.count-1)
            descriptionArray.append(input)
            descriptionArray.append("(")
            descriptionArray.append(number)
            descriptionArray.append(")")
            loopThroughDescriptionArray()
            return description + "..."
        }
            
        else if isUndoActive
        {
            var middleOfDescriptionArray = 0
            if descriptionArray.count%2 == 0 || descriptionArray.count == 3
            {
                middleOfDescriptionArray = descriptionArray.count/2
            }
            else{
                middleOfDescriptionArray = descriptionArray.count/2 + 1
            }
            let endOfDescriptionArray = descriptionArray.count
            let numberOfElementsToDelete = endOfDescriptionArray - middleOfDescriptionArray
            var i = 1
            while i <= numberOfElementsToDelete
            {
                descriptionArray.remove(at: descriptionArray.count-1)
                i += 1
            }
            descriptionArray.append(input)
            loopThroughDescriptionArray()
            isUndoActive = false
            return description + "..."
        }
            
        else if descriptionArray.contains("M") && input != "＝"{
            descriptionArray.append(input)
            description = description + input
            return description + "..."
        }
        else if descriptionArray.count == 2 && descriptionArray[1] == "x" && input == "π"
        {
            let number = Double(descriptionArray[0])
            accumulator = number! + Double.pi
            return description + "="
        }
        else if descriptionArray.count == 2 && descriptionArray[1] == "+" {
            let number = Double(descriptionArray[0])
            accumulator = number! + number!
            description = "\(number!)" + "+" + "\(number!)"
            return description + "="
        }
            
        else if description.contains("=") && description.contains("√") && !["+", "-", "x", "÷"].contains(descriptionArray[descriptionArray.count-2]) && !description.contains("M"){
            descriptionArray = [descriptionArray[descriptionArray.count-1]]
            descriptionArray.append(input)
            loopThroughDescriptionArray()
            return description + "..."
        }
        else if isPartialResult == true
        {
            descriptionArray.append(input)
            loopThroughDescriptionArray()
            return description + "..."
        }
            
        else{
            if !description.contains("(") || descriptionArray.contains("sin") || descriptionArray.contains("cos") || descriptionArray.contains("tan")
            {
                loopThroughDescriptionArray()
            }
            if !description.contains("M")
            {
                return description + "="
            }
            if description.contains("M") && description.contains("(")
            {
                description = description + descriptionArray[descriptionArray.count-1]
            }
            return description
        }
    }
    
    mutating func loopThroughDescriptionArray(){
        description = ""
        for index in descriptionArray
        {
            description += index
        }
    }
    
    mutating func undoDescription() -> String
    {
        isUndoActive = true
        description = description.substring(to: description.index(before: description.endIndex))
        return description
    }
    
    
    
    mutating func undo(){
        if !internalProgram.isEmpty
        {
            internalProgram.removeLast()
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
            pendingBinaryOperation = nil
            accumulator = 0.0
            internalProgram.removeAll()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand)
                    } else if let variableName = op as? String {
                        if variableValues[variableName] != nil{
                            setOperand(variableName: variableName)
                        }else if let operation = op as? String{
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    
    var result: Double? {
        get{
            return accumulator
        }
        set{
            if newValue != nil{
                accumulator = newValue!
            }
            else{
                accumulator = 0.0
            }
        }
    }
    
}
