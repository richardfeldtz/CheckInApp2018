//
//  EventCollectionViewCell.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/24/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var eventNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .orange
    }
    
}
