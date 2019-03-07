//
//  SelectEventViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 28/02/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SVProgressHUD

class SelectEventViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var CardView: UIView!
    @IBOutlet weak var EventList: UIPickerView!
    @IBOutlet weak var doneButton: UIImageView!
    static var apiCall = false
    
    var events = [String]()
    
    override func viewDidLayoutSubviews() {
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
        EventList.delegate=self
        EventList.dataSource=self
        doneButton.isUserInteractionEnabled=true
        doneButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectEventButtonPressed(_ :))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(SelectEventViewController.apiCall){
            SelectEventViewController.apiCall = false
            SVProgressHUD.show(withStatus:"Getting list of events...")
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultMaskType(.black)
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                self.events.removeAll()
                let eventURL = URL(string:RestHelper.urls["Get_Events"]!)!
                let eventList = RestHelper.makePost(eventURL, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!])
                let eventData = eventList.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: eventData, options : .allowFragments) as? [String]{
                        for event in jsonArray {
                            self.events.append(event)
                        }
                    }
                    
                } catch {
                    print("error")
                }
                
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    self.EventList.reloadAllComponents()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return events.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return events[row]
    }
    
    @objc func selectEventButtonPressed(_ : UITapGestureRecognizer){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Device_Info")
        do {
            let deviceInfo = try managedContext.fetch(fetchRequest)
            let objectUpdate = deviceInfo[0] as! NSManagedObject
            objectUpdate.setValue(events[EventList.selectedRow(inComponent: 0)], forKey: "eventName")
            do{
                try managedContext.save()
                print("Device Updated!")
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
        StudentListViewController.eventName=events[EventList.selectedRow(inComponent: 0)]
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: AdminToolsViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
}
