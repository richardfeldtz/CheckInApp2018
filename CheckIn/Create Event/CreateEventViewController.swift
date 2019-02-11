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
    @IBOutlet var eventLocation: UITextField!
    
    @IBOutlet var createEventButton: UIButton!
    @IBOutlet var loadStudentsView: UIView!
    
    fileprivate let datePicker = UIDatePicker()
    fileprivate let timePicker = UIDatePicker()
    
    fileprivate var identifier = ""
    fileprivate var key = ""
    
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
        view.layer.shouldRasterize = false
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
    }
    
    func checkInternetConnection() -> Bool {
        let connection = InternetConnectionTest.isInternetAvailable()
        if !connection {
            let internetAlert = UIAlertController(title: "No internet connection", message: "Your device is not connected to the internet. Please make sure you are connected to the internet to perform this action.", preferredStyle: .alert)
            internetAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(internetAlert, animated: true)
        }
        return connection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventLocation.delegate = self
        eventName.delegate = self
        eventDate.delegate = self
        eventTime.delegate = self
        let createEventGesture = UITapGestureRecognizer(target: self, action: #selector(self.createEventPressed(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        loadStudentsView.addGestureRecognizer(tapGesture)
        createEventButton.addGestureRecognizer(createEventGesture)
        showDatePicker()
        showTimePicker()
    }
    
    @objc func removeScreen(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func createEventPressed(_ sender: UITapGestureRecognizer) {
        
        if (eventTime.text?.isEmpty)! || (eventTime.text?.isEmpty)! || (eventName.text?.isEmpty)! || (eventLocation.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Warning", message: "Fields must not be blank", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        //Return if not connected to the internet
        if !checkInternetConnection(){
            return
        }
        
        let milisecondsDate = self.miliSecFromDate(date: eventDate.text! + " " + eventTime.text!)
        let localData = CoreDataHelper.retrieveData("Device_Info")
        for data in localData {
            self.identifier = (data as AnyObject).value(forKey: "identifier") as! String
            self.key = (data as AnyObject).value(forKey: "key") as! String

        }
        
        let url = URL(string:RestHelper.urls["Create_Event"]!)!
        RestHelper.makePost(url, ["identifier": self.identifier, "key": self.key, "eventName": eventName.text!, "location": eventLocation.text!, "eventDate": milisecondsDate, "isHometownHall": "false", "isOrientation": "false"])
        
        let uploadAlert = UIAlertController(title: "Success", message: "Event successfully created", preferredStyle: .alert)
        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
            (alertAction: UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(uploadAlert, animated: true)
    }
    
    func miliSecFromDate(date : String) -> String {
        let strTime = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let ObjDate = formatter.date(from: strTime)
        return (String(describing: ObjDate!.millisecondsSince1970))
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        formatView(view: eventName)
        formatView(view: eventDate)
        formatView(view: eventTime)
        formatView(view: eventLocation)
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
        formatter.dateFormat = "MM/dd/yyyy"
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
