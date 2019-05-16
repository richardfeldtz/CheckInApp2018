//
//  StudentListViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 04/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import AudioToolbox



class StudentListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var easterEggView = UIImageView(image: UIImage(named: "car"))
    var tableAnimated = false
    var helpIndicator = false
    var roundButton = UIButton.init()
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareImage: UIImageView!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var scrollImage: UIImageView!
    @IBOutlet weak var fnameImage: UIImageView!
    @IBOutlet weak var lnameImage: UIImageView!
    
    private lazy var firstNameLabel: UILabel = {
        let label = UILabel()
        label.text = "First Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    static var data: Array<StudentData> = []
    static var idmap = [String : Int]()
    static var eventName = ""
    
    //Variable used to identify selected student before passing it to the profile view
    var selectedStudent: StudentData?
    
    //Variable used to store the filtered list
    var filteredStudents = [StudentData]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        StudentListViewController.searchController.searchBar.text=nil
        titleLabel.text = StudentListViewController.eventName
        if(ColorHelper.color){
            titleLabel.font = UIFont.init(name: "Chalkduster", size: 25)
        }
    
        //LJFFmobile easter egg setup
        self.view.bringSubviewToFront(easterEggView)
        easterEggView.frame = CGRect(x:0, y:0, width: 400, height: 360)
        self.view.addSubview(easterEggView)
        easterEggView.center.y = self.view.bounds.height - 100
        easterEggView.center.x = -200
        
        //Paint screen
        paintScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        if !tableAnimated {
            animateTable()
            tableAnimated = true
        }
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Setup the Search Controller
        StudentListViewController.searchController.searchResultsUpdater = self
        StudentListViewController.searchController.obscuresBackgroundDuringPresentation = false
        StudentListViewController.searchController.searchBar.placeholder = "Search Students"
        navigationItem.searchController = StudentListViewController.searchController
        definesPresentationContext = true
        
        //LJFFmobile easter egg action recognizer
        let easterSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(showBatMobile(_ :)))
        easterSwipe.edges = .left
        self.view.addGestureRecognizer(easterSwipe)
        
        //Scroll to top gesture recognizer
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollToTop)))
        
        self.view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(showHelpLayer(_:))))
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 15)!], for: .normal)
        
        addButton()
        
    }
    
    /*Add stuff on screen shake
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            //Vibrate
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }*/
    
    func addButton()  {
        
        roundButton = UIButton(frame: .init(x: 0, y: 0, width: 50, height: 50))
        roundButton.addTarget(self, action: #selector(openQRCodeScanner), for: .touchUpInside)
        roundButton.layer.cornerRadius = roundButton.bounds.size.width
        roundButton.backgroundColor = .gray
        roundButton.setImage(#imageLiteral(resourceName: "icons8-qr-code-filled-100"), for: .normal)
        roundButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        roundButton.imageView?.layer.masksToBounds = true
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        roundButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        roundButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        roundButton.layer.shadowOpacity = 1.0
        roundButton.layer.shadowRadius = 0.0
        roundButton.layer.masksToBounds = false
        
        view.addSubview(roundButton)
        NSLayoutConstraint.activate([
            roundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            roundButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            roundButton.widthAnchor.constraint(equalToConstant: 100),
            roundButton.heightAnchor.constraint(equalToConstant: 100)
            ])
    }
    @objc func openQRCodeScanner() {
        if(!helpIndicator) {
            let storyboard: UIStoryboard = UIStoryboard(name: "QRCodeScan", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
            self.show(vc, sender: self)
        }
    }
    
    //Method to return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Method to return the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering() ? filteredStudents.count : StudentListViewController.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if StudentListViewController.data.count == 0 {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentListCell") as! StudentTableViewCell
        
        
        let student:StudentData? = isFiltering() ? filteredStudents[indexPath.row] : StudentListViewController.data[indexPath.row]

        //Uncomment below block to color student list
        /*
        if(ColorHelper.color){
            cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.white : ColorHelper.navBarColor.withAlphaComponent(0.1)
        }
        else{
            cell.backgroundColor = indexPath.row % 2 == 0 ? .white : UIColor.lightGray.withAlphaComponent(0.1)
        }
        cell.fname.textColor=ColorHelper.labelColor
        cell.lname.textColor=ColorHelper.labelColor
        */

        //Comment below line to allow color switch
        cell.backgroundColor = indexPath.row % 2 == 0 ? .white : UIColor.lightGray.withAlphaComponent(0.1)
        
        cell.fname.text = student!.fname
        cell.lname.text = student!.lname
        cell.checkMark.image = student!.checked ? UIImage(named: "checkmark") : nil
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            selectedStudent = filteredStudents[indexPath.row]
        }
        else {
            selectedStudent = StudentListViewController.data[indexPath.row]
        }
        if !helpIndicator{
            self.performSegue(withIdentifier: "showProfile", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let profile = segue.destination as? ProfileViewController
        {
            profile.name = (selectedStudent?.name)!
            profile.id = (selectedStudent?.id)!
            profile.sname = (selectedStudent?.sname)!
        }
    }
    
    @IBAction func pressedAdminTools(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "AdminTools", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdminToolsViewController") as! AdminToolsViewController
        self.show(vc, sender: self)
    }
    
    static let searchController = UISearchController(searchResultsController: nil)
    
    //Function checks if list has been filtered via search text
    func isFiltering() -> Bool {
        return StudentListViewController.searchController.isActive && !searchBarIsEmpty()
    }
    
    //Function checks if search text is empty
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return StudentListViewController.searchController.searchBar.text?.isEmpty ?? true
    }
    
    //Function to create filtered list based on search text
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStudents = StudentListViewController.data.filter({( student : StudentData) -> Bool in
            return (student.name!.lowercased().contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }
    
    //LJFFmobile easter egg animation
    @objc func showBatMobile(_ recognizer : UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            UIView.animate(withDuration: 3, delay: 0.4, options: [.curveEaseOut],
                       animations: {
                        self.easterEggView.center.x = self.view.bounds.width + 200
            },completion: {
                (finished : Bool) in
                    self.easterEggView.center.x = -200
                })
        }
    }
    
    @objc func scrollToTop() {
        if(!helpIndicator) {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @objc func showHelpLayer(_ recognizer : UIPinchGestureRecognizer) {
        if recognizer.state == .ended {
            scrollToTop()
            if (recognizer.scale < 1.0) {
                if !helpIndicator {
                    self.tableView.allowsSelection = false
                    self.tableView.isScrollEnabled = false
                    self.navigationItem.leftBarButtonItem?.isEnabled = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    helpIndicator = true
                    self.tableView.alpha = 0.1
                    shareImage.isHidden = false
                    qrImage.isHidden = false
                    scrollImage.isHidden = false
                    fnameImage.isHidden = false
                    lnameImage.isHidden = false
                }
            }
            else {
                if helpIndicator {
                    self.tableView.allowsSelection = true
                    self.tableView.isScrollEnabled = true
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    helpIndicator = false
                    self.tableView.alpha = 1
                    shareImage.isHidden = true
                    qrImage.isHidden = true
                    scrollImage.isHidden = true
                    fnameImage.isHidden = true
                    lnameImage.isHidden = true
                }
            }
        }
    }
    
    
    
    
    func animateTable() {
        let cells = self.tableView.visibleCells
        
        let tableHeight = self.tableView.bounds.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var delay = 0
        for cell in cells {
            UIView.animate(withDuration: 1.75, delay: Double(delay) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delay += 1
        }
    }
    
    func rotate360(view: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear] , animations: {
            view.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: {
            (completed : Bool) in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear , animations: {
                view.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }, completion: nil)
        } )
    }
    
    func paintScreen(){
        if(ColorHelper.color){
            self.navigationController?.navigationBar.barTintColor=ColorHelper.navBarColor
            titleLabel.textColor = ColorHelper.navTextColor
            self.navigationController?.navigationBar.tintColor = ColorHelper.navTextColor
            self.navigationItem.leftBarButtonItem?.tintColor = ColorHelper.navTextColor
            self.navigationItem.rightBarButtonItem?.tintColor = ColorHelper.navTextColor
            roundButton.backgroundColor=ColorHelper.navBarColor
            (StudentListViewController.searchController.searchBar.value(forKey: "cancelButton") as! UIButton).tintColor=ColorHelper.navTextColor
            (StudentListViewController.searchController.searchBar.value(forKey: "searchField") as! UITextField).textColor = ColorHelper.navTextColor
            StudentListViewController.searchController.searchBar.tintColor=ColorHelper.navTextColor
        }
    }
    
}

//Extension updates delegate when search text changes
extension StudentListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        //ShowLebron easter egg segue
        if searchController.searchBar.text! == "23" {
            GifViewController.imageName = "lj"
            ColorHelper.switchToColor();
            self.performSegue(withIdentifier: "showLebron", sender: self)
        }
        else{
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
}
