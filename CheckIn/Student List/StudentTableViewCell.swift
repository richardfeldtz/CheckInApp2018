//
//  StudentTableViewCell.swift
//  CheckIn
//
//  Created by Anand Kelkar on 04/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import UIKit

class StudentTableViewCell: UITableViewCell {

    @IBOutlet var leftOfLastNameView: UIView!
    @IBOutlet var leftOfFirstNameView: UIView!
    @IBOutlet var leftOfCheckView: UIView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var fname: UILabel!
    @IBOutlet weak var lname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkMark.layer.cornerRadius = 10
        checkMark.layer.shouldRasterize = false
        checkMark.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
