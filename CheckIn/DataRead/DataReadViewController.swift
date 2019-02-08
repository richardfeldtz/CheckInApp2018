//
//  DataReadViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 07/02/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataReadViewController : UIViewController {
    
    var data = ""
    var count = 0
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        analyzeData()
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        buttonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonClick(_ :))))
    }
    
    override func viewDidLayoutSubviews() {
        buttonView.layer.cornerRadius = 10
        buttonView.layer.shouldRasterize = false
        
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 10
    }
    
    func analyzeData() {
        let individualEntries = data.split(separator: ",")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let descrEntity = NSEntityDescription.entity(forEntityName: "Checkins", in: managedContext)!
        
        for entry in individualEntries {
            let pieces = entry.split(separator: ":")
            let id = String(pieces[0])
            let guests = Int(pieces[1])
            let index = StudentListViewController.idmap[id]
            
            if !StudentListViewController.data[index!].checked {
                count += 1
                StudentListViewController.data[index!].checked=true
            
                let checkedStudent = NSManagedObject(entity: descrEntity, insertInto: managedContext)
                checkedStudent.setValue(id, forKey: "id")
                checkedStudent.setValue(StudentListViewController.eventName, forKey: "event_name")
                checkedStudent.setValue(guests, forKey: "guests")
        
                //Update checkin flag
                var studentResult : [NSManagedObject]
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
                fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
                do {
                    studentResult = try managedContext.fetch(fetchRequest)
                    let student=studentResult.first
                    student?.setValue(true, forKey: "checked")
                }
                catch _ as NSError{
                    print("Could not successfully analyze data that was read.")
                }
            }
        }
        
        
        do {
            try managedContext.save()
            textLabel.text = String(count) + " checkin records were successfully copied onto this device."
        }
        catch _ as NSError {
            print("Could not update checkins")
        }
        
    }
    
    @objc func buttonClick(_ : UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
}
