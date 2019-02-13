//
//  SelectEventController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/28/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class SelectEventController: UIViewController, UIPickerViewDataSource {
    
    let pickerView = UIPickerView()
    static var events = [String]()
    
    lazy var eventTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Event Name"
        textField.inputView = pickerView
        textField.inputAccessoryView = setUpToolbar(functionType: #selector(cancelPicker))
        textField.addTarget(self, action: #selector(self.addPickerview), for: .touchUpInside)
        return textField
    }()
    
    func setUpToolbar(functionType: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: functionType)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        return toolbar
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        StudentListViewController.eventName = SelectEventController.events[row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Device_Info")
        do {
            let deviceInfo = try managedContext.fetch(fetchRequest)
            let objectUpdate = deviceInfo[0] as! NSManagedObject
            objectUpdate.setValue(SelectEventController.events[row], forKey: "eventName")
            do{
                try managedContext.save()
                print("Device Updated!")
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
        
        eventTextField.text = SelectEventController.events[row]
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
    @objc func addPickerview() {
        view.addSubview(pickerView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        view.addSubview(eventTextField)
        NSLayoutConstraint.activate([
            eventTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            SelectEventController.events.removeAll()
            let eventURL = URL(string:RestHelper.urls["Get_Events"]!)!
            let eventList = RestHelper.makePost(eventURL, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!])
            let eventData = eventList.data(using: .utf8)!
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: eventData, options : .allowFragments) as? [String]{
                    for event in jsonArray {
                        SelectEventController.events.append(event)
                    }
                }
                
            } catch {
                print("error")
            }
        
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
}

extension SelectEventController: UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SelectEventController.events.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SelectEventController.events[row]
    }
}
