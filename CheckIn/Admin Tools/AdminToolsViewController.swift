//
//  AdminViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/11/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit
import CoreData

class AdminToolsViewController: UIViewController {
    
    @IBOutlet var uploadDataView: UIView!
    @IBOutlet var downloadDataView: UIView!
    @IBOutlet var filterView: UIView!
    @IBOutlet var createEventView: UIView!
    @IBOutlet var eventDetailsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
    }
    
    fileprivate func setupGestureRecognizers() {
        uploadDataView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        downloadDataView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadData)))
        filterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterStudentsTapped)))
        createEventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCreateEventVC)))
        eventDetailsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEventDetailsVC)))
    }
    
    @objc func handleTap(){
        print("TOUCHED")
    }
    
    @objc func downloadData() {
//        let progressHUD = ProgressHUD(text: "Downloding Data")
//        self.view.addSubview(progressHUD)
        
        let url = URL(string:"https://dev1-ljff.cs65.force.com/test/services/apexrest/students")!
        let jsonString = RestHelper.makePost(url, ["identifier": "test", "key": "123456"])
        
        CoreDataHelper.deleteData()
        
        let data = jsonString.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,String>]{
                
                for item in jsonArray {
                    CoreDataHelper.saveStudentData(item, "Student")
                }
                
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    @objc func filterStudentsTapped(){
        let vc = FilterStudentsViewController()
        vc.modalPresentationStyle = .formSheet
        vc.storyboard?.instantiateInitialViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func openCreateEventVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateEvent") as! CreateEventViewController
        self.show(vc, sender: self)
    }
    
    @objc func openEventDetailsVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventDetails") as! EventDetailsViewController
        self.show(vc, sender: self)
    }
    
    
}
