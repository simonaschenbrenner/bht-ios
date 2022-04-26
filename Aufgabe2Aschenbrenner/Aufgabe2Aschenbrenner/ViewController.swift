//
//  ViewController.swift
//  Aufgabe2Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 30.04.21.
//

import UIKit

class ViewController: UIViewController {    
    
    var arg1: Int?
    var arg2: Int?
    enum op {
        case plus
        case minus
        case mult
        case div
    }
    
    @IBOutlet weak var arg1Label: UILabel!
    @IBOutlet weak var arg2Label: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var multButton: UIButton!
    @IBOutlet weak var divButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arg1Label.text = ""
        arg2Label.text = ""
        disableButton(enterButton, plusButton, minusButton, multButton, divButton)
    }
    
    @IBAction func button(_ sender: UIButton) {
        switch sender.currentTitle {
            case "ENTER":
                if (arg1 == nil && arg2 != nil) {
                    arg1 = arg2
                    arg2 = 0
                    arg1Label.text = String(arg1!)
                    arg2Label.text = ""
                    disableButton(enterButton)
                }
            case "RESET":
                arg1 = nil
                arg2 = nil
                arg1Label.text = ""
                arg2Label.text = ""
                disableButton(enterButton, plusButton, minusButton, multButton, divButton)
            case "+":
                calculate(op.plus)
            case "−":
                calculate(op.minus)
            case "×":
                calculate(op.mult)
            case "÷":
                calculate(op.div)
            case "0","1","2","3","4","5","6","7","8","9":
                if (arg2 == nil) {
                    arg2 = 0
                    if (arg1 == nil) {
                        enableButton(enterButton)
                    }
                }
                // Idee von https://stackoverflow.com/questions/35973899/how-does-one-trap-arithmetic-overflow-errors-in-swift
                let res = arg2!.multipliedReportingOverflow(by: 10)
                if (res.1) {
                    print("Overflow!")
                    return
                } else {
                    arg2 = res.0 + sender.tag
                    arg2Label.text = String(arg2!)
                }
                
                if (arg1 != nil) {
                    enableButton(plusButton, minusButton, multButton, divButton)
                }
            default:
                return
        }
    }
    
    func calculate(_ operation: op) {
        if (arg1 != nil && arg2 != nil) {
            var res = (0, false)
            switch operation {
                case .plus:
                    res = arg1!.addingReportingOverflow(arg2!)
                case .minus:
                    res = arg1!.subtractingReportingOverflow(arg2!)
                case .mult:
                    res = arg1!.multipliedReportingOverflow(by: arg2!)
                case .div:
                    if (arg2 != 0) {
                        res = (arg1!/arg2!, false)
                    } else {
                        print("Can't divide by 0!")
                    }
            }
            if (res.1) {
                print("Overflow!")
                return
            } else {
                arg1! = res.0
                arg2 = nil
                arg1Label.text = String(arg1!)
                arg2Label.text = ""
                disableButton(plusButton, minusButton, multButton, divButton)
                return
            }
        }
    }

    func disableButton(_ buttons: UIButton...) {
        for button in buttons {
            button.tintColor = UIColor.systemGray
            button.isUserInteractionEnabled = false
            button.isEnabled = false
        }
    }
    
    func enableButton(_ buttons: UIButton...) {
        for button in buttons {
            button.tintColor = UIColor.systemBlue
            button.isUserInteractionEnabled = true
            button.isEnabled = true
        }
    }
    
}
