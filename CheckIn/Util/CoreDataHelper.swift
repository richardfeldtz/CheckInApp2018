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
        obj.setValue(false, forKeyPath: "checked")
        obj.setValue(jsonObj["Name"], forKeyPath: "name")
        obj.setValue(jsonObj["School_Name"], forKey: "sname")
        obj.setValue(jsonObj["ID"], forKey: "id")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            
        }
    }
    
    class func retrieveStudentData() -> Array<Student>?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [Student]
            return result
            
        } catch {
            print("Failed")
        }
        
        return nil
    }
    
    class func updateStudentData(entityName: String, APS_ID: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", APS_ID)
        do {
            let studentObj = try managedContext.fetch(fetchRequest)
            let objectUpdate = studentObj[0] as! NSManagedObject
            objectUpdate.setValue(true, forKey: "checked")
            do{
                try managedContext.save()
                print("Student Updated!")
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
    }
//    class func updateData(, _ entityName: String) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
//        //fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur1")
//        do {
//            let test = try managedContext.fetch(fetchRequest)
//            
//            let objectUpdate = test[0] as! NSManagedObject
//            objectUpdate.setValue("newName", forKey: "username")
//            objectUpdate.setValue("newmail", forKey: "email")
//            objectUpdate.setValue("newpassword", forKey: "password")
//            do{
//                try managedContext.save()
//            }catch{
//                print(error)
//            }
//        } catch {
//            print(error)
//        }
//        
//    }
    
    class func deleteData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        //fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur3")
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try! managedContext.execute(request)
        
    }
    
    
    
}
