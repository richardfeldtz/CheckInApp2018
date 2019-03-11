//
//  RegistrationCheckViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 03/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

import Foundation

class RegistrationCheckViewController : UIViewController {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var contentText: UILabel!
    @IBOutlet weak var deviceName: UITextField!
    @IBOutlet weak var buttonView: UIView!
    var identifier: String = ""
    
    override func viewDidLoad() {
        super .viewDidLoad()
        //Code to move view with keyboard
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        //Code to dismiss keyboard when user clicks on the view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonClick(_ :))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contentText.text = "You must register this device before using the app. Please enter a name for this device."
    }
    
    override func viewDidLayoutSubviews() {
        cardView.layer.cornerRadius = 10
        cardView.layer.borderWidth = 1
        cardView.layer.shouldRasterize = false
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowPath = UIBezierPath(rect: cardView.bounds).cgPath
        
        buttonView.layer.cornerRadius = 10
        buttonView.layer.shouldRasterize = false
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    @objc func buttonClick(_ : UITapGestureRecognizer) {
        //Check if device name is empty
        if deviceName.text == nil || deviceName.text == ""{
            let deviceNameAlert = UIAlertController(title: "Error", message: "Please enter a device name", preferredStyle: .alert)
            deviceNameAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(deviceNameAlert, animated: true)
        }
        else{
            identifier = deviceName.text!
            identifier = identifier.trimmingCharacters(in: [" "])
            let url = URL(string:RestHelper.urls["Register_Device"]!)!
            let params = ["identifier":identifier] as Dictionary<String,String>
            let response = RestHelper.makePost(url, params)
            if response == "\"Device Successfully Registered.\"" {
                let registrationAlert = UIAlertController(title: "Success", message: "A device registration request was successfully created for your device with the name "+identifier+". Once the request is approved, you can use this device for check-ins. Please reopen the app when the request is approved.", preferredStyle: .alert)
                registrationAlert.addAction(UIAlertAction(title: "OK", style: .cancel , handler:
                    {
                        (alertAction: UIAlertAction) in
                        self.writeIdentifier(identifier: self.identifier)
                        self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(registrationAlert, animated: true)
			} else if response == "\"A device with this name has already been registered. Please choose a different name.\"" {
				let registrationAlert = UIAlertController(title: "Error", message: "A device with this name has already been registered. Please choose a different name.", preferredStyle: .alert)
				registrationAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
				self.present(registrationAlert, animated: true)
			}
        }
    }
    
    func writeIdentifier(identifier : String) {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get device info
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device_Info")
        do{
            let temp = try managedContext.fetch(fetchRequest).first
            if(!(temp==nil))
            {
                temp?.setValue(identifier, forKey: "identifier")
                try managedContext.save()
            }
            else{
                let entity = NSEntityDescription.entity(forEntityName: "Device_Info", in: managedContext)
                let filter = NSManagedObject(entity: entity!, insertInto: managedContext)
                filter.setValue(identifier, forKey: "identifier")
                try managedContext.save()
            }
        }
        catch _ as NSError {
            print("Error writing identifier to core data")
        }
    }
    
    
    
}
