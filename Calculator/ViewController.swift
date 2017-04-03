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
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
//            descriptionDisplay!.text = brain.describeCalculation(display.text!)
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

