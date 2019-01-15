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

class ProfileViewController : UIViewController {
    
    
    
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
            self.dismiss(animated: true, completion: nil)
            
        }
        catch _ as NSError{
            print("Could not check-in student")
        }
    }
    
    
    var name = ""
    var sname = ""
    var id = ""
    
    override func viewWillAppear(_ animated: Bool) {
        if StudentListViewController.data[StudentListViewController.idmap[id]!].checked {
            let checkInAlert = UIAlertController(title: "Warning", message: "The student has already been checked in", preferredStyle: .alert)
            checkInAlert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler:
                {
                    (alertAction: UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
            }))
            self.present(checkInAlert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        // idLabel.text = id
        checkInLabel.text = name
        navigationController?.setNavigationBarHidden(false, animated: true)
        preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
    }
    
    @IBAction func checkInStudent(_ sender: Any) {
        CoreDataHelper.updateStudentData(entityName: "Student", APS_ID: id)
    }
    
}
