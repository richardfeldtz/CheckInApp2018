//
//  LaunchViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 03/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class LaunchViewController :UIViewController
{
    
    @IBOutlet weak var animatedView: UIView!
    
    let imagelayer=CALayer()
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        generateLogo()
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        imagelayer.position=animatedView.center
    }
    
    func generateLogo()
    {
        imagelayer.frame=animatedView.bounds
        animatedView.layer.addSublayer(imagelayer)
        
        imagelayer.contents = UIImage(named: "LJFF_logo")?.cgImage
        imagelayer.contentsGravity = CALayerContentsGravity.resizeAspect
        imagelayer.backgroundColor=UIColor.black.cgColor
        imagelayer.shadowOpacity = 0.7
        imagelayer.shadowRadius = 10.0
        imagelayer.cornerRadius = imagelayer.frame.width/2
        imagelayer.isHidden = false
        imagelayer.masksToBounds = false
        animatedView.alpha = 0.0
        
        UIView.animate(withDuration: 2.0, animations: {
            self.animatedView.alpha = 1.0
        }, completion: { finished in
            
            let coreData = CoreDataHelper.retrieveData("Student")
            for data in coreData {
                let studentDataItem = StudentData(id: (data as AnyObject).value(forKey: "id") as? String, name: (data as AnyObject).value(forKey: "name") as? String,checked: ((data as AnyObject).value(forKey: "checked") as! Bool) , sname: (data as AnyObject).value(forKey: "sname") as? String)
                StudentListViewController.data.append(studentDataItem)
                StudentListViewController.idmap.updateValue(StudentListViewController.data.count-1, forKey: studentDataItem.id!)
            }
            
            self.performSegue(withIdentifier: "ShowList", sender: self)
        })

        
    }
    
    
}


