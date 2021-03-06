//
//  Subject.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/22/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class Subject: Hashable {
    //MARK: Properties
    var uid: Int
    var name: String
    
    var hashValue: Int {
        return self.uid
    }
    
    //MARK: Initialization
    
    init?(uid: Int, name: String) {
        if name.isEmpty {
            return nil
        }
        self.uid = uid
        self.name = name
    }
}

extension Subject: Equatable {
    static func == (lhs: Subject, rhs: Subject) -> Bool {
        return lhs.name == rhs.name
    }
}

