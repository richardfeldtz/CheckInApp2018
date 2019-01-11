//
//  CoreDataHelper.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/8/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import CoreData
import Foundation
import UIKit

public class CoreDataHelper {
    
    class func countOfEntity(_ entityName: String) -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        return try! managedContext.count(for: fetchRequest)
    }
    
    class func saveStudentData(_ jsonObj: [String:String], _ entityName: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let descrEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        let obj = NSManagedObject(entity: descrEntity, insertInto: managedContext)
        obj.setValue(jsonObj["Name"], forKeyPath: "fname")
        obj.setValue(jsonObj["School_Name"], forKey: "sname")
        obj.setValue(jsonObj["ID"], forKey: "sfid")
        obj.setValue("test.com", forKey: "lname")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            
        }
    }
    
    class func retrieveData(_ entityName: String) -> [Any]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            return result
        } catch {
            print("Failed")
        }
        return []
    }
    
    
    class func updateData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur1")
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue("newName", forKey: "username")
            objectUpdate.setValue("newmail", forKey: "email")
            objectUpdate.setValue("newpassword", forKey: "password")
            do{
                try managedContext.save()
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
        
    }
    
    class func deleteData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
//        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        //fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur3")
        var fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        var request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try! managedContext.execute(request)
        
        fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Checkins")
        request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try! managedContext.execute(request)

//        do{
//            let test = try managedContext.fetch(fetchRequest)
//
//            let objectToDelete = test[0] as! NSManagedObject
//            managedContext.delete(objectToDelete)
//
//            do{
//                try managedContext.save()
//            }catch{
//                print(error)
//            }
//
//        }catch{
//            print(error)
//        }
    }
    
}
