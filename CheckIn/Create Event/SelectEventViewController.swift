//
//  SelectEventViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/23/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit
import CoreData

class SelectEventViewController: UICollectionViewController {
    
    var events = [String]()
    
    func formatView(view : UIView){
        view.layer.cornerRadius = 10
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
        formatView(view: cell)
        cell.eventNameLabel.text = events[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        StudentListViewController.eventName = events[indexPath.row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Device_Info")
        do {
            let deviceInfo = try managedContext.fetch(fetchRequest)
            let objectUpdate = deviceInfo[0] as! NSManagedObject
            objectUpdate.setValue(events[indexPath.row], forKey: "eventName")
            do{
                try managedContext.save()
                print("Device Updated!")
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "eventHeader", for: indexPath)
        return headerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 50, left: 100, bottom: 20, right: 100)
        layout.itemSize = CGSize(width: view.frame.width/4 - 30, height: view.frame.width/6)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 30
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 100)
        collectionView!.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let eventURL = URL(string:"https://dev1-ljff.cs65.force.com/test/services/apexrest/event")!
        let eventList = RestHelper.makePost(eventURL, ["identifier": "test", "key": "123456"])
        let eventData = eventList.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: eventData, options : .allowFragments) as? [String]{
                for event in jsonArray {
                    self.events.append(event)
                }
            }
        } catch {
            print("error")
        }
    }
}
