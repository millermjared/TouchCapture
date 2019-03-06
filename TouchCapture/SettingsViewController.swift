//
//  SettingsViewController.swift
//  TouchCapture
//
//  Created by Mathew Miller on 11/17/18.
//  Copyright © 2018 Mathew Miller. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var markupModeSwitch: UISwitch!
    @IBOutlet weak var modePicker: UIPickerView!
    @IBOutlet weak var trainingModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        trainingModeSwitch.setOn(Settings.trainingModeOn, animated: false)
        markupModeSwitch.setOn(Settings.markupModeOn, animated: false)
        modePicker.dataSource = self
        modePicker.delegate = self
    }
    
    @IBAction func trainingModeChanged(_ sender: Any) {
        Settings.trainingModeOn = trainingModeSwitch.isOn
    }
    
    @IBAction func markupModeChanged(_ sender: Any) {
        Settings.markupModeOn = markupModeSwitch.isOn
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}

extension SettingsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GestureType.allCases.count
    }
    
    
}

extension SettingsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GestureType.allCases[row].rawValue
    }
}
