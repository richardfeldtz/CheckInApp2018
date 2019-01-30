//
//  CheckedInStudentsViewController.swift
//  CheckIn
//
//  Created by Richard Feldtz on 1/28/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CheckedInStudentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	static var data: Array<CheckedInStudentData> = []
	
	override func viewDidLoad() {
		super.viewDidLoad();
		let checkins = CoreDataHelper.retrieveData("Checkins");
		let students = CoreDataHelper.retrieveData("Student");
		loadCheckInData(checkInData: checkins as! [Checkins],
						studentData: students as! [Student]);
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		DispatchQueue.main.async{
			self.tableView.reloadData()
		}
		tableView.setNeedsDisplay()
	}
	
	//Method to return the number of sections
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	//Method to return the number of rows
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return CoreDataHelper.countOfEntity("Checkins")
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "checkedInStudentCell") as! CheckedInTableViewCell
		
		var student: CheckedInStudentData?
		
		if CheckedInStudentsViewController.data.count == 0 {
			return UITableViewCell()
		}
		student = CheckedInStudentsViewController.data[indexPath.row]
		
		cell.fName.text = student!.fname
		cell.lName.text = student!.lname
		cell.guests.text = student!.guests
		
		cell.fName.numberOfLines=0;
		cell.fName.font = UIFont(name: "HelveticaNeue", size: 20)
		cell.fName.minimumScaleFactor = 0.1
		cell.fName.adjustsFontSizeToFitWidth=true
		
		cell.lName.numberOfLines=0;
		cell.lName.font = UIFont(name: "HelveticaNeue", size: 20)
		cell.lName.minimumScaleFactor = 0.1
		cell.lName.adjustsFontSizeToFitWidth=true
		
		cell.guests.numberOfLines=0;
		cell.guests.font = UIFont(name: "HelveticaNeue", size: 20)
		cell.guests.minimumScaleFactor = 0.1
		cell.guests.adjustsFontSizeToFitWidth=true
		return cell
	}
	
	func loadCheckInData(checkInData: [Checkins], studentData: [Student]) {
		CheckedInStudentsViewController.data.removeAll()
		for student in studentData {
			if (student.checked) {
				for checkin in checkInData {
					if (student.id == checkin.id) {
						let checkedInStudent = CheckedInStudentData(
												id: student.id,
												fname: student.fname,
												lname: student.lname,
												guests: String(checkin.guests));
						CheckedInStudentsViewController.data.append(checkedInStudent)
					}
				}
			}
		}
	}
}
