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
    
    func formatView(view : UIView){
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.backgroundColor=UIColor.white.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        view.layer.shouldRasterize = false
        view.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        formatView(view: uploadDataView)
        formatView(view: downloadDataView)
        formatView(view: filterView)
        formatView(view: createEventView)
        formatView(view: eventDetailsView)
    }
    
    
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
        let localData = CoreDataHelper.retrieveData("Checkins")
        var ids: Array<String> = []
        var guests: Array<Int> = []
        do{
        for data in localData {
            ids.append((data as AnyObject).value(forKey: "id") as! String)
            guests.append((data as AnyObject).value(forKey: "guests") as! Int)
        }}
        
        //Generate checkin id list
        var idString = ""
        var guestNumbers = ""

        for number in ids {
            idString = idString + number + ","
        }
        
        for number in guests {
            guestNumbers = guestNumbers + String(number) + ","
        }
        
        idString.removeLast()
        guestNumbers.removeLast()
        
        let url = URL(string:"https://dev1-ljff.cs65.force.com/test/services/apexrest/event/attendance")!
        _ = RestHelper.makePost(url, ["identifier": "test", "key": "123456", "eventName": "API Test", "studentIds": idString, "guestCounts": guestNumbers])
        let uploadAlert = UIAlertController(title: "Success", message: "Check in list successfully uploaded", preferredStyle: .alert)
        uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(uploadAlert, animated: true)
    }
    
    @objc func downloadData() {
        
        let url = URL(string:"https://dev1-ljff.cs65.force.com/test/services/apexrest/students")!
        let schoolURL = URL(string:"https://dev1-ljff.cs65.force.com/test/services/apexrest/schools")!
        let jsonString = RestHelper.makePost(url, ["identifier": "test", "key": "123456"])
        let schoolList = RestHelper.makePost(schoolURL, ["identifier": "test", "key": "123456"])
        
        CoreDataHelper.deleteAllData(from: "Checkins")
        CoreDataHelper.deleteAllData(from: "Student")
        CoreDataHelper.deleteAllData(from: "School")
        StudentListViewController.data.removeAll()
        StudentListViewController.idmap.removeAll()
        FilterStudentsViewController.schoolData.removeAll()
        
        let data = jsonString.data(using: .utf8)!
        let schoolData = schoolList.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,String>], let schoolArray = try JSONSerialization.jsonObject(with: schoolData, options : .allowFragments) as? [String]{
                
                for school in schoolArray {
                    CoreDataHelper.saveSchoolData("School", school)
                    FilterStudentsViewController.schoolData.append(school)
                }
                
                for item in jsonArray {
                    let studentDataItem = StudentData(id: item["APS_Student_ID"], name: item["Name"],checked: false , sname: item["School_Name"])
                    StudentListViewController.data.append(studentDataItem)
                    StudentListViewController.idmap.updateValue(StudentListViewController.data.count-1, forKey: studentDataItem.id!)
                    CoreDataHelper.saveStudentData(item, "Student")
                }
                
                let downloadAlert = UIAlertController(title: "Success", message: "Student list successfully downloaded", preferredStyle: .alert)
                downloadAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(downloadAlert, animated: true)
                
                
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
