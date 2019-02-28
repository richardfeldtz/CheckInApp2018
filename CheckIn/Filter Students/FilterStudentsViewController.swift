//
//  FilterStudentsViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/7/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class FilterStudentsViewController: UIViewController, UIPickerViewDataSource {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate let alphabet = ["A","B","C","D","E","F","G",
                                "H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    let schoolPickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
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
        button.translatesAutoresizingMaskIntoConstraints = false
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
        label.adjustsFontSizeToFitWidth = true
        label.text = "Only check in students from: "
        return label
    }()
    
    lazy var byLastNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.text = "Only check in students with the last name:"
        return label
    }()
    
    lazy var schoolContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    lazy var lastNameContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
        view.layer.shouldRasterize = false
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
    }
    
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
        view.backgroundColor = .gray
        // preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
        schoolPickerView.delegate = self
        schoolPickerView.dataSource = self
        lastNamePickerView.delegate = self
        lastNamePickerView.dataSource = self
        
        
        let firstLetterIndex = returnIndexOfAlphabet(FilterStudentsViewController.currentSelectedLastNameFilter.first!)
        let lastLetterIndex = returnIndexOfAlphabet(FilterStudentsViewController.currentSelectedLastNameFilter.last!)
        lastNamePickerView.selectRow(firstLetterIndex, inComponent: 0, animated: false)
        lastNamePickerView.selectRow(lastLetterIndex, inComponent: 1, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let schools = CoreDataHelper.retrieveData("School")
        
        for school in schools {
            schoolData.append((school as AnyObject).value(forKey: "sname") as! String)
        }
        
        view.addSubview(schoolContainerView)
        schoolContainerView.addSubview(xButton)
        //schoolContainerView.addSubview(filterStudentsLabel)
        schoolContainerView.addSubview(schoolPickerView)
        schoolContainerView.addSubview(schoolFilterSwitch)
        schoolContainerView.addSubview(studentsFromLabel)
        
        
        NSLayoutConstraint.activate([
            schoolContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            schoolContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            schoolContainerView.heightAnchor.constraint(equalToConstant: view.frame.height/2 - 20),
            schoolContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
            ])
        
        NSLayoutConstraint.activate([
            xButton.trailingAnchor.constraint(equalTo: schoolContainerView.trailingAnchor, constant: -30),
            xButton.topAnchor.constraint(equalTo: schoolContainerView.topAnchor, constant: 30),
            xButton.widthAnchor.constraint(equalToConstant: 25),
            xButton.heightAnchor.constraint(equalToConstant: 25)
            ])
        
//        NSLayoutConstraint.activate([
//            filterStudentsLabel.centerXAnchor.constraint(equalTo: schoolContainerView.centerXAnchor),
//            filterStudentsLabel.topAnchor.constraint(equalTo: schoolContainerView.topAnchor, constant: 50),
//            filterStudentsLabel.heightAnchor.constraint(equalToConstant: 50)
//            ])

        NSLayoutConstraint.activate([
            schoolPickerView.centerYAnchor.constraint(equalTo: schoolContainerView.centerYAnchor),
            schoolPickerView.centerXAnchor.constraint(equalTo: schoolContainerView.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate([
            studentsFromLabel.topAnchor.constraint(equalTo: schoolContainerView.topAnchor, constant: 50),
            studentsFromLabel.centerXAnchor.constraint(equalTo: schoolContainerView.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate([
            schoolFilterSwitch.bottomAnchor.constraint(equalTo: schoolContainerView.bottomAnchor, constant: -50),
            schoolFilterSwitch.centerXAnchor.constraint(equalTo: schoolContainerView.centerXAnchor)
            ])
        
        
        view.addSubview(lastNameContainerView)
        lastNameContainerView.addSubview(byLastNameLabel)
        lastNameContainerView.addSubview(lastNamePickerView)
        lastNameContainerView.addSubview(lastNameFilterSwitch)
        NSLayoutConstraint.activate([
            lastNameContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            lastNameContainerView.topAnchor.constraint(equalTo: schoolContainerView.bottomAnchor, constant: 10),
            lastNameContainerView.heightAnchor.constraint(equalToConstant: view.frame.height/2 - 20),
            lastNameContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20)
            ])
        
        NSLayoutConstraint.activate([
            byLastNameLabel.topAnchor.constraint(equalTo: lastNameContainerView.topAnchor, constant: 50),
            byLastNameLabel.centerXAnchor.constraint(equalTo: lastNameContainerView.centerXAnchor)
            ])
        NSLayoutConstraint.activate([
            lastNamePickerView.centerYAnchor.constraint(equalTo: lastNameContainerView.centerYAnchor),
            lastNamePickerView.centerXAnchor.constraint(equalTo: lastNameContainerView.centerXAnchor),
            ])
        
        NSLayoutConstraint.activate([
            lastNameFilterSwitch.bottomAnchor.constraint(equalTo: lastNameContainerView.bottomAnchor, constant: -50),
            lastNameFilterSwitch.centerXAnchor.constraint(equalTo: lastNameContainerView.centerXAnchor)
            ])
        
    }
    
    func returnIndexOfAlphabet(_ letter: String) -> Int {
        return self.alphabet.firstIndex(of: letter) ?? 0
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == schoolPickerView {
            // schoolPickerView.selectedRow(inComponent: 0). .text = schoolData[row]
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
        if pickerView == schoolPickerView {
            return 200
        }
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
