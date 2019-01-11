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


class StudentListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    
    var data: Array<StudentData> = []
    
    //Variable used to identify selected student before passing it to the profile view
    var selectedStudent: StudentData?
    
    //Variable used to store the filtered list
    var filteredStudents = [StudentData]()
    
    func fetchCurrentCoreData() {
        let currentStudentEntities = CoreDataHelper.retrieveStudentData()
        if let currentStudentArray = currentStudentEntities {
            
            for item in currentStudentArray{
                data.append(StudentData(id: item.id, name: item.name, checked: item.checked ,sname: item.sname))
                print(item.checked)

            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCurrentCoreData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //generateDummyData()
        view.addSubview(roundButton)
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationItem.title = "Hometown Hall 2018"
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Students"
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
            if data.count == 0 {
                return UITableViewCell()
            }
            student = data[indexPath.row]
        }
        cell.fname.text = student!.name
        cell.checkMark.image = student!.checked ? UIImage(named: "checkmark") : nil
        
        cell.fname.numberOfLines=0;
        cell.fname.font = UIFont(name: "HelveticaNeue", size: 20)
        cell.fname.minimumScaleFactor = 0.1
        cell.fname.adjustsFontSizeToFitWidth=true
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            selectedStudent = filteredStudents[indexPath.row]
        }
        else {
            selectedStudent = data[indexPath.row]
        }
        
        selectedStudent = data[indexPath.row]
        
        
        self.performSegue(withIdentifier: "showProfile", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let profile = segue.destination as? ProfileViewController
        {
            
            profile.fname = (selectedStudent?.name)!
            profile.id = (selectedStudent?.id)!
            
        }
    }
    
    @IBAction func pressedAdminTools(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "AdminTools", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdminToolsViewController") as! AdminToolsViewController
        self.show(vc, sender: self)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    //Function checks if list has been filtered via search text
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //Function checks if search text is empty
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //Function to create filtered list based on search text
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStudents = data.filter({( student : StudentData) -> Bool in
            return (student.name!.lowercased().contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        headerView.addSubview(firstNameLabel)
        NSLayoutConstraint.activate([
            firstNameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            firstNameLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 0.1 * headerView.frame.width + 10),
            ])
        
        return headerView
    }
    
}

//Extension updates delegate when search text changes
extension StudentListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
