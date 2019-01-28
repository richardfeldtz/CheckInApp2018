//
//  EventDetails.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var checkInCount: UILabel!
    @IBOutlet weak var guestCount: UILabel!
	@IBOutlet weak var guestView: UIView!
	@IBOutlet weak var checkedInStudentsView: UIView!
	
	func formatView(view : UIView){
		view.layer.cornerRadius = 10
		view.layer.shouldRasterize = false
		view.layer.borderWidth = 1
		
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 1
		view.layer.shadowOffset = CGSize.zero
		view.layer.shadowRadius = 10
	}
	
	override func viewDidLayoutSubviews() {
		formatView(view: guestView)
		formatView(view: checkedInStudentsView)
	}
	
    override func viewDidLoad() {
		super.viewDidLoad();
		let coreData = CoreDataHelper.retrieveData("Checkins");
		updateCheckInCount(checkInData: coreData as! [Checkins]);
		updateGuestCount(checkInData: coreData as! [Checkins]);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func updateCheckInCount(checkInData: [Checkins]) {
		checkInCount.text = String(checkInData.count);
	}
	
	func updateGuestCount(checkInData: [Checkins]) {
		var totalGuests = Int16();
		for checkIns in checkInData {
			totalGuests += checkIns.guests;
		}
		guestCount.text = String(totalGuests);
	}
}
