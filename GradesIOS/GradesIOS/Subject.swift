//
//  Subject.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/22/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class Subject {
    //MARK: Properties
    var name: String
    
    //MARK: Initialization
    
    init?(name: String) {
        if name.isEmpty {
            return nil
        }
        self.name = name
    }
}

extension Subject: Equatable {
    static func == (lhs: Subject, rhs: Subject) -> Bool {
        return lhs.name == rhs.name
    }
}

