//
//  CreateEventViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var eventName: UITextField!
    @IBOutlet var eventDate: UITextField!
    @IBOutlet var eventTime: UITextField!

    @IBOutlet var createEventButton: UIButton!
    @IBOutlet var loadStudentsView: UIView!
    
    fileprivate let datePicker = UIDatePicker()
    fileprivate let timePicker = UIDatePicker()
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
        view.layer.shouldRasterize = false
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        //        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventName.delegate = self
        eventDate.delegate = self
        eventTime.delegate = self
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(self.removeScreen(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        loadStudentsView.addGestureRecognizer(tapGesture)
        showDatePicker()
        showTimePicker()
    }
    
    @objc func removeScreen(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        formatView(view: eventName)
        formatView(view: eventDate)
        formatView(view: eventTime)
        formatView(view: loadStudentsView)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.lightGray
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .white
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let vc = LoadStudentsViewController()
        vc.modalPresentationStyle = .formSheet
        vc.storyboard?.instantiateInitialViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
        self.present(vc, animated: true, completion: nil)
    }
    
    func setUpToolbar(functionType: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: functionType)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CreateEventViewController.cancelDatePicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        return toolbar
    }
    
    func showDatePicker(){
        datePicker.datePickerMode = .date
        eventDate.inputAccessoryView = setUpToolbar(functionType: #selector(datePickerFormat))
        eventDate.inputView = datePicker
    }
    
    func showTimePicker(){
        timePicker.datePickerMode = .time
        eventTime.inputAccessoryView = setUpToolbar(functionType: #selector(timePickerFormat))
        eventTime.inputView = timePicker
    }
    
    @objc func datePickerFormat(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        eventDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func timePickerFormat(){
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        eventTime.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
}
