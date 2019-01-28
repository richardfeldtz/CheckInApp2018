//
//  SelectionScreen.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/23/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class SelectionScreen: UIViewController {
    
    
//    @IBOutlet var selectEventLabel: UILabel!
//    @IBOutlet var createEventLabel: UILabel!
//    @IBOutlet var createEventView: UIView!
//    @IBOutlet var selectEventView: UIView!
    
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
        view.layer.shouldRasterize = false
        view.layer.borderWidth = 1
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10
    }
    
    func setUpTouchHandlers() {
//        createEventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(createEventTapped)))
//        selectEventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectEventTapped)))
        
    }
    
//    @objc func createEventTapped() {
//        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
//        let navVc = UINavigationController(rootViewController: vc)
//        vc.navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-delete-filled-25"), style: .plain, target: self, action: #selector(removeScreen)), animated: true)
//        self.show(navVc, sender: self)
//
//    }
    
//    @objc func selectEventTapped() {
//        let storyboard = UIStoryboard(name: "CreateEvent", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "eventCollectionViewController") as! SelectEventViewController
//        let navVc = UINavigationController(rootViewController: vc)
//        vc.navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-delete-filled-25"), style: .plain, target: self, action: #selector(removeScreen)), animated: true)
//        self.show(navVc, sender: self)
//    }
    
    @objc func removeScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectionScreen.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectionScreen.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        //Code to dismiss keyboard when user clicks on the view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //setUpTouchHandlers()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //formatView(view: createEventView)
        //formatView(view: selectEventView)
    }
}
