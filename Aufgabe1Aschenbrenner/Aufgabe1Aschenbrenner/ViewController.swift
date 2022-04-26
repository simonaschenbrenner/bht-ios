//
//  ViewController.swift
//  Aufgabe1Aschenbrenner
//
//  Created by Simon Núñez Aschenbrenner on 18.04.21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var counter: UILabel!
    
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Hallo, ich bin es: Simon Aschenbrenner"
        counter.text = String(0)
    }

    @IBAction func button(_ sender: Any) {
        print("Mensch Simon ich fange jetzt einen Knopfdruck ab! Mensch, Simon")
        i += 1
        counter.text = String(i)
    };
    
}
