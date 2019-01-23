//
//  LaunchViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 03/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreGraphics

class LaunchViewController :UIViewController
{
    
    @IBOutlet weak var animatedView: UIView!
    
    let imagelayer=CALayer()
    
    //Global identifier and key to use in api calls
    static var key : String?
    static var identifier : String?
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        generateLogo()
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        imagelayer.position=animatedView.center
    }
    
    func getRegKey(identifier : String) -> String {
        let url = URL(string: RestHelper.urls["Get_Registration_Key"]!)!
        let params = ["identifier":identifier] as Dictionary<String,String>
        var response = RestHelper.makePost(url, params)
        //Trim starting and ending "
        response.removeFirst()
        response.removeLast()
        return response
    }
    
    func generateLogo()
    {
        imagelayer.frame=animatedView.bounds
        animatedView.layer.addSublayer(imagelayer)
        
        imagelayer.contents = UIImage(named: "blackLogo")?.cgImage
        imagelayer.contentsGravity = CALayerContentsGravity.resizeAspect
        imagelayer.backgroundColor=UIColor.black.cgColor
        imagelayer.shadowOpacity = 0.7
        imagelayer.shadowRadius = 10.0
        imagelayer.cornerRadius = imagelayer.frame.width/2
        imagelayer.isHidden = false
        imagelayer.masksToBounds = false
        animatedView.alpha = 0.0
        
        UIView.animate(withDuration: 2.0, animations: {
            self.animatedView.alpha = 1.0
        }, completion: { finished in
            
            //Read device data
            var coreData = CoreDataHelper.retrieveData("Device_Info")
            let data = coreData.first
            
            LaunchViewController.key = (data as AnyObject).value(forKey: "key") as? String
            LaunchViewController.identifier = (data as AnyObject).value(forKey: "identifier") as? String
            
            if LaunchViewController.identifier == nil {
                self.performSegue(withIdentifier: "CheckRegistration", sender: self)
            }
            
            else if LaunchViewController.key == nil {
                let responseKey = self.getRegKey(identifier: LaunchViewController.identifier!)
                if responseKey == "Not Authorized" {
                    let registrationAlert = UIAlertController(title: "Not Authorized", message: "Your device registration has not yet been approved. Please wait till device \""+LaunchViewController.identifier!+"\" is verified.", preferredStyle: .alert)
                    registrationAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(registrationAlert, animated: true)
                }
                else {
                    self.writeKey(key: responseKey)
                    print("Wrote key "+responseKey)
                    self.performSegue(withIdentifier: "ShowList", sender: self)
                }
            }
            else {
                //Read event name
                let eventName = (data as AnyObject).value(forKey: "eventName") as? String
                if eventName != nil {
                    StudentListViewController.eventName = eventName!
                }
            
                //Read student records from core data
                coreData = CoreDataHelper.retrieveData("Student")
                for data in coreData {
                    let studentDataItem = StudentData(id: (data as AnyObject).value(forKey: "id") as? String, name: (data as AnyObject).value(forKey: "name") as? String,checked: ((data as AnyObject).value(forKey: "checked") as! Bool) , sname: (data as AnyObject).value(forKey: "sname") as? String)
                    StudentListViewController.data.append(studentDataItem)
                    StudentListViewController.idmap.updateValue(StudentListViewController.data.count-1, forKey: studentDataItem.id!)
                }
        
                self.performSegue(withIdentifier: "ShowList", sender: self)
            }
        })

        
    }
    
    func writeKey(key : String) {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get device info
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device_Info")
        do{
            let temp = try managedContext.fetch(fetchRequest).first
            temp?.setValue(key, forKey: "key")
            try managedContext.save()
        }
        catch _ as NSError {
            print("Error writing key to core data")
        }
    }
    
    
    
}


