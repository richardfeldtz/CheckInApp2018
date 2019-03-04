//
//  EventDetails.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var CardView: UIView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var CheckInCountView: UIView!
    @IBOutlet weak var GuestCountView: UIView!
    @IBOutlet weak var checkinCount: UILabel!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var checkInTable: UITableView!
    
    static var data: Array<CheckedInStudentData> = []
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        
        CheckInCountView.layer.cornerRadius = 10
        CheckInCountView.layer.shouldRasterize = false
        CheckInCountView.layer.borderWidth = 1
        
        GuestCountView.layer.cornerRadius = 10
        GuestCountView.layer.shouldRasterize = false
        GuestCountView.layer.borderWidth = 1
        
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
        let coreData = CoreDataHelper.retrieveData("Checkins");
        updateCounts(checkInData: coreData as! [Checkins]);
        let students = CoreDataHelper.retrieveData("Student");
        loadCheckInData(checkInData: coreData as! [Checkins],
                        studentData: students as! [Student]);
        checkInTable.dataSource = self
        checkInTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        eventName.text=StudentListViewController.eventName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventDetailsViewController.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkedInStudentCell") as! CheckedInTableViewCell
        
        var student: CheckedInStudentData?
        
        if EventDetailsViewController.data.count == 0 {
            return UITableViewCell()
        }
        
        student = EventDetailsViewController.data[indexPath.row]
        
        cell.fname.text = student!.fname
        cell.lname.text = student!.lname
        cell.guests.text = student!.guests
        
        cell.fname.numberOfLines=0;
        cell.fname.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.fname.minimumScaleFactor = 0.1
        cell.fname.adjustsFontSizeToFitWidth=true
        
        cell.lname.numberOfLines=0;
        cell.lname.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.lname.minimumScaleFactor = 0.1
        cell.lname.adjustsFontSizeToFitWidth=true
        
        cell.guests.numberOfLines=0;
        cell.guests.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.guests.minimumScaleFactor = 0.1
        cell.guests.adjustsFontSizeToFitWidth=true
        return cell
    }
    
    
    func updateCounts(checkInData: [Checkins]) {
        checkinCount.text = String(checkInData.count);
        
        var totalGuests = Int16();
        for checkIns in checkInData {
            totalGuests += checkIns.guests;
        }
        guestCount.text = String(totalGuests);
        
    }
    
    func loadCheckInData(checkInData: [Checkins], studentData: [Student]) {
        EventDetailsViewController.data.removeAll()
        for student in studentData {
            if (student.checked) {
                for checkin in checkInData {
                    if (student.id == checkin.id) {
                        let checkedInStudent = CheckedInStudentData(
                            id: student.id,
                            fname: student.fname,
                            lname: student.lname,
                            guests: String(checkin.guests));
                        EventDetailsViewController.data.append(checkedInStudent)
                    }
                }
            }
        }
    }
    
}
