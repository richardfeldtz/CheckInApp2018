//
//  CheckedInStudentData.swift
//  CheckIn
//
//  Created by Richard Feldtz on 1/30/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation

struct CheckedInStudentData {
	var id:String?
	var fname:String?
	var lname:String?
	var guests:String?
	
	init(id: String? = nil,
		 fname: String? = nil,
		 lname: String? = nil,
		 guests: String? = nil) {
		
		self.id = id
		self.fname = fname
		self.lname = lname
		self.guests = guests
	}
}
