//
//  TasksDelegateProtocol.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/29/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

protocol TasksDelegate {
    
    func tasksChanged (_ newTasks: [Subject], new_students: [Subject], new_grades: [[Int]], atRow: Int)
    
}

