//
//  FilterStudentsViewController.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/7/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

class FilterStudentsViewController: UIViewController {

    lazy var xButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icons8-delete-filled-25"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(self.removeScreen), for: .touchUpInside)
        return button
    }()
    
    @objc func removeScreen(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(xButton)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NSLayoutConstraint.activate([
            xButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            xButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            xButton.widthAnchor.constraint(equalToConstant: 25),
            xButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

}
