//
//  FilterStudentsViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/7/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit
import Foundation

class FilterStudentsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var filterSchoolView: UIView!
    @IBOutlet weak var filterNameView: UIView!
    
    @IBOutlet weak var schoolPickerView: UIPickerView!
    @IBOutlet weak var schoolFilterSwitch: UISwitch!
    @IBOutlet weak var lastNamePickerView: UIPickerView!
    @IBOutlet weak var lastNameFilterSwitch: UISwitch!
    
    @IBAction func schoolFilterSwitchChanged(_ sender: UISwitch) {
        FilterStudentsViewController.schoolFilterFlag = schoolFilterSwitch.isOn
        if lastNameFilterSwitch.isOn {
            FilterStudentsViewController.nameFilterFlag = false
            lastNameFilterSwitch.isOn = false
        }
    }
    
    @IBAction func lastNameSwitchChanged(_ sender: UISwitch) {
        FilterStudentsViewController.nameFilterFlag = lastNameFilterSwitch.isOn
        if schoolFilterSwitch.isOn {
            FilterStudentsViewController.schoolFilterFlag = false
            schoolFilterSwitch.isOn = false
        }
    }
    
    static var schoolData = [String]()
    static var currentSelectedSchool: String = "SchoolName"
    static var currentSelectedLastNameFilter: [String] = ["A", "A"]
    
    static var schoolFilterFlag = false
    static var nameFilterFlag = false
    
    fileprivate let alphabet = ["A","B","C","D","E","F","G",
                                "H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == schoolPickerView {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == schoolPickerView {
            return FilterStudentsViewController.schoolData.count
        } else {
            return alphabet.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == schoolPickerView {
            return FilterStudentsViewController.schoolData[row]
        } else {
            return String(alphabet[row])
        }
    }
    
    override func viewDidLayoutSubviews() {
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 10
        
        filterSchoolView.layer.cornerRadius = 10
        filterSchoolView.layer.shouldRasterize = false
        filterSchoolView.layer.borderWidth = 1
        
        filterNameView.layer.cornerRadius = 10
        filterNameView.layer.shouldRasterize = false
        filterNameView.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        schoolPickerView.delegate = self
        schoolPickerView.dataSource = self
        lastNamePickerView.delegate = self
        lastNamePickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        if FilterStudentsViewController.schoolFilterFlag {
            schoolFilterSwitch.isOn = true
            let schoolIndex = returnIndexOfSchool(FilterStudentsViewController.currentSelectedSchool)
            schoolPickerView.selectRow(schoolIndex, inComponent: 0, animated: false)
        }
        if FilterStudentsViewController.nameFilterFlag {
            lastNameFilterSwitch.isOn = true
            let firstLetterIndex = returnIndexOfAlphabet(FilterStudentsViewController.currentSelectedLastNameFilter.first!)
            let lastLetterIndex = returnIndexOfAlphabet(FilterStudentsViewController.currentSelectedLastNameFilter.last!)
            lastNamePickerView.selectRow(firstLetterIndex, inComponent: 0, animated: false)
            lastNamePickerView.selectRow(lastLetterIndex, inComponent: 1, animated: false)
        }
    }
    
    
    
    
    func returnIndexOfAlphabet(_ letter: String) -> Int {
        return self.alphabet.firstIndex(of: letter) ?? 0
    }
    
    func returnIndexOfSchool(_ schoolName: String) -> Int {
        return FilterStudentsViewController.schoolData.firstIndex(of: schoolName) ?? 0
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == schoolPickerView {
            FilterStudentsViewController.currentSelectedSchool = FilterStudentsViewController.schoolData[row]
        } else {
            FilterStudentsViewController.currentSelectedLastNameFilter.removeAll()
            FilterStudentsViewController.currentSelectedLastNameFilter.append(alphabet[lastNamePickerView.selectedRow(inComponent: 0)])
            FilterStudentsViewController.currentSelectedLastNameFilter.append(alphabet[lastNamePickerView.selectedRow(inComponent: 1)])
            
            
            let firstLetter = UnicodeScalar(FilterStudentsViewController.currentSelectedLastNameFilter.first!)
            let lastLetter = UnicodeScalar(FilterStudentsViewController.currentSelectedLastNameFilter.last!)
            if firstLetter!.value > lastLetter!.value{
                self.navigationItem.setHidesBackButton(true, animated: true)
                
            } else {
                self.navigationItem.setHidesBackButton(false, animated: true)
            }
        }
    }
    
}


