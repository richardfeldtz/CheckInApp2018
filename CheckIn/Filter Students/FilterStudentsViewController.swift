//
//  FilterStudentsViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/7/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class FilterStudentsViewController: UIViewController, UIPickerViewDataSource {
    
    fileprivate let alphabet = ["A","B","C","D","E","F","G",
    "H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    let schoolPickerView = UIPickerView()
    let lastNamePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    
    var schoolData = [String]()
    static var currentSelectedSchool: String?
    static var currentSelectedLastNameFilter: [String] = ["A", "A"]
    
    static var schoolFilterFlag = false
    static var nameFilterFlag = false
    
    lazy var schoolFilterSwitch: UISwitch = {
        let schoolSwitch = UISwitch()
        schoolSwitch.isOn = FilterStudentsViewController.schoolFilterFlag
        schoolSwitch.addTarget(self, action: #selector(schoolFilterWasSwitched), for: .valueChanged)
        schoolSwitch.translatesAutoresizingMaskIntoConstraints = false
        return schoolSwitch
    }()
    
    
    lazy var lastNameFilterSwitch: UISwitch = {
        let schoolSwitch = UISwitch()
        schoolSwitch.isOn = FilterStudentsViewController.nameFilterFlag
        schoolSwitch.addTarget(self, action: #selector(nameFilterWasSwitched), for: .valueChanged)
        schoolSwitch.translatesAutoresizingMaskIntoConstraints = false
        return schoolSwitch
    }()
    
    
    lazy var xButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icons8-delete-filled-25"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(self.removeScreen), for: .touchUpInside)
        return button
    }()
    
    lazy var filterStudentsLabel: UnderLinedLabel = {
        let label = UnderLinedLabel()
        label.text = "Filter Students"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var studentsFromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Only check in students from: "
        return label
    }()
    
    lazy var schoolTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "School Name"
        textField.inputView = schoolPickerView
        textField.text = FilterStudentsViewController.currentSelectedSchool
        textField.inputAccessoryView = setUpToolbar(functionType: #selector(cancelPicker))
        textField.addTarget(self, action: #selector(self.addSchoolPickerView), for: .touchUpInside)
        return textField
    }()
    

    
    lazy var byLastNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "With the last name:"
        return label
    }()
    
    @objc func removeScreen(){
        let firstLetter = UnicodeScalar(FilterStudentsViewController.currentSelectedLastNameFilter.first!)
        let lastLetter = UnicodeScalar(FilterStudentsViewController.currentSelectedLastNameFilter.last!)
        if firstLetter!.value > lastLetter!.value{
            let filterAlert = UIAlertController(title: "Warning", message: "Invalid Filter", preferredStyle: .alert)
            filterAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:nil))
            self.present(filterAlert, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func addSchoolPickerView() {
        view.addSubview(schoolPickerView)
    }
    
    @objc func addGradePickerView() {
        view.addSubview(lastNamePickerView)
    }
    
    @objc func schoolFilterWasSwitched(){
        FilterStudentsViewController.schoolFilterFlag = schoolFilterSwitch.isOn
        if lastNameFilterSwitch.isOn {
            FilterStudentsViewController.nameFilterFlag = false
            lastNameFilterSwitch.isOn = false
        }
    }
    
    @objc func nameFilterWasSwitched(){
        FilterStudentsViewController.nameFilterFlag = lastNameFilterSwitch.isOn
        if schoolFilterSwitch.isOn {
            FilterStudentsViewController.schoolFilterFlag = false
            schoolFilterSwitch.isOn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
        schoolPickerView.delegate = self
        schoolPickerView.dataSource = self
        lastNamePickerView.delegate = self
        lastNamePickerView.dataSource = self
        
        
        let firstLetterIndex = returnIndexOfAlphabet(FilterStudentsViewController.currentSelectedLastNameFilter.first!)
        let lastLetterIndex = returnIndexOfAlphabet(FilterStudentsViewController.currentSelectedLastNameFilter.last!)
        lastNamePickerView.selectRow(firstLetterIndex, inComponent: 0, animated: false)
        lastNamePickerView.selectRow(lastLetterIndex, inComponent: 1, animated: false)
        view.addSubview(xButton)
        view.addSubview(filterStudentsLabel)
        view.addSubview(studentsFromLabel)
        view.addSubview(schoolTextField)
        view.addSubview(byLastNameLabel)
        view.addSubview(lastNamePickerView)
        view.addSubview(schoolFilterSwitch)
        view.addSubview(lastNameFilterSwitch)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let schools = CoreDataHelper.retrieveData("School")
        
        for school in schools {
            schoolData.append((school as AnyObject).value(forKey: "sname") as! String)
        }
        
        
        xButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            xButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            xButton.widthAnchor.constraint(equalToConstant: 25),
            xButton.heightAnchor.constraint(equalToConstant: 25)
            ])
        NSLayoutConstraint.activate([
            filterStudentsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterStudentsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            filterStudentsLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
        NSLayoutConstraint.activate([
            studentsFromLabel.topAnchor.constraint(equalTo: filterStudentsLabel.bottomAnchor, constant: 20),
            studentsFromLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        NSLayoutConstraint.activate([
            schoolTextField.topAnchor.constraint(equalTo: studentsFromLabel.bottomAnchor, constant: 20),
            schoolTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        NSLayoutConstraint.activate([
            byLastNameLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            byLastNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        NSLayoutConstraint.activate([
            lastNamePickerView.topAnchor.constraint(equalTo: byLastNameLabel.bottomAnchor, constant: 20),
            lastNamePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastNamePickerView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        //switch constraints
        NSLayoutConstraint.activate([
            schoolFilterSwitch.topAnchor.constraint(equalTo: schoolTextField.bottomAnchor, constant: 20),
            schoolFilterSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        NSLayoutConstraint.activate([
            lastNameFilterSwitch.topAnchor.constraint(equalTo: lastNamePickerView.bottomAnchor, constant: 20),
            lastNameFilterSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor)

            ])
    }
    
    func returnIndexOfAlphabet(_ letter: String) -> Int {
        return self.alphabet.firstIndex(of: letter) ?? 0
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    func setUpToolbar(functionType: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: functionType)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        return toolbar
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == schoolPickerView {
            schoolTextField.text = schoolData[row]
            FilterStudentsViewController.currentSelectedSchool = schoolData[row]
        } else {
            FilterStudentsViewController.currentSelectedLastNameFilter.removeAll()
            FilterStudentsViewController.currentSelectedLastNameFilter.append(alphabet[lastNamePickerView.selectedRow(inComponent: 0)])
            FilterStudentsViewController.currentSelectedLastNameFilter.append(alphabet[lastNamePickerView.selectedRow(inComponent: 1)])
        }
        
    }
    
}

extension FilterStudentsViewController: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == schoolPickerView {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == schoolPickerView {
            return CoreDataHelper.countOfEntity("School")
        } else {
            return alphabet.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == schoolPickerView {
            return schoolData[row]
        } else {
            return String(alphabet[row])
        }
    }
}
