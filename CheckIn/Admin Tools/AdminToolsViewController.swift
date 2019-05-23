//
//  AdminViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/11/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class AdminToolsViewController: UIViewController {
    
    @IBOutlet var uploadDataView: UIView!
    @IBOutlet var downloadDataView: UIView!
    @IBOutlet weak var clearCheckInsView: UIView!
    @IBOutlet weak var shareDataView: UIView!
    @IBOutlet var filterView: UIView!
    @IBOutlet var createEventView: UIView!
    @IBOutlet var eventDetailsView: UIView!
    @IBOutlet weak var checkInNumberView: UIView!
    @IBOutlet weak var checkInCount: UILabel!
    
    
    var key : String?
    var identifier : String?
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
        view.layer.shouldRasterize = false
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        formatView(view: uploadDataView)
        formatView(view: downloadDataView)
        formatView(view: clearCheckInsView)
        formatView(view: shareDataView)
        formatView(view: filterView)
        formatView(view: createEventView)
        formatView(view: eventDetailsView)
        checkInNumberView.layer.cornerRadius = 10
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        self.navigationController?.navigationItem.backBarButtonItem?.tintColor = .black
        self.key = LaunchViewController.key
        self.identifier = LaunchViewController.identifier
        let coreData = CoreDataHelper.retrieveData("Checkins");
        updateCheckInCount(checkInData: coreData as! [Checkins]);
    }
    
    fileprivate func setupGestureRecognizers() {
        uploadDataView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadData)))
        downloadDataView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(downloadData)))
        clearCheckInsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearCheckins)))
        shareDataView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareData)))
        filterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterStudentsTapped)))
        createEventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openCreateEventVC)))
        eventDetailsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEventDetailsVC)))
    }
    
    func checkInternetConnection() -> Bool {
        let connection = InternetConnectionTest.isInternetAvailable()
        if !connection {
            let internetAlert = UIAlertController(title: "No internet connection", message: "Your device is not connected to the internet. Please make sure you are connected to the internet to perform this action.", preferredStyle: .alert)
            internetAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(internetAlert, animated: true)
        }
        return connection
    }
    
    
    
    @objc func uploadData() {
        
        //Return if not connected to the internet
        if !checkInternetConnection(){
            return
        }
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Uploading Data...")
        SVProgressHUD.setSuccessImage(#imageLiteral(resourceName: "blackLogo"))
        
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
        
        if(idString != "") {
            idString.removeLast()
            guestNumbers.removeLast()
            
            let url = URL(string:RestHelper.urls["Attendance"]!)!
            var response = RestHelper.makePost(url, ["identifier": self.identifier!, "key": self.key!, "eventName": StudentListViewController.eventName, "studentIds": idString, "guestCounts": guestNumbers])
            
            response.removeFirst()
            response.removeLast()
            if response == "Success" {
                SVProgressHUD.showSuccess(withStatus: "Successfully uploaded Student Data!")
                SVProgressHUD.dismiss(withDelay: .init(floatLiteral: 2))
            }
            else {
                let uploadAlert = UIAlertController(title: "Error", message: "There was an error uploading the check-in records.", preferredStyle: .alert)
                uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(uploadAlert, animated: true)
            }
        }
        else {
            SVProgressHUD.dismiss(withDelay: .init(floatLiteral: 0))
            let uploadAlert = UIAlertController(title: "Error", message: "There are no check-in records to upload", preferredStyle: .alert)
            uploadAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(uploadAlert, animated: true)
        }
    }
    
    @objc func downloadData() {
        
        //Return if not connected to the internet
        if !checkInternetConnection(){
            return
        }
        
        let downloadDataAlert = UIAlertController(title: "Warning", message: "Downloading data will also clear all the check-in data on this device. Are you sure you want to continue?", preferredStyle: .alert)
        downloadDataAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        downloadDataAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            
            
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show(withStatus: "Downloading Data...")
            
            
            DispatchQueue.global(qos: .background).async {
                
                let url = URL(string:RestHelper.urls["Get_Students"]!)!
                let schoolURL = URL(string:RestHelper.urls["Get_Schools"]!)!
                let jsonString = RestHelper.makePost(url, ["identifier": self.identifier!, "key": self.key!])
                let schoolList = RestHelper.makePost(schoolURL, ["identifier": self.identifier!, "key": self.key!])
                
                CoreDataHelper.deleteAllData(from: "Checkins")
                CoreDataHelper.deleteAllData(from: "Student")
                CoreDataHelper.deleteAllData(from: "School")
                StudentListViewController.data.removeAll()
                StudentListViewController.idmap.removeAll()
                
                let data = jsonString.data(using: .utf8)!
                let schoolData = schoolList.data(using: .utf8)!
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,String>],
                        let schoolArray = try JSONSerialization.jsonObject(with: schoolData, options : .allowFragments) as? [String]{
                        
                        for school in schoolArray {
                            CoreDataHelper.saveSchoolData("School", school)
                            FilterStudentsViewController.schoolData.append(school)
                        }
                        
                        
                        for item in jsonArray {
                            let studentDataItem = StudentData(id: item["APS_Student_ID"], fname: item["FirstName"], lname: item["LastName"], checked: false , sname: item["School_Name"])
                            StudentListViewController.data.append(studentDataItem)
                            StudentListViewController.idmap.updateValue(StudentListViewController.data.count-1, forKey: studentDataItem.id!)
                            CoreDataHelper.saveStudentData(item, "Student")
                        }
                        
                        DispatchQueue.main.async {
                            SVProgressHUD.showSuccess(withStatus: "Downloaded Student Data!")
                            SVProgressHUD.dismiss(withDelay: .init(floatLiteral: 2))
                        }
                        
                    } else {
                        print("bad json")
                    }
                } catch let error as NSError {
                    print(error)
                }
                
            }
            
            return
        }))
        self.present(downloadDataAlert,animated: true)
        
        
        
    }
    
    @objc func clearCheckins() {
        
        let clearDataAlert = UIAlertController(title: "Warning", message: "You are about to clear all the check-in data on this device. Are you sure you want to continue?", preferredStyle: .alert)
        clearDataAlert.addAction(UIAlertAction(title: "No", style: .cancel))
        clearDataAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            let reconfirmAlert = UIAlertController(title: "Really?", message: "Are you absolutely sure you want to clear all the check-in data on this device?", preferredStyle: .alert)
            reconfirmAlert.addAction(UIAlertAction(title: "What? No!", style: .cancel))
            reconfirmAlert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: {
                action in
                self.clear()
                let confirmDeleteAlert = UIAlertController(title: "Success", message: "Check-in data deleted from device.", preferredStyle: .alert)
                confirmDeleteAlert.addAction(UIAlertAction(title: "Phew! Finally!", style: .cancel))
                self.present(confirmDeleteAlert, animated:true)
            }))
            self.present(reconfirmAlert, animated:true)
        }))
        self.present(clearDataAlert, animated:true)
        
        
    }
    
    func clear() {
        let localData = CoreDataHelper.retrieveData("Checkins")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        var checkInResult : [NSManagedObject]
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Student")
        for data in localData {
            let studentId = (data as AnyObject).value(forKey: "id") as! String
            (StudentListViewController.data[StudentListViewController.idmap[studentId]!]).checked = false
            fetchRequest.predicate = NSPredicate(format: "id == %@", studentId)
            do {
                checkInResult = try managedContext.fetch(fetchRequest)
                let studentCheckIn=checkInResult.first
                studentCheckIn?.setValue(false, forKey: "checked")
                
            }
            catch _ as NSError{
                print("Error changing checked flags")
            }
        }
        do{
            try managedContext.save()
        }
        catch _ as NSError {
            print("Error clearing data")
        }
        CoreDataHelper.deleteAllData(from: "Checkins")
    }
    
    @objc func filterStudentsTapped(){
        let storyboard: UIStoryboard = UIStoryboard(name: "FilterStudents", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FilterStudentsViewController") as! FilterStudentsViewController
        show(vc, sender: self)
    }
    
    @objc func openCreateEventVC() {
        
        //Return if not connected to the internet
        if !checkInternetConnection(){
            return
        }
        
        SelectEventViewController.apiCall = true
        
        let storyboard: UIStoryboard = UIStoryboard(name: "CreateEvent", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SelectEventViewController") as! SelectEventViewController
        show(vc, sender: self)
        
    }
    
    @objc func openEventDetailsVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "EventDetails", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventDetails") as! EventDetailsViewController
        self.show(vc, sender: self)
    }
    
    func updateCheckInCount(checkInData: [Checkins]) {
        checkInCount.text = String(checkInData.count);
    }
    
    @objc func shareData() {
        let storyboard: UIStoryboard = UIStoryboard(name: "DataShare", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DataShareViewController") as! DataShareViewController
        show(vc, sender: self)
    }
    
    
}
