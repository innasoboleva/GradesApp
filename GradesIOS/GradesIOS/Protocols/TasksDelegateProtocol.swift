//
//  TasksDelegateProtocol.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/29/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

protocol TasksDelegate {
    
    func tasksChanged (_ newTasks: [Task: [User: Int]], tasks: [Task], atSubject: Subject)
}

