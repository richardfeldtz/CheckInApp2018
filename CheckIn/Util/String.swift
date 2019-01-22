//
//  String.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/22/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
extension StringProtocol where Index == String.Index {
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}
