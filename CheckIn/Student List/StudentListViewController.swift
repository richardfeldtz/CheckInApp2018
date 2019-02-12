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

protocol FooTwoViewControllerDelegate:class {
    func myVCDidFinish(_ controller: ProfileViewController, text: String)
}

class StudentListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, FooTwoViewControllerDelegate {
    
    var easterEggView = UIImageView(image: UIImage(named: "car"))
    var tableAnimated = false
    
    func myVCDidFinish(_ controller: ProfileViewController, text: String) {
        //swift 3
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        print("back to student list")
        tableView.setNeedsDisplay()
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var roundButton: UIButton = {
        let roundButton = UIButton(type: .custom)
        roundButton.setTitleColor(UIColor.orange, for: .normal)
        roundButton.addTarget(self, action: #selector(openQRCodeScanner), for: .touchUpInside)
        return roundButton
    }()
    
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
        self.navigationItem.title = StudentListViewController.eventName
    
        //LJFFmobile easter egg setup
        self.view.bringSubviewToFront(easterEggView)
        easterEggView.frame = CGRect(x:0, y:0, width: 400, height: 360)
        self.view.addSubview(easterEggView)
        easterEggView.center.y = self.view.bounds.height - 100
        easterEggView.center.x = -200
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        self.tableView.reloadData()
        if !tableAnimated {
            animateTable()
            tableAnimated = true
        }
        tableView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(roundButton)
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
        
    }
    
    override func viewWillLayoutSubviews() {
        roundButton.layer.cornerRadius = 5// roundButton.layer.frame.size.width/2
        roundButton.backgroundColor = .gray
        roundButton.clipsToBounds = true
        roundButton.setImage(#imageLiteral(resourceName: "icons8-qr-code-filled-100"), for: .normal)
        roundButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            roundButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            roundButton.widthAnchor.constraint(equalToConstant: 100),
            roundButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func openQRCodeScanner() {
        let storyboard: UIStoryboard = UIStoryboard(name: "QRCodeScan", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "QRScannerViewController") as! QRScannerViewController
        self.show(vc, sender: self)
    }
    
    //Method to return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Method to return the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredStudents.count
        }
        return CoreDataHelper.countOfEntity("Student")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentListCell") as! StudentTableViewCell
        
        var student:StudentData?
        if isFiltering() {
            student = filteredStudents[indexPath.row]
        } else {
            if StudentListViewController.data.count == 0 {
                return UITableViewCell()
            }
            student = StudentListViewController.data[indexPath.row]
        }
        
        cell.fname.text = student!.fname
        cell.lname.text = student!.lname
        
        cell.checkMark.image = student!.checked ? UIImage(named: "checkmark") : nil
        
        cell.fname.numberOfLines=0;
        cell.fname.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.fname.minimumScaleFactor = 0.1
        cell.fname.adjustsFontSizeToFitWidth=true
        
        cell.lname.numberOfLines=0;
        cell.lname.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.lname.minimumScaleFactor = 0.1
        cell.lname.adjustsFontSizeToFitWidth=true
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            selectedStudent = filteredStudents[indexPath.row]
        }
        else {
            selectedStudent = StudentListViewController.data[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "showProfile", sender: self)
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
        else if segue.destination is GifViewController {
            
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
    
    func rotate360() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveLinear] , animations: {
            self.view.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: {
            (completed : Bool) in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear , animations: {
                self.view.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }, completion: nil)
        } )
    }
    
}

//Extension updates delegate when search text changes
extension StudentListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        //ShowLebron easter egg segue
        if searchController.searchBar.text! == "23" {
            GifViewController.imageName = "lj"
            self.performSegue(withIdentifier: "showLebron", sender: self)
        }
        else{
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
}
