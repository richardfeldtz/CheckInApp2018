//
//  UpdateHelpViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 09/05/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import FLAnimatedImage

class UpdateHelpViewController : UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var gifView: FLAnimatedImageView!
    
    override func viewWillLayoutSubviews() {
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        let path1 : String = Bundle.main.path(forResource: "Update", ofType: "gif")!
        let url = URL(fileURLWithPath: path1)
        do{
            let gifData = try Data(contentsOf: url)
            let imageData = FLAnimatedImage(animatedGIFData: gifData)
            gifView.animatedImage = imageData
        }
        catch _ as NSError{
            print("Error setting gif image")
        }
    }
    
}
