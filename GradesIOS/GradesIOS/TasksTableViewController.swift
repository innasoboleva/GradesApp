//
//  TasksTableViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit
import os.log

class TasksTableViewController: UITableViewController, StudentsChanged {
    // protocol StudentsChanged
    func studentsChanged(list_added: Set<User>, list_removed: Set<User>) {
        var students_added_array = [String]()
        var students_removed_array = [String]()
        for student in list_added {
            students_added_array.append(String(student.uid))
        }
        for student in list_removed {
            students_removed_array.append(String(student.uid))
        }
        // for sending subject_id as a String
        var sub_id = String()
        if let subjects_id = subject?.uid {
            sub_id = String(describing: subjects_id)
        }
        
        // for keeping database up to date
        let json: [String: Any] = ["subject_id": sub_id, "subject_name": subject?.name as Any, "students_id": students_added_array]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // post request to change students in a database
        let url = URL(string: "http://127.0.0.1:8000/polls/add_student/")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                os_log("Request error", log: OSLog.default, type: .debug)
                if error?._code == NSURLErrorTimedOut {
                    self.present_alert("Server is not responding. Please, try again later.")
                }
                else if error?._code == NSURLErrorCannotConnectToHost {
                    self.present_alert("Server is not responding. Please, try again later.")
                }
                else if error?._code == NSURLErrorNetworkConnectionLost {
                    // make second request, if connection was lost - try again
                    let taskTry = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            os_log("Request error", log: OSLog.default, type: .debug)
                            self.present_alert("Please, try again later")
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            
                            if responseJSON["status"] as? String == "ok" {
                                
                                // for keeping dictionary data up to date with the changes
                                for user in list_added {
                                    let dict_keys = self.dict_tasks.keys
                                    for key in dict_keys {
                                        self.dict_tasks[key]![user] = 0
                                    }
                                }
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                // adding students first then removing
                                let json_remove: [String: Any] = ["subject_id": sub_id, "students_id": students_removed_array]
                                let jsonDataRemove = try? JSONSerialization.data(withJSONObject: json_remove)
                                // post request to change students in a database
                                let url_remove = URL(string: "http://127.0.0.1:8000/polls/remove_student/")!
                                var request_remove = URLRequest(url: url_remove)
                                request_remove.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                request_remove.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                request_remove.httpMethod = "POST"
                                request_remove.httpBody = jsonDataRemove
                                
                                let task_remove = URLSession.shared.dataTask(with: request_remove) { data, response, error in
                                    guard let data = data, error == nil else {
                                        os_log("Request error", log: OSLog.default, type: .debug)
                                        if error?._code == NSURLErrorTimedOut {
                                            self.present_alert("Server is not responding. Please, try again later.")
                                        }
                                        else if error?._code == NSURLErrorCannotConnectToHost {
                                            self.present_alert("Server is not responding. Please, try again later.")
                                        }
                                        else if error?._code == NSURLErrorNetworkConnectionLost {
                                            // make second request, if connection was lost - try again
                                            
                                            let task_removeTry = URLSession.shared.dataTask(with: request_remove) { data, response, error in
                                                guard let data = data, error == nil else {
                                                    os_log("Request error", log: OSLog.default, type: .debug)
                                                    self.present_alert("Please, try again later.")
                                                    print(error?.localizedDescription ?? "No data")
                                                    return
                                                }
                                                
                                                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                                if let responseJSON = responseJSON as? [String: Any] {
                                                    
                                                    if responseJSON["status"] as? String == "ok" {
                                                        // for keeping Dict instance up to date with the changes
                                                        for user in list_removed {
                                                            let dict_keys = self.dict_tasks.keys
                                                            for key in dict_keys {
                                                                let _ = self.dict_tasks[key]!.removeValue(forKey: user)
                                                            }
                                                        }
                                                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                    } else if responseJSON["status"] as? String == "not exist" {
                                                        
                                                        // if tasks do not exist - no need to execute, no students records
                                                        if self.tasks.count > 0 {
                                                            
                                                            DispatchQueue.main.async {
                                                                
                                                                let jsonStudents: [String: Any] = ["subject_id": sub_id, "task_name": self.tasks[0].name]
                                                                let jsonDataStudents = try? JSONSerialization.data(withJSONObject: jsonStudents)
                                                                // post request to get users
                                                                let urlStudents = URL(string: "http://127.0.0.1:8000/polls/get_students/")!
                                                                var requestStudents = URLRequest(url: urlStudents)
                                                                requestStudents.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                                requestStudents.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                                                requestStudents.httpMethod = "POST"
                                                                requestStudents.httpBody = jsonDataStudents
                                                                
                                                                let taskStudents = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                                    guard let data2 = data2, error2 == nil else {
                                                                        os_log("Request error", log: OSLog.default, type: .debug)
                                                                        if error2?._code == NSURLErrorTimedOut {
                                                                            self.present_alert("Server is not responding. Please, try again later.")
                                                                        }
                                                                        else if error2?._code == NSURLErrorCannotConnectToHost {
                                                                            self.present_alert("Server is not responding. Please, try again later.")
                                                                        }
                                                                        else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                                            // make second request, if connection was lost - try again
                                                                            
                                                                            let taskStudentsTry = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                                                guard let data2 = data2, error2 == nil else {
                                                                                    os_log("Request error", log: OSLog.default, type: .debug)
                                                                                    self.present_alert("Please, try again later")
                                                                                    print(error2?.localizedDescription ?? "No data")
                                                                                    return
                                                                                }
                                                                                let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                                                if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                                                    
                                                                                    if responseJSON2["status"] as? String == "ok" {
                                                                                        // id, name
                                                                                        let new_user_list = responseJSON2["users"] as? [[String]]
                                                                                        
                                                                                        var new_users = [User: Int]()
                                                                                        for each_user in new_user_list! {
                                                                                            let new_student = User(uid: Int(each_user[0])!,
                                                                                                                   name: each_user[1])
                                                                                            // make a dictionary
                                                                                            new_users[new_student!] = 1
                                                                                        }
                                                                                        
                                                                                        let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                                        for each_old_user in old_users! {
                                                                                            if let _ = new_users[each_old_user] {
                                                                                                continue
                                                                                            }
                                                                                            else {
                                                                                                // delete users from main dictionary
                                                                                                let keys_in_dict = self.dict_tasks.keys
                                                                                                for key in keys_in_dict {
                                                                                                    let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                                                    }
                                                                                    else if responseJSON2["detail"] as? String == "Signature has expired."
                                                                                    {
                                                                                        self.logout()
                                                                                    }
                                                                                }
                                                                            }
                                                                            taskStudentsTry.resume()
                                                                                
                                                                        }
                                                                        print(error2?.localizedDescription ?? "No data")
                                                                        return
                                                                    }
                                                                    //actual response
                                                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                                        
                                                                        if responseJSON2["status"] as? String == "ok" {
                                                                            // id, name
                                                                            let new_user_list = responseJSON2["users"] as? [[String]]
                                                                            
                                                                            var new_users = [User: Int]()
                                                                            for each_user in new_user_list! {
                                                                                let new_student = User(uid: Int(each_user[0])!,
                                                                                                       name: each_user[1])
                                                                                // make a dictionary
                                                                                new_users[new_student!] = 1
                                                                            }
                                                                            
                                                                            let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                            for each_old_user in old_users! {
                                                                                if let _ = new_users[each_old_user] {
                                                                                    continue
                                                                                }
                                                                                else {
                                                                                    // delete users from main dictionary
                                                                                    let keys_in_dict = self.dict_tasks.keys
                                                                                    for key in keys_in_dict {
                                                                                        let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                                    }
                                                                                }
                                                                            }
                                                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                                        }
                                                                        else if responseJSON2["detail"] as? String == "Signature has expired."
                                                                        {
                                                                            self.logout()
                                                                        }
                                                                    }
                                                                }
                                                                taskStudents.resume()
                                                            }
                                                        }
                                                    }
                                                    else if responseJSON["detail"] as? String == "Signature has expired."
                                                    {
                                                        self.logout()
                                                    }
                                                    else {
                                                        // Unable to remove students in a database
                                                        print(error?.localizedDescription ?? "Unable to remove students in a database")
                                                        self.present_alert("Could not add/remove students in a list, please try again.")
                                                    }
                                                }
                                            }
                                            task_removeTry.resume()
                                            
                                        }
                                        print(error?.localizedDescription ?? "No data")
                                        return
                                    }
                                    // actual response
                                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                    if let responseJSON = responseJSON as? [String: Any] {
                                        
                                        if responseJSON["status"] as? String == "ok" {
                                            // for keeping Dict instance up to date with the changes
                                            for user in list_removed {
                                                let dict_keys = self.dict_tasks.keys
                                                for key in dict_keys {
                                                    let _ = self.dict_tasks[key]!.removeValue(forKey: user)
                                                }
                                            }
                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                        } else if responseJSON["status"] as? String == "not exist" {
                                            
                                            // if tasks do not exist - no need to execute, no students records
                                            if self.tasks.count > 0 {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    let jsonStudents: [String: Any] = ["subject_id": sub_id, "task_name": self.tasks[0].name]
                                                    let jsonDataStudents = try? JSONSerialization.data(withJSONObject: jsonStudents)
                                                    // post request to get users
                                                    let urlStudents = URL(string: "http://127.0.0.1:8000/polls/get_students/")!
                                                    var requestStudents = URLRequest(url: urlStudents)
                                                    requestStudents.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                    requestStudents.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                                    requestStudents.httpMethod = "POST"
                                                    requestStudents.httpBody = jsonDataStudents
                                                    
                                                    let taskStudents = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                        guard let data2 = data2, error2 == nil else {
                                                            os_log("Request error", log: OSLog.default, type: .debug)
                                                            if error2?._code == NSURLErrorTimedOut {
                                                                self.present_alert("Server is not responding. Please, try again later.")
                                                            }
                                                            else if error2?._code == NSURLErrorCannotConnectToHost {
                                                                self.present_alert("Server is not responding. Please, try again later.")
                                                            }
                                                            else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                                // make second request, if connection was lost - try again
                                                                let taskStudentsTry = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                                    guard let data2 = data2, error2 == nil else {
                                                                        os_log("Request error", log: OSLog.default, type: .debug)
                                                                        self.present_alert("Please, try again later.")
                                                                        print(error2?.localizedDescription ?? "No data")
                                                                        return
                                                                    }
                                                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                                        
                                                                        if responseJSON2["status"] as? String == "ok" {
                                                                            // id, name
                                                                            let new_user_list = responseJSON2["users"] as? [[String]]
                                                                            
                                                                            var new_users = [User: Int]()
                                                                            for each_user in new_user_list! {
                                                                                let new_student = User(uid: Int(each_user[0])!,
                                                                                                       name: each_user[1])
                                                                                // make a dictionary
                                                                                new_users[new_student!] = 1
                                                                            }
                                                                            
                                                                            let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                            for each_old_user in old_users! {
                                                                                if let _ = new_users[each_old_user] {
                                                                                    continue
                                                                                }
                                                                                else {
                                                                                    // delete users from main dictionary
                                                                                    let keys_in_dict = self.dict_tasks.keys
                                                                                    for key in keys_in_dict {
                                                                                        let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                                    }
                                                                                }
                                                                            }
                                                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                                        }
                                                                        else if responseJSON2["detail"] as? String == "Signature has expired."
                                                                        {
                                                                            self.logout()
                                                                        }
                                                                    }
                                                                }
                                                                taskStudentsTry.resume()
                                                                
                                                            }
                                                            
                                                            print(error2?.localizedDescription ?? "No data")
                                                            return
                                                        }
                                                            // actual response
                                                        let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                        if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                            
                                                            if responseJSON2["status"] as? String == "ok" {
                                                                // id, name
                                                                let new_user_list = responseJSON2["users"] as? [[String]]
                                                                
                                                                var new_users = [User: Int]()
                                                                for each_user in new_user_list! {
                                                                    let new_student = User(uid: Int(each_user[0])!,
                                                                                           name: each_user[1])
                                                                    // make a dictionary
                                                                    new_users[new_student!] = 1
                                                                }
                                                                
                                                                let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                for each_old_user in old_users! {
                                                                    if let _ = new_users[each_old_user] {
                                                                        continue
                                                                    }
                                                                    else {
                                                                        // delete users from main dictionary
                                                                        let keys_in_dict = self.dict_tasks.keys
                                                                        for key in keys_in_dict {
                                                                            let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                        }
                                                                    }
                                                                }
                                                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                            }
                                                            else if responseJSON2["detail"] as? String == "Signature has expired."
                                                            {
                                                                self.logout()
                                                            }
                                                        }
                                                    }
                                                    taskStudents.resume()
                                                }
                                            }
                                        }
                                        else if responseJSON["detail"] as? String == "Signature has expired."
                                        {
                                            self.logout()
                                        }
                                        else {
                                            // Unable to remove students in a database
                                            print(error?.localizedDescription ?? "Unable to remove students in a database")
                                            self.present_alert("Could not add/remove students in a list, please try again.")
                                        }
                                    }
                                }
                                task_remove.resume()
                                
                            } else if responseJSON["detail"] as? String == "Signature has expired."
                            {
                                self.logout()
                            }
                            else {
                                // Unable to add students in a database
                                print(error?.localizedDescription ?? "Unable to add students in a database")
                                self.present_alert("Could not add/remove students in a list, please try again.")
                            }
                        }
                    }
                    taskTry.resume()
                }
                print(error?.localizedDescription ?? "No data")
                return
            }
                // actual response
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                
                if responseJSON["status"] as? String == "ok" {
                    
                    // for keeping dictionary data up to date with the changes
                    for user in list_added {
                        let dict_keys = self.dict_tasks.keys
                        for key in dict_keys {
                            self.dict_tasks[key]![user] = 0
                        }
                    }
                    self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                    // adding students first then removing
                    let json_remove: [String: Any] = ["subject_id": sub_id, "students_id": students_removed_array]
                    let jsonDataRemove = try? JSONSerialization.data(withJSONObject: json_remove)
                    // post request to change students in a database
                    let url_remove = URL(string: "http://127.0.0.1:8000/polls/remove_student/")!
                    var request_remove = URLRequest(url: url_remove)
                    request_remove.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request_remove.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                    request_remove.httpMethod = "POST"
                    request_remove.httpBody = jsonDataRemove
                    
                    let task_remove = URLSession.shared.dataTask(with: request_remove) { data, response, error in
                        guard let data = data, error == nil else {
                            os_log("Request error", log: OSLog.default, type: .debug)
                            if error?._code == NSURLErrorTimedOut {
                                self.present_alert("Server is not responding. Please, try again later.")
                            }
                            else if error?._code == NSURLErrorCannotConnectToHost {
                                self.present_alert("Server is not responding. Please, try again later.")
                            }
                            else if error?._code == NSURLErrorNetworkConnectionLost {
                                // make second request, if connection was lost - try again
                                let task_removeTry = URLSession.shared.dataTask(with: request_remove) { data, response, error in
                                    guard let data = data, error == nil else {
                                        os_log("Request error", log: OSLog.default, type: .debug)
                                        self.present_alert("Please, try again later.")
                                        print(error?.localizedDescription ?? "No data")
                                        return
                                    }
                                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                    if let responseJSON = responseJSON as? [String: Any] {
                                        
                                        if responseJSON["status"] as? String == "ok" {
                                            // for keeping Dict instance up to date with the changes
                                            for user in list_removed {
                                                let dict_keys = self.dict_tasks.keys
                                                for key in dict_keys {
                                                    let _ = self.dict_tasks[key]!.removeValue(forKey: user)
                                                }
                                            }
                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                        } else if responseJSON["status"] as? String == "not exist" {
                                            
                                            // if tasks do not exist - no need to execute, no students records
                                            if self.tasks.count > 0 {
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    let jsonStudents: [String: Any] = ["subject_id": sub_id, "task_name": self.tasks[0].name]
                                                    let jsonDataStudents = try? JSONSerialization.data(withJSONObject: jsonStudents)
                                                    // post request to get users
                                                    let urlStudents = URL(string: "http://127.0.0.1:8000/polls/get_students/")!
                                                    var requestStudents = URLRequest(url: urlStudents)
                                                    requestStudents.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                    requestStudents.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                                    requestStudents.httpMethod = "POST"
                                                    requestStudents.httpBody = jsonDataStudents
                                                    
                                                    let taskStudents = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                        guard let data2 = data2, error2 == nil else {
                                                            os_log("Request error", log: OSLog.default, type: .debug)
                                                            if error2?._code == NSURLErrorTimedOut {
                                                                self.present_alert("Server is not responding. Please, try again later.")
                                                            }
                                                            else if error2?._code == NSURLErrorCannotConnectToHost {
                                                                self.present_alert("Server is not responding. Please, try again later.")
                                                            }
                                                            else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                                // make second request, if connection was lost - try again
                                                                let taskStudentsTry = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                                    guard let data2 = data2, error2 == nil else {
                                                                        os_log("Request error", log: OSLog.default, type: .debug)
                                                                        self.present_alert("Please, try again later.")
                                                                        print(error2?.localizedDescription ?? "No data")
                                                                        return
                                                                    }
                                                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                                        
                                                                        if responseJSON2["status"] as? String == "ok" {
                                                                            // id, name
                                                                            let new_user_list = responseJSON2["users"] as? [[String]]
                                                                            
                                                                            var new_users = [User: Int]()
                                                                            for each_user in new_user_list! {
                                                                                let new_student = User(uid: Int(each_user[0])!,
                                                                                                       name: each_user[1])
                                                                                // make a dictionary
                                                                                new_users[new_student!] = 1
                                                                            }
                                                                            
                                                                            let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                            for each_old_user in old_users! {
                                                                                if let _ = new_users[each_old_user] {
                                                                                    continue
                                                                                }
                                                                                else {
                                                                                    // delete users from main dictionary
                                                                                    let keys_in_dict = self.dict_tasks.keys
                                                                                    for key in keys_in_dict {
                                                                                        let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                                    }
                                                                                }
                                                                            }
                                                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                                        }
                                                                        else if responseJSON2["detail"] as? String == "Signature has expired."
                                                                        {
                                                                            self.logout()
                                                                        }
                                                                    }
                                                                }
                                                                taskStudentsTry.resume()
                                                            }
                                                            
                                                            print(error2?.localizedDescription ?? "No data")
                                                            return
                                                        }
                                                        // actual response
                                                        let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                        if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                            
                                                            if responseJSON2["status"] as? String == "ok" {
                                                                // id, name
                                                                let new_user_list = responseJSON2["users"] as? [[String]]
                                                                
                                                                var new_users = [User: Int]()
                                                                for each_user in new_user_list! {
                                                                    let new_student = User(uid: Int(each_user[0])!,
                                                                                           name: each_user[1])
                                                                    // make a dictionary
                                                                    new_users[new_student!] = 1
                                                                }
                                                                
                                                                let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                for each_old_user in old_users! {
                                                                    if let _ = new_users[each_old_user] {
                                                                        continue
                                                                    }
                                                                    else {
                                                                        // delete users from main dictionary
                                                                        let keys_in_dict = self.dict_tasks.keys
                                                                        for key in keys_in_dict {
                                                                            let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                        }
                                                                    }
                                                                }
                                                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                            }
                                                            else if responseJSON2["detail"] as? String == "Signature has expired."
                                                            {
                                                                self.logout()
                                                            }
                                                        }
                                                    }
                                                    taskStudents.resume()
                                                }
                                            }
                                        }
                                        else if responseJSON["detail"] as? String == "Signature has expired."
                                        {
                                            self.logout()
                                        }
                                        else {
                                            // Unable to remove students in a database
                                            print(error?.localizedDescription ?? "Unable to remove students in a database")
                                            self.present_alert("Could not add/remove students in a list, please try again.")
                                        }
                                    }
                                }
                                task_removeTry.resume()
                                
                            }
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        
                        // actual response
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            
                            if responseJSON["status"] as? String == "ok" {
                                // for keeping Dict instance up to date with the changes
                                for user in list_removed {
                                    let dict_keys = self.dict_tasks.keys
                                    for key in dict_keys {
                                        let _ = self.dict_tasks[key]!.removeValue(forKey: user)
                                    }
                                }
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                            } else if responseJSON["status"] as? String == "not exist" {
                                
                                // if tasks do not exist - no need to execute, no students records
                                if self.tasks.count > 0 {
                                    
                                    DispatchQueue.main.async {
                                        
                                        let jsonStudents: [String: Any] = ["subject_id": sub_id, "task_name": self.tasks[0].name]
                                        let jsonDataStudents = try? JSONSerialization.data(withJSONObject: jsonStudents)
                                        // post request to get users
                                        let urlStudents = URL(string: "http://127.0.0.1:8000/polls/get_students/")!
                                        var requestStudents = URLRequest(url: urlStudents)
                                        requestStudents.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                        requestStudents.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                        requestStudents.httpMethod = "POST"
                                        requestStudents.httpBody = jsonDataStudents
                                        
                                        let taskStudents = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                            guard let data2 = data2, error2 == nil else {
                                                os_log("Request error", log: OSLog.default, type: .debug)
                                                if error2?._code == NSURLErrorTimedOut {
                                                    self.present_alert("Server is not responding. Please, try again later.")
                                                }
                                                else if error2?._code == NSURLErrorCannotConnectToHost {
                                                    self.present_alert("Server is not responding. Please, try again later.")
                                                }
                                                else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                    // make second request, if connection was lost - try again
                                                    let taskStudentsTry = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                        guard let data2 = data2, error2 == nil else {
                                                            os_log("Request error", log: OSLog.default, type: .debug)
                                                            self.present_alert("Please, try again later.")
                                                            print(error2?.localizedDescription ?? "No data")
                                                            return
                                                        }
                                                        let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                        if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                            
                                                            if responseJSON2["status"] as? String == "ok" {
                                                                // id, name
                                                                let new_user_list = responseJSON2["users"] as? [[String]]
                                                                
                                                                var new_users = [User: Int]()
                                                                for each_user in new_user_list! {
                                                                    let new_student = User(uid: Int(each_user[0])!,
                                                                                           name: each_user[1])
                                                                    // make a dictionary
                                                                    new_users[new_student!] = 1
                                                                }
                                                                
                                                                let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                                for each_old_user in old_users! {
                                                                    if let _ = new_users[each_old_user] {
                                                                        continue
                                                                    }
                                                                    else {
                                                                        // delete users from main dictionary
                                                                        let keys_in_dict = self.dict_tasks.keys
                                                                        for key in keys_in_dict {
                                                                            let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                        }
                                                                    }
                                                                }
                                                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                            }
                                                            else if responseJSON2["detail"] as? String == "Signature has expired."
                                                            {
                                                                self.logout()
                                                            }
                                                        }
                                                    }
                                                    taskStudentsTry.resume()
                                                }
                                                
                                                print(error2?.localizedDescription ?? "No data")
                                                return
                                            }
                                            // actual response
                                            let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                            if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                
                                                if responseJSON2["status"] as? String == "ok" {
                                                    // id, name
                                                    let new_user_list = responseJSON2["users"] as? [[String]]
                                                    
                                                    var new_users = [User: Int]()
                                                    for each_user in new_user_list! {
                                                        let new_student = User(uid: Int(each_user[0])!,
                                                                               name: each_user[1])
                                                        // make a dictionary
                                                        new_users[new_student!] = 1
                                                    }
                                                    
                                                    let old_users = self.dict_tasks[self.tasks[0]]?.keys
                                                    for each_old_user in old_users! {
                                                        if let _ = new_users[each_old_user] {
                                                            continue
                                                        }
                                                        else {
                                                            // delete users from main dictionary
                                                            let keys_in_dict = self.dict_tasks.keys
                                                            for key in keys_in_dict {
                                                                let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                            }
                                                        }
                                                    }
                                                    self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                }
                                                else if responseJSON2["detail"] as? String == "Signature has expired."
                                                {
                                                    self.logout()
                                                }
                                            }
                                        }
                                        taskStudents.resume()
                                    }
                                }
                            }
                            else if responseJSON["detail"] as? String == "Signature has expired."
                            {
                                self.logout()
                            }
                            else {
                                // Unable to remove students in a database
                                print(error?.localizedDescription ?? "Unable to remove students in a database")
                                self.present_alert("Could not add/remove students in a list, please try again.")
                            }
                        }
                    }
                    task_remove.resume()
                    
                } else if responseJSON["detail"] as? String == "Signature has expired."
                {
                    self.logout()
                }
                else {
                    // Unable to add students in a database
                    print(error?.localizedDescription ?? "Unable to add students in a database")
                    self.present_alert("Could not add/remove students in a list, please try again.")
                }
            }
        }
        task.resume()
    }
    
    // MARK: properties
    weak var delegate: TeacherSubjectsTableViewController?
    
    var subject: Subject?
    var all_students = [User]()
    var tasks = [Task]()
    var dict_tasks = [Task: [User: Int]]()
    var raw_token: String?
    var session_tasks = [URLSessionDataTask]()
    
    //MARK: Actions
    
    @IBAction func unwindToTasksList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewTaskViewController,
            let new_task = sourceViewController.newTaskName.text {
            
            if !(new_task.isEmpty) {
                
                let json: [String: Any] = ["task": new_task, "subject_id": String(subject!.uid), "subject": subject?.name as Any]
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                // post request to add new task to database
                let url = URL(string: "http://127.0.0.1:8000/polls/add_new_task/")!
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        os_log("Request error", log: OSLog.default, type: .debug)
                        if error?._code == NSURLErrorTimedOut {
                            self.present_alert("Server is not responding. Please, try again later.")
                        }
                        else if error?._code == NSURLErrorCannotConnectToHost {
                            self.present_alert("Server is not responding. Please, try again later.")
                        }
                        else if error?._code == NSURLErrorNetworkConnectionLost {
                            // make second request, if connection was lost - try again
                            let taskTry = URLSession.shared.dataTask(with: request) { data, response, error in
                                guard let data = data, error == nil else {
                                    os_log("Request error", log: OSLog.default, type: .debug)
                                    self.present_alert("Please, try again later.")
                                    print(error?.localizedDescription ?? "No data")
                                    return
                                }
                                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                if let responseJSON = responseJSON as? [String: Any] {
                                    
                                    if responseJSON["status"] as? String == "ok" {
                                        let task_id = responseJSON["task_id"] as? String
                                        let id = Int(task_id!)
                                        let student_task = Task(uid: id!, name: new_task)
                                        
                                        let newIndexPath = IndexPath(row: self.tasks.count, section: 0)
                                        self.tasks.append(student_task!)
                                        
                                        OperationQueue.main.addOperation {
                                            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.dict_tasks[student_task!] = [User: Int]()
                                            
                                            var users_exist = false
                                            var users_exist_in_task: Task?
                                            for task in self.dict_tasks.keys {
                                                if users_exist {
                                                    break
                                                }
                                                for user in self.dict_tasks[task]!.keys {
                                                    if !(user.name.isEmpty) {
                                                        users_exist = true
                                                        users_exist_in_task = task
                                                        break
                                                    }
                                                }
                                            }
                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                            if users_exist {
                                                let json_grades: [String: Any] = ["task": new_task, "subject_id": String(self.subject!.uid), "subject": self.subject?.name as Any, "task_with_data": users_exist_in_task?.name as Any]
                                                let jsonDataGrades = try? JSONSerialization.data(withJSONObject: json_grades)
                                                // post request to add new grades to database
                                                let url_grades = URL(string: "http://127.0.0.1:8000/polls/add_grades/")!
                                                var request_grades = URLRequest(url: url_grades)
                                                request_grades.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                request_grades.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                                request_grades.httpMethod = "POST"
                                                request_grades.httpBody = jsonDataGrades
                                                let task_grade = URLSession.shared.dataTask(with: request_grades) { data2, response2, error2 in
                                                    guard let data2 = data2, error2 == nil else {
                                                        os_log("Request error", log: OSLog.default, type: .debug)
                                                        if error2?._code == NSURLErrorTimedOut {
                                                            self.present_alert("Server is not responding. Please, try again later.")
                                                        }
                                                        else if error2?._code == NSURLErrorCannotConnectToHost {
                                                            self.present_alert("Server is not responding. Please, try again later.")
                                                        }
                                                        else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                            // make second request, if connection was lost - try again
                                                            
                                                            let task_gradeTry = URLSession.shared.dataTask(with: request_grades) { data2, response2, error2 in
                                                                guard let data2 = data2, error2 == nil else {
                                                                    os_log("Request error", log: OSLog.default, type: .debug)
                                                                    self.present_alert("Please, try again later.")
                                                                    print(error2?.localizedDescription ?? "No data")
                                                                    return
                                                                }
                                                                let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                                if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                                    if responseJSON2["status"] as? String == "ok" {
                                                                        
                                                                        // keeping students data up to date
                                                                        self.dict_tasks[student_task!] = self.dict_tasks[users_exist_in_task!]
                                                                        let dict_keys = self.dict_tasks[student_task!]?.keys
                                                                        // setting grades for a new task to 0
                                                                        for each_user in dict_keys! {
                                                                            self.dict_tasks[student_task!]?[each_user] = 0
                                                                        }
                                                                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                                    } else if responseJSON2["detail"] as? String == "Signature has expired."
                                                                    {
                                                                        self.logout()
                                                                    }
                                                                }
                                                            }
                                                            task_gradeTry.resume()
                                                            
                                                        }
                                                        print(error2?.localizedDescription ?? "No data")
                                                        return
                                                    }
                                                        // actual response
                                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                        if responseJSON2["status"] as? String == "ok" {
                                                            
                                                            // keeping students data up to date
                                                            self.dict_tasks[student_task!] = self.dict_tasks[users_exist_in_task!]
                                                            let dict_keys = self.dict_tasks[student_task!]?.keys
                                                            // setting grades for a new task to 0
                                                            for each_user in dict_keys! {
                                                                self.dict_tasks[student_task!]?[each_user] = 0
                                                            }
                                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                        } else if responseJSON2["detail"] as? String == "Signature has expired."
                                                        {
                                                            self.logout()
                                                        }
                                                    }
                                                }
                                                task_grade.resume()
                                            }
                                        }
                                        
                                    } else if responseJSON["detail"] as? String == "Signature has expired."
                                    {
                                        self.logout()
                                    }
                                    else {
                                        self.present_alert("Could not add new assignment, please try again.")
                                    }
                                }
                            }
                            taskTry.resume()
                        }
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                        //actual response
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        
                        if responseJSON["status"] as? String == "ok" {
                            let task_id = responseJSON["task_id"] as? String
                            let id = Int(task_id!)
                            let student_task = Task(uid: id!, name: new_task)
                            
                            let newIndexPath = IndexPath(row: self.tasks.count, section: 0)
                            self.tasks.append(student_task!)
                            
                            OperationQueue.main.addOperation {
                                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                            }
                            
                            DispatchQueue.main.async {
                                self.dict_tasks[student_task!] = [User: Int]()
                                
                                var users_exist = false
                                var users_exist_in_task: Task?
                                for task in self.dict_tasks.keys {
                                    if users_exist {
                                        break
                                    }
                                    for user in self.dict_tasks[task]!.keys {
                                        if !(user.name.isEmpty) {
                                            users_exist = true
                                            users_exist_in_task = task
                                            break
                                        }
                                    }
                                }
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                if users_exist {
                                    let json_grades: [String: Any] = ["task": new_task, "subject_id": String(self.subject!.uid), "subject": self.subject?.name as Any, "task_with_data": users_exist_in_task?.name as Any]
                                    let jsonDataGrades = try? JSONSerialization.data(withJSONObject: json_grades)
                                    // post request to add new grades to database
                                    let url_grades = URL(string: "http://127.0.0.1:8000/polls/add_grades/")!
                                    var request_grades = URLRequest(url: url_grades)
                                    request_grades.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                    request_grades.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                    request_grades.httpMethod = "POST"
                                    request_grades.httpBody = jsonDataGrades
                                    let task_grade = URLSession.shared.dataTask(with: request_grades) { data2, response2, error2 in
                                        guard let data2 = data2, error2 == nil else {
                                            os_log("Request error", log: OSLog.default, type: .debug)
                                            if error2?._code == NSURLErrorTimedOut {
                                                self.present_alert("Server is not responding. Please, try again later.")
                                            }
                                            else if error2?._code == NSURLErrorCannotConnectToHost {
                                                self.present_alert("Server is not responding. Please, try again later.")
                                            }
                                            else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                // make second request, if connection was lost - try again
                                                
                                                let task_gradeTry = URLSession.shared.dataTask(with: request_grades) { data2, response2, error2 in
                                                    guard let data2 = data2, error2 == nil else {
                                                        os_log("Request error", log: OSLog.default, type: .debug)
                                                        self.present_alert("Please, try again later.")
                                                        print(error2?.localizedDescription ?? "No data")
                                                        return
                                                    }
                                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                        if responseJSON2["status"] as? String == "ok" {
                                                            
                                                            // keeping students data up to date
                                                            self.dict_tasks[student_task!] = self.dict_tasks[users_exist_in_task!]
                                                            let dict_keys = self.dict_tasks[student_task!]?.keys
                                                            // setting grades for a new task to 0
                                                            for each_user in dict_keys! {
                                                                self.dict_tasks[student_task!]?[each_user] = 0
                                                            }
                                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                        } else if responseJSON2["detail"] as? String == "Signature has expired."
                                                        {
                                                            self.logout()
                                                        }
                                                    }
                                                }
                                                task_gradeTry.resume()
                                                
                                            }
                                            print(error2?.localizedDescription ?? "No data")
                                            return
                                        }
                                            // actual response
                                        let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                        if let responseJSON2 = responseJSON2 as? [String: Any] {
                                            if responseJSON2["status"] as? String == "ok" {
                                                
                                                // keeping students data up to date
                                                self.dict_tasks[student_task!] = self.dict_tasks[users_exist_in_task!]
                                                let dict_keys = self.dict_tasks[student_task!]?.keys
                                                // setting grades for a new task to 0
                                                for each_user in dict_keys! {
                                                    self.dict_tasks[student_task!]?[each_user] = 0
                                                }
                                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                            } else if responseJSON2["detail"] as? String == "Signature has expired."
                                            {
                                                self.logout()
                                            }
                                        }
                                    }
                                    task_grade.resume()
                                }
                            }
                            
                        } else if responseJSON["detail"] as? String == "Signature has expired."
                        {
                            self.logout()
                        }
                        else {
                            self.present_alert("Could not add new assignment, please try again.")
                        }
                    }
                }
                task.resume()
            }
            
        } 
        else if let sourceViewController = sender.source as? EditTasksTableViewController {
            var counter = 0 // update view then send info to database if wrong get error message
            let old_tasks = self.tasks
            let old_dict_tasks = self.dict_tasks
            var save_error = false
            for each_task in sourceViewController.list_of_tasks {
                if tasks[counter] != each_task {
                    // for keeping Dict instance up to date with the changes
                    if let value_dict = self.dict_tasks.removeValue(forKey: self.tasks[counter]) {
                        self.dict_tasks[each_task] = value_dict
                    }
                    // keeping cells up to date
                    self.tasks[counter] = each_task
                }
                counter += 1
            }
            tableView.reloadData()
            counter = 0
            for each_task in sourceViewController.list_of_tasks {
                if old_tasks[counter] != each_task {
                    var sub_id = String()
                    if let subjects_id = subject?.uid {
                        sub_id = String(describing: subjects_id)
                    }
                    // for keeping database correct
                    let json: [String: Any] = ["subject_id": sub_id, "old_task_name": old_tasks[counter].name, "new_task_name": each_task.name]
                    let jsonData = try? JSONSerialization.data(withJSONObject: json)
                    // post request to change task in a database
                    let url = URL(string: "http://127.0.0.1:8000/polls/change_task/")!
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            os_log("Request error", log: OSLog.default, type: .debug)
                            if error?._code == NSURLErrorTimedOut {
                                self.tasks = old_tasks
                                self.dict_tasks = old_dict_tasks
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                self.present_alert("Server is not responding. Please, try again later.")
                            }
                            else if error?._code == NSURLErrorCannotConnectToHost {
                                self.tasks = old_tasks
                                self.dict_tasks = old_dict_tasks
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                self.present_alert("Server is not responding. Please, try again later.")
                            }
                            else if error?._code == NSURLErrorNetworkConnectionLost {
                                // make second request, if connection was lost - try again
                                let taskTry = URLSession.shared.dataTask(with: request) { data, response, error in
                                    guard let data = data, error == nil else {
                                        self.tasks = old_tasks
                                        self.dict_tasks = old_dict_tasks
                                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                        print(error?.localizedDescription ?? "No data")
                                        os_log("Request error", log: OSLog.default, type: .debug)
                                        self.present_alert("Please, try again later.")
                                        return
                                    }
                                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                    if let responseJSON = responseJSON as? [String: Any] {
                                        if responseJSON["detail"] as? String == "Signature has expired."
                                        {
                                            self.logout()
                                        }
                                        else if responseJSON["status"] as? String != "ok" {
                                            self.present_alert("Could not change task names, please try again.")
                                            
                                            self.tasks = old_tasks
                                            self.dict_tasks = old_dict_tasks
                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                            save_error = true
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                                self.session_tasks.append(taskTry)
                                taskTry.resume()
                                
                            } else {
                                self.tasks = old_tasks
                                self.dict_tasks = old_dict_tasks
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                            }
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        // actual response
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            if responseJSON["detail"] as? String == "Signature has expired."
                            {
                                self.logout()
                            }
                            else if responseJSON["status"] as? String != "ok" {
                                    self.present_alert("Could not change task names, please try again.")
                                    
                                    self.tasks = old_tasks
                                    self.dict_tasks = old_dict_tasks
                                    self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                    save_error = true
                                    self.tableView.reloadData()
                            }
                        }
                    }
                    self.session_tasks.append(task)
                    task.resume()
                }
                if save_error {
                    break
                }
                counter += 1
            }
        }
        else if let sourceViewController = sender.source as? StudentGradesTableViewController {
            let new_users_grades = sourceViewController.user_grades
            let current_task = sourceViewController.current_task
            let dict_keys = new_users_grades.keys
            
            // for sending subject_id as a String
            var sub_id = String()
            if let subjects_id = subject?.uid {
                sub_id = String(describing: subjects_id)
            }
            
            for key in dict_keys {
                if new_users_grades[key] != dict_tasks[current_task!]![key] {
                    // if grade has changed
                    var grade_int = String()
                    if let grade = new_users_grades[key] {
                        grade_int = String(describing: grade)
                    }
                    // for keeping database correct
                    let json: [String: Any] = ["subject_id": sub_id, "task_name": current_task!.name, "student_id": String(describing: key.uid), "user_grade": grade_int]
                    let jsonData = try? JSONSerialization.data(withJSONObject: json)
                    // post request to change user's grade in a database
                    let url = URL(string: "http://127.0.0.1:8000/polls/change_grade/")!
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            os_log("Request error", log: OSLog.default, type: .debug)
                            if error?._code == NSURLErrorTimedOut {
                                self.present_alert("Server is not responding. Please, try again later.")
                            }
                            else if error?._code == NSURLErrorCannotConnectToHost {
                                self.present_alert("Server is not responding. Please, try again later.")
                            }
                            else if error?._code == NSURLErrorNetworkConnectionLost {
                                // make second request, if connection was lost - try again
                                let taskTry = URLSession.shared.dataTask(with: request) { data, response, error in
                                    guard let data = data, error == nil else {
                                        os_log("Request error", log: OSLog.default, type: .debug)
                                        self.present_alert("Please, try again later.")
                                        print(error?.localizedDescription ?? "No data")
                                        return
                                    }
                                    
                                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                                    if let responseJSON = responseJSON as? [String: Any] {
                                        
                                        if responseJSON["status"] as? String == "ok" {
                                            
                                            // for keeping Dict instance up to date with the changes
                                            if let _ = self.dict_tasks[current_task!]!.removeValue(forKey: key)
                                            {
                                                self.dict_tasks[current_task!]![key] = new_users_grades[key]
                                            }
                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                        } else if responseJSON["detail"] as? String == "Signature has expired."
                                        {
                                            self.logout()
                                        }
                                        else if responseJSON["status"] as? String == "not exist" {
                                            // Unable to change user's grade - reload current "all users"
                                            print(error?.localizedDescription ?? "Unable to change user's grade in a database, no user with id \(key.uid)")
                                            
                                            DispatchQueue.main.async {
                                                // reload all current students
                                                let jsonStudents: [String: Any] = ["subject_id": sub_id, "task_name": current_task!.name]
                                                let jsonDataStudents = try? JSONSerialization.data(withJSONObject: jsonStudents)
                                                // post request to get users
                                                let urlStudents = URL(string: "http://127.0.0.1:8000/polls/get_students/")!
                                                var requestStudents = URLRequest(url: urlStudents)
                                                requestStudents.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                                requestStudents.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                                requestStudents.httpMethod = "POST"
                                                requestStudents.httpBody = jsonDataStudents
                                                
                                                
                                                let taskStudents = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                    guard let data2 = data2, error2 == nil else {
                                                        os_log("Request error", log: OSLog.default, type: .debug)
                                                        if error2?._code == NSURLErrorTimedOut {
                                                            self.present_alert("Server is not responding. Please, try again later.")
                                                        }
                                                        else if error2?._code == NSURLErrorCannotConnectToHost {
                                                            self.present_alert("Server is not responding. Please, try again later.")
                                                        }
                                                        else if error2?._code == NSURLErrorNetworkConnectionLost {
                                                            // make second request, if connection was lost - try again
                                                            let taskStudentsTry = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                                guard let data2 = data2, error2 == nil else {
                                                                    os_log("Request error", log: OSLog.default, type: .debug)
                                                                    self.present_alert("Please, try again later.")
                                                                    print(error2?.localizedDescription ?? "No data")
                                                                    return
                                                                }
                                                                let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                                if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                                    
                                                                    if responseJSON2["status"] as? String == "ok" {
                                                                        // id, name
                                                                        let new_user_list = responseJSON2["users"] as? [[String]]
                                                                        
                                                                        var new_users = [User: Int]()
                                                                        for each_user in new_user_list! {
                                                                            let new_student = User(uid: Int(each_user[0])!,
                                                                                                   name: each_user[1])
                                                                            // make a dictionary
                                                                            new_users[new_student!] = 1
                                                                        }
                                                                        
                                                                        let old_users = self.dict_tasks[current_task!]?.keys
                                                                        for each_old_user in old_users! {
                                                                            if let _ = new_users[each_old_user] {
                                                                                continue
                                                                            }
                                                                            else {
                                                                                // delete users from main dictionary
                                                                                let keys_in_dict = self.dict_tasks.keys
                                                                                for key in keys_in_dict {
                                                                                    let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                                }
                                                                            }
                                                                        }
                                                                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                                    } else if responseJSON2["detail"] as? String == "Signature has expired."
                                                                    {
                                                                        self.logout()
                                                                    }
                                                                }
                                                            }
                                                            taskStudentsTry.resume()
                                                        }
                                                        
                                                        print(error2?.localizedDescription ?? "No data")
                                                        return
                                                    }
                                                        // actual response
                                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                        
                                                        if responseJSON2["status"] as? String == "ok" {
                                                            // id, name
                                                            let new_user_list = responseJSON2["users"] as? [[String]]
                                                            
                                                            var new_users = [User: Int]()
                                                            for each_user in new_user_list! {
                                                                let new_student = User(uid: Int(each_user[0])!,
                                                                                       name: each_user[1])
                                                                // make a dictionary
                                                                new_users[new_student!] = 1
                                                            }
                                                            
                                                            let old_users = self.dict_tasks[current_task!]?.keys
                                                            for each_old_user in old_users! {
                                                                if let _ = new_users[each_old_user] {
                                                                    continue
                                                                }
                                                                else {
                                                                    // delete users from main dictionary
                                                                    let keys_in_dict = self.dict_tasks.keys
                                                                    for key in keys_in_dict {
                                                                        let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                    }
                                                                }
                                                            }
                                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                        } else if responseJSON2["detail"] as? String == "Signature has expired."
                                                        {
                                                            self.logout()
                                                        }
                                                    }
                                                }
                                                taskStudents.resume()
                                            }
                                            self.present_alert("Could not change student's grades, please try again.")
                                        }
                                    }
                                }
                                taskTry.resume()
                                
                            }
                            
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                            // actual response
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            
                            if responseJSON["status"] as? String == "ok" {
                                
                                // for keeping Dict instance up to date with the changes
                                if let _ = self.dict_tasks[current_task!]!.removeValue(forKey: key)
                                {
                                    self.dict_tasks[current_task!]![key] = new_users_grades[key]
                                }
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                            } else if responseJSON["detail"] as? String == "Signature has expired."
                            {
                                self.logout()
                            }
                            else if responseJSON["status"] as? String == "not exist" {
                                // Unable to change user's grade - reload current "all users"
                                print(error?.localizedDescription ?? "Unable to change user's grade in a database, no user with id \(key.uid)")
                                
                                DispatchQueue.main.async {
                                // reload all current students
                                let jsonStudents: [String: Any] = ["subject_id": sub_id, "task_name": current_task!.name]
                                let jsonDataStudents = try? JSONSerialization.data(withJSONObject: jsonStudents)
                                // post request to get users
                                let urlStudents = URL(string: "http://127.0.0.1:8000/polls/get_students/")!
                                var requestStudents = URLRequest(url: urlStudents)
                                requestStudents.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                requestStudents.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                requestStudents.httpMethod = "POST"
                                requestStudents.httpBody = jsonDataStudents
                                

                                let taskStudents = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                    guard let data2 = data2, error2 == nil else {
                                        os_log("Request error", log: OSLog.default, type: .debug)
                                        if error2?._code == NSURLErrorTimedOut {
                                            self.present_alert("Server is not responding. Please, try again later.")
                                        }
                                        else if error2?._code == NSURLErrorCannotConnectToHost {
                                            self.present_alert("Server is not responding. Please, try again later.")
                                        }
                                        else if error2?._code == NSURLErrorNetworkConnectionLost {
                                            // make second request, if connection was lost - try again
                                            let taskStudentsTry = URLSession.shared.dataTask(with: requestStudents) { data2, response2, error2 in
                                                guard let data2 = data2, error2 == nil else {
                                                    os_log("Request error", log: OSLog.default, type: .debug)
                                                    self.present_alert("Please, try again later.")
                                                    print(error2?.localizedDescription ?? "No data")
                                                    return
                                                }
                                                let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                                if let responseJSON2 = responseJSON2 as? [String: Any] {
                                                    
                                                    if responseJSON2["status"] as? String == "ok" {
                                                        // id, name
                                                        let new_user_list = responseJSON2["users"] as? [[String]]
                                                        
                                                        var new_users = [User: Int]()
                                                        for each_user in new_user_list! {
                                                            let new_student = User(uid: Int(each_user[0])!,
                                                                                   name: each_user[1])
                                                            // make a dictionary
                                                            new_users[new_student!] = 1
                                                        }
                                                        
                                                        let old_users = self.dict_tasks[current_task!]?.keys
                                                        for each_old_user in old_users! {
                                                            if let _ = new_users[each_old_user] {
                                                                continue
                                                            }
                                                            else {
                                                                // delete users from main dictionary
                                                                let keys_in_dict = self.dict_tasks.keys
                                                                for key in keys_in_dict {
                                                                    let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                                }
                                                            }
                                                        }
                                                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                                    } else if responseJSON2["detail"] as? String == "Signature has expired."
                                                    {
                                                        self.logout()
                                                    }
                                                }
                                            }
                                            taskStudentsTry.resume()
                                        }
                                        
                                        print(error2?.localizedDescription ?? "No data")
                                        return
                                    } // actual response
                                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                                    if let responseJSON2 = responseJSON2 as? [String: Any] {
                                        
                                        if responseJSON2["status"] as? String == "ok" {
                                            // id, name
                                            let new_user_list = responseJSON2["users"] as? [[String]]
                                            
                                            var new_users = [User: Int]()
                                            for each_user in new_user_list! {
                                                let new_student = User(uid: Int(each_user[0])!,
                                                                       name: each_user[1])
                                                // make a dictionary
                                                new_users[new_student!] = 1
                                            }
                                            
                                            let old_users = self.dict_tasks[current_task!]?.keys
                                            for each_old_user in old_users! {
                                                if let _ = new_users[each_old_user] {
                                                    continue
                                                }
                                                else {
                                                    // delete users from main dictionary
                                                    let keys_in_dict = self.dict_tasks.keys
                                                    for key in keys_in_dict {
                                                        let _ = self.dict_tasks[key]?.removeValue(forKey: each_old_user)
                                                    }
                                                }
                                            }
                                            self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                        } else if responseJSON2["detail"] as? String == "Signature has expired."
                                        {
                                            self.logout()
                                        }
                                    }
                                }
                                taskStudents.resume()
                                }
                                self.present_alert("Could not change student's grades, please try again.")
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    // MARK: segues information transfer
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowDetailStudent" {
            if let toViewController = segue.destination as? StudentGradesTableViewController {
                if let users_exist = self.dict_tasks[tasks[tableView.indexPathForSelectedRow!.row]] {
                    toViewController.user_grades = users_exist
                }
                toViewController.all_students = self.all_students
                toViewController.subject = self.subject
                toViewController.current_task = self.tasks[tableView.indexPathForSelectedRow!.row]
                toViewController.delegating = self
                
            } else {
                fatalError("Unable to send data to Student Grades Controller")
            }
        }
        else if segue.identifier == "EditTasksSegue" {
            if let navigationController = segue.destination as? UINavigationController,
                let editTaskController = navigationController.topViewController as? EditTasksTableViewController {
                    editTaskController.list_of_tasks = self.tasks
            } else {
                fatalError("Unable to send data to EditTasksTableViewController")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TasksTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TasksTableViewCell else {
            fatalError("The dequeued cell is not an instance of TasksTableViewCell.")
        }
        // Fetches the appropriate task for the data source layout.
        let task = tasks[indexPath.row]
        cell.taskName.text = task.name

        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // deleting task
            let old_dict = dict_tasks.removeValue(forKey: tasks[indexPath.row])
            let removed_task = tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let json: [String: Any] = ["subject_id": subject?.uid as Any, "task_name": removed_task.name]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // post request to delete subject in database
            let url = URL(string: "http://127.0.0.1:8000/polls/remove_task/")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    os_log("Request error", log: OSLog.default, type: .debug)
                    if error?._code == NSURLErrorTimedOut {
                        self.tasks.append(removed_task)
                        self.dict_tasks[removed_task] = old_dict
                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                        tableView.reloadData()
                        self.present_alert("Server is not responding. Please, try again later.")
                    }
                    else if error?._code == NSURLErrorCannotConnectToHost {
                        self.tasks.append(removed_task)
                        self.dict_tasks[removed_task] = old_dict
                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                        tableView.reloadData()
                        self.present_alert("Server is not responding. Please, try again later.")
                    }
                    else if error?._code == NSURLErrorNetworkConnectionLost {
                        // make second request, if connection was lost - try again
                        let taskTry = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data, error == nil else {
                                self.tasks.append(removed_task)
                                self.dict_tasks[removed_task] = old_dict
                                self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                tableView.reloadData()
                                self.present_alert("Please, try again later.")
                                os_log("Request error", log: OSLog.default, type: .debug)
                                print(error?.localizedDescription ?? "No data")
                                return
                            }
                            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                            if let responseJSON = responseJSON as? [String: Any] {
                                if responseJSON["detail"] as? String == "Signature has expired."
                                {
                                    self.logout()
                                }
                                else if responseJSON["status"] as? String != "ok" {
                                    self.present_alert("Could not delete '\(removed_task.name)' task, please try again.")
                                    
                                    self.tasks.append(removed_task)
                                    self.dict_tasks[removed_task] = old_dict
                                    self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                                    tableView.reloadData()
                                }
                            }
                        }
                        taskTry.resume()
                    } else {
                        self.tasks.append(removed_task)
                        self.dict_tasks[removed_task] = old_dict
                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                        tableView.reloadData()
                    }
                    print(error?.localizedDescription ?? "No data")
                    return
                } // actual response
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if responseJSON["detail"] as? String == "Signature has expired."
                    {
                        self.logout()
                    }
                    else if responseJSON["status"] as? String != "ok" {
                        self.present_alert("Could not delete '\(removed_task.name)' task, please try again.")
                        
                        self.tasks.append(removed_task)
                        self.dict_tasks[removed_task] = old_dict
                        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
                        tableView.reloadData()
                    }
                }
            }
            task.resume()
        }
    }
    
    private func logout() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        guard let nextController = story.instantiateInitialViewController() else {
            assertionFailure("Unable to load main view controller")
            return
        }
        
        let alertController = UIAlertController(title: "Error", message: "Authorization failed. Please, log in again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) -> Void in
            self.present(nextController, animated: true)
        })
        alertController.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func present_alert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        alertController.addAction(okAction)
        OperationQueue.main.addOperation {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
