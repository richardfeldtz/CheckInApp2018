//
//  CreateEventViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class CreateEventViewController: UIViewController {
    @IBOutlet weak var CardView: UIView!
    @IBOutlet weak var EventDateView: UIView!
    @IBOutlet weak var EventTimeView: UIView!
    @IBOutlet weak var createButton: UIImageView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!
    @IBOutlet weak var eventTime: UIDatePicker!
    @IBOutlet weak var isHTH: UISwitch!
    @IBOutlet weak var isOrientation: UISwitch!
    
    fileprivate var identifier = ""
    fileprivate var key = ""
    
    override func viewDidLayoutSubviews() {
//        EventDateView.layer.shouldRasterize = false
//        EventDateView.layer.borderWidth = 1
//        
//        EventTimeView.layer.shouldRasterize = false
//        EventTimeView.layer.borderWidth = 1
        
        CardView.layer.cornerRadius = 10
        CardView.layer.shouldRasterize = false
        CardView.layer.borderWidth = 1
        
        CardView.layer.shadowColor = UIColor.black.cgColor
        CardView.layer.shadowOpacity = 1
        CardView.layer.shadowOffset = CGSize.zero
        CardView.layer.shadowRadius = 10
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        createButton.isUserInteractionEnabled=true
        createButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(create(_ :))))
        
        //Code to dismiss keyboard when user clicks on the view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func create(_ : UITapGestureRecognizer){
        
        let ev_name=self.eventName.text
        let ev_loc=self.eventLocation.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="MM/dd/yyyy"
        let ev_date=dateFormatter.string(from: self.eventDate.date)
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let ev_time=dateFormatter.string(from: self.eventTime.date)
        
        if ((self.eventName.text?.isEmpty)! || (self.eventLocation.text?.isEmpty)!) {
            let alert = UIAlertController(title: "Warning", message: "Please enter all the event details", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        SVProgressHUD.show(withStatus:"Creating event")
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let milisecondsDate = self.miliSecFromDate(date: ev_date + " " + ev_time)
            let localData = CoreDataHelper.retrieveData("Device_Info")
            for data in localData {
                self.identifier = (data as AnyObject).value(forKey: "identifier") as! String
                self.key = (data as AnyObject).value(forKey: "key") as! String
                
            }
            
            let url = URL(string:RestHelper.urls["Create_Event"]!)!
            let _ = RestHelper.makePost(url, ["identifier": self.identifier, "key": self.key, "eventName": ev_name!, "location": ev_loc!, "eventDate": milisecondsDate, "isHometownHall": String(self.isHTH.isOn), "isOrientation": String(self.isOrientation.isOn)])
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Device_Info")
            do {
                let deviceInfo = try managedContext.fetch(fetchRequest)
                let objectUpdate = deviceInfo[0] as! NSManagedObject
                objectUpdate.setValue(ev_name!, forKey: "eventName")
                do{
                    try managedContext.save()
                    print("Device Updated!")
                }catch{
                    print(error)
                }
            } catch {
                print(error)
            }
            StudentListViewController.eventName=ev_name!
            
            let uploadAlert = UIAlertController(title: "Success", message: "Event successfully created", preferredStyle: .alert)
            uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                (alertAction: UIAlertAction) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(uploadAlert, animated: true)
            
            
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func miliSecFromDate(date : String) -> String {
        let strTime = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let ObjDate = formatter.date(from: strTime)
        return (String(describing: ObjDate!.millisecondsSince1970))
    }
    
}
