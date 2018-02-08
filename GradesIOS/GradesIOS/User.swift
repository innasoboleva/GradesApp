//
//  User.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 2/8/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class User: Hashable {
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

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
}
