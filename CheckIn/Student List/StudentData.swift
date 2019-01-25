//
//  StudentData.swift
//  CheckIn
//
//  Created by Alexander Stevens on 12/11/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation

struct StudentData {
    var name:String?
    var id:String?
    var fname:String?
    var lname:String?
    var checked:Bool = false
    var sname:String?
    
    init(name: String? = nil,
        id: String? = nil,
        fname: String? = nil,
        lname: String? = nil,
        checked: Bool = false,
        sname: String? = nil) {
        
        self.id = id
        self.fname = fname
        self.lname = lname
        self.checked = checked
        self.sname = sname
        self.name = self.fname!+" "+self.lname!
    }
}
