//
//  HelpEndViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 09/05/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class HelpEndViewController : UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var doneButtonView: UIImageView!
    
    
    override func viewWillLayoutSubviews() {
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 10
        
    }
    
    override func viewDidLoad() {
        doneButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBackHome)))
    }
    
    @objc func goBackHome() {
        navigationController?.popViewController(animated: true)
    }
    
}
