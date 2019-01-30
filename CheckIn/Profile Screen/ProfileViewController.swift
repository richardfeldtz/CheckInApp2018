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
        return 12
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Pick number of guests"
        }
        else {
            return String(row - 1)
        }
    }
    
    
    var guestsWithStudent: Int = 0
    var name = ""
    var sname = ""
    var id = ""
    var alreadyChecked = false
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var checkInButtonText: UILabel!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet var checkInLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var guestPicker: UIPickerView!
    @IBAction func dismissProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if StudentListViewController.data[StudentListViewController.idmap[id]!].checked {
            
            //Get guest count for student who is already checked in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            var checkInResult : [NSManagedObject]
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Checkins")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            do {
                checkInResult = try managedContext.fetch(fetchRequest)
                let studentCheckIn=checkInResult.first
                guestPicker.selectRow(studentCheckIn?.value(forKey: "guests") as! Int + 1, inComponent: 0, animated: true)
            }
            catch _ as NSError{
                print("Error fetching guest count from check in table")
            }
            
            //Change check-in button text
            self.checkInButtonText.text = "Update"
            alreadyChecked = true
            let checkInAlert = UIAlertController(title: "Warning", message: "The student has already been checked in", preferredStyle: .alert)
            checkInAlert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(checkInAlert, animated: true)
        }
        else {
            deleteButtonView.isHidden = true
        }
        
        var lastNameDoesNotMatchFilter = true
        let filterString = FilterStudentsViewController.getFilterString(FilterStudentsViewController.currentSelectedLastNameFilter)
        let nameArray = name.byWords
        for (_, char) in filterString.enumerated() {
            if (Character((nameArray.last?.prefix(1).lowercased())!) == char) {
                lastNameDoesNotMatchFilter = false
            }
        }
        
        if FilterStudentsViewController.nameFilterFlag {
            if lastNameDoesNotMatchFilter {
                let checkInAlert = UIAlertController(title: "Warning", message: "The selected student does not match the filter", preferredStyle: .alert)
                checkInAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{
                    (alertAction: UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(checkInAlert, animated: true)
            }
        }

        if FilterStudentsViewController.schoolFilterFlag && sname != FilterStudentsViewController.currentSelectedSchool {
            let checkInAlert = UIAlertController(title: "Warning", message: "The selected student does not match the filter", preferredStyle: .alert)
            checkInAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{
                (alertAction: UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(checkInAlert, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        guestPicker.dataSource=self
        guestPicker.delegate=self
        guestPicker.autoresizesSubviews=true
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonClick(_ :))))
        deleteButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteButtonClick(_ :))))
        checkInLabel.text = name
        schoolNameLabel.text = sname
        navigationController?.setNavigationBarHidden(false, animated: true)
        preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
    }
    
    override func viewDidLayoutSubviews() {
        buttonView.layer.cornerRadius = 10
        buttonView.layer.shouldRasterize = false
        deleteButtonView.layer.cornerRadius = 10
        deleteButtonView.layer.shouldRasterize = false
    }
    
    @objc func buttonClick(_ : UITapGestureRecognizer) {
        
        var guestCount = 0
        let selectedPickerRow = Int(guestPicker.selectedRow(inComponent: 0))
        if selectedPickerRow > 0 {
            guestCount = selectedPickerRow - 1;
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        if !alreadyChecked {
            let descrEntity = NSEntityDescription.entity(forEntityName: "Checkins", in: managedContext)!
            let checkedStudent = NSManagedObject(entity: descrEntity, insertInto: managedContext)
            checkedStudent.setValue(id, forKey: "id")
            checkedStudent.setValue("API Event", forKey: "event_name")
            checkedStudent.setValue(guestCount, forKey: "guests")
            
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
                self.dismiss(animated: true, completion: nil)
                
            }
            catch _ as NSError{
                print("Could not check-in student")
            }
        }
        else {
            var checkInResult : [NSManagedObject]
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Checkins")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            do {
                checkInResult = try managedContext.fetch(fetchRequest)
                let studentCheckIn=checkInResult.first
                studentCheckIn?.setValue(guestCount, forKey: "guests")
                try managedContext.save()
                print("Update successful")
                StudentListViewController.searchController.searchBar.text=nil
                self.dismiss(animated: true, completion: nil)
                
            }
            catch _ as NSError{
                print("Could not update check-in")
            }
        }
    }
    
    @objc func deleteButtonClick(_ : UITapGestureRecognizer) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var studentResult : NSManagedObject
        let checkInFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Checkins")
        let studentFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        checkInFetchRequest.predicate = NSPredicate(format: "id == %@", id)
        studentFetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let delCheckIn = NSBatchDeleteRequest(fetchRequest: checkInFetchRequest)
            try managedContext.execute(delCheckIn)
            studentResult = try managedContext.fetch(studentFetchRequest).first!
            studentResult.setValue(false, forKey: "checked")
            try managedContext.save()
            StudentListViewController.data[StudentListViewController.idmap[id]!].checked = false
            StudentListViewController.searchController.searchBar.text=nil
            self.dismiss(animated: true, completion: nil)
            
        }
        catch _ as NSError{
            print("Could not update check-in")
        }
        
    }
    
}
