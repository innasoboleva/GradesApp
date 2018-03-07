//
//  StudentsChangedProtocol.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 2/1/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

protocol StudentsChanged {
    
    func studentsChanged(list_added: Set<User>, list_removed: Set<User>)
}
