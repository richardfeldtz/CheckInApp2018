//
//  ProfileViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 04/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProfileViewController : UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guestTextField.text = String(row)
    }
    
    
    var pickerView = UIPickerView()
    var guestsWithStudent: Int = 0
    var name = ""
    var sname = ""
    var id = ""
    
    @IBOutlet var guestTextField: UITextField!
    @IBOutlet var checkInLabel: UILabel!
    
    @IBAction func dismissProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func checkIn(_ sender: UIButton) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let descrEntity = NSEntityDescription.entity(forEntityName: "Checkins", in: managedContext)!
        let checkedStudent = NSManagedObject(entity: descrEntity, insertInto: managedContext)
        checkedStudent.setValue(id, forKey: "id")
        checkedStudent.setValue("API Event", forKey: "event_name")
        
        //Update checkin flag
        var studentResult : [NSManagedObject]
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let index = StudentListViewController.idmap[id]
        StudentListViewController.data[index!].checked=true
        
        do {
            studentResult = try managedContext.fetch(fetchRequest)
            let student=studentResult.first
            student?.setValue(true, forKey: "checked")
            try managedContext.save()
            print("Checkin successful")
            StudentListViewController.searchController.searchBar.text=nil
            guard let text = guestTextField.text, let number = Int(text) else { return } // no text
            CoreDataHelper.addToCheckInTable(number, id, "Checkins")
            self.dismiss(animated: true, completion: nil)
            
        }
        catch _ as NSError{
            print("Could not check-in student")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if StudentListViewController.data[StudentListViewController.idmap[id]!].checked {
            let checkInAlert = UIAlertController(title: "Warning", message: "The student has already been checked in", preferredStyle: .alert)
            checkInAlert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler:{
                    (alertAction: UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
            }))
            self.present(checkInAlert, animated: true)
        }
        
        var lastNameFilterCondition = true
        let filterString = FilterStudentsViewController.getFilterString(FilterStudentsViewController.currentSelectedLastNameFilter)
        let nameArray = name.byWords
        for (_, char) in filterString.enumerated() {
            if (Character((nameArray.last?.prefix(1).lowercased())!) == char) {
                lastNameFilterCondition = false
            }
        }
        
        
        if FilterStudentsViewController.currentSelectedSchool != "" && (sname == FilterStudentsViewController.currentSelectedSchool || lastNameFilterCondition) {
            let checkInAlert = UIAlertController(title: "Warning", message: "The selected student does not match the filter", preferredStyle: .alert)
            checkInAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{
                (alertAction: UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(checkInAlert, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        // idLabel.text = id
        pickerView.delegate = self
        checkInLabel.text = name
        guestTextField.delegate = self
        guestTextField.inputView = pickerView
        guestTextField.inputAccessoryView = setUpToolbar(functionType: #selector(cancelPicker))
        navigationController?.setNavigationBarHidden(false, animated: true)
        preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
    }
    
    func setUpToolbar(functionType: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: functionType)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        //        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelPicker))
        toolbar.setItems([spaceButton,doneButton], animated: false)
        
        return toolbar
    }
    
    @objc func cancelPicker(){
        self.view.endEditing(true)
    }
    
}
