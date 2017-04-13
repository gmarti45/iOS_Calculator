//
//  ViewController.swift
//  Calculator
//
//  Created by Gloria Martinez on 3/30/17.
//  Copyright © 2017 Gloria Martinez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.addUnaryOperation(named: "✅") { [weak weakSelf = self] in
            weakSelf?.display.textColor = UIColor.green
            return sqrt($0)}
    }
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil{
            brain.program = savedProgram!
            displayValue = brain.result!
        }
    }
    
    @IBAction func Undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping && !display.text!.isEmpty {
            display.text! = display.text!.substring(to: display.text!.index(before: display.text!.endIndex))
            if display!.text!.isEmpty
            {
                display!.text = " "
            }
        }
        else if !display.text!.isEmpty{
            brain.undo()
            brain.program = brain.program
            descriptionDisplay.text! = brain.undoDescription()
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.performClear()
        display!.text = "0"
        descriptionDisplay.text = " "
    }
    
    var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurrentlyInDisplay = display!.text!
            if (textCurrentlyInDisplay.contains(".") && digit == ".")
            {
                display!.text = textCurrentlyInDisplay            }
            else{
                display!.text = textCurrentlyInDisplay + digit
            }
        }else{
            display!.text = digit
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    var displayValue: Double{
        get{
            if display!.text!.contains(" ")
            {
                display!.text! = String(display!.text!.characters.dropFirst())
            }
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            descriptionDisplay!.text = brain.describeCalculation(mathematicalSymbol)
        }
        
        
        if let result = brain.result{
            displayValue = result
        }
        
    }
    
    //->M
    @IBAction func setVariable(_ sender: UIButton) {
        brain.variableValues["M"] = displayValue
        brain.program = brain.program
        displayValue = brain.result!

    }
   
    //M
    @IBAction func getVariable(_ sender: UIButton)  {
        brain.setOperand(variableName: "M")
        displayValue = brain.result!
    }
    
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        // Do any additional setup after loading the view, typically from a nib.
    //    }
    //
    //    override func didReceiveMemoryWarning() {
    //        super.didReceiveMemoryWarning()
    //        // Dispose of any resources that can be recreated.
    //    }
    
    
}

