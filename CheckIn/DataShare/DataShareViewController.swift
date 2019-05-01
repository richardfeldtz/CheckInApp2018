//
//  DataShareViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 07/02/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataShareViewController : UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var QRCode: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var transformedImage : CIImage!
    var codeData = ""
    
    override func viewDidLoad() {
        let checkinData = CoreDataHelper.retrieveData("Checkins") as! [Checkins];
        for dataEntry in checkinData {
            let id = dataEntry.id
            let guests = String(dataEntry.guests)
            codeData = codeData + id! + ":" + guests + ","
        }
        if(checkinData.count > 0) {
            codeData.removeLast()
        }
        
        textLabel.text = "Scan this code from another device to transfer the " + String(checkinData.count) + " check-ins."
        
        var codeImage : CIImage!
        
        let data = codeData.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        codeImage = filter!.outputImage
        
        let scaleX = QRCode.frame.size.width / codeImage.extent.width
        let scaleY = QRCode.frame.size.height / codeImage.extent.height
        
        transformedImage = codeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        QRCode.image = UIImage(ciImage : transformedImage)
    }
    
    override func viewWillLayoutSubviews() {
        formatView(view: cardView)
    }
    
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
        view.layer.shouldRasterize = false
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
    }
    
}
