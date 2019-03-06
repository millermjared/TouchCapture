//
//  ViewController.swift
//  TouchCapture
//
//  Created by Mathew Miller on 11/17/18.
//  Copyright © 2018 Mathew Miller. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var trainingLabel: UILabel!
    
    var touchReporter: TouchReporter?
    var touchClassifier = TouchClassifier()
    
    var counter = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isMultipleTouchEnabled = true
        
        Settings.gestureType = GestureType.allCases.first ?? .pinch
        
        trainingLabel.text = "Please make \(counter) \(Settings.gestureType.rawValue) gestures"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchReporter = TouchReporter(touches, inView: view)
        
        counter -= 1
        
        if counter <= 0 {
            
            if Settings.gestureType == GestureType.allCases.last {
                trainingLabel.text = "Training complete, thank you for your help"
            } else {                
                counter = 10
                
                var found = false
                for gestureType in GestureType.allCases {
                    if found {
                        Settings.gestureType = gestureType
                        break
                    }
                    
                    if gestureType == Settings.gestureType {
                        found = true
                    }
                }
                trainingLabel.text = "Please make \(counter) \(Settings.gestureType.rawValue) gestures"
            }
        } else {
            trainingLabel.text = "Please make \(counter) \(Settings.gestureType.rawValue) gestures"
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchReporter?.updateTouches(touches, inView: view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchReporter = nil
    }

}

