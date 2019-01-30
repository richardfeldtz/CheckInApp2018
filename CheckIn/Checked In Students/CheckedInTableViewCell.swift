//
//  CheckedInTableViewCell.swift
//  CheckIn
//
//  Created by Richard Feldtz on 1/30/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class CheckedInTableViewCell: UITableViewCell {
	
	@IBOutlet weak var fName: UILabel!
	@IBOutlet weak var lName: UILabel!
	@IBOutlet weak var guests: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
}
