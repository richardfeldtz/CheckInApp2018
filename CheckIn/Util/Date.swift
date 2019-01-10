//
//  Date.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/9/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import UIKit

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
