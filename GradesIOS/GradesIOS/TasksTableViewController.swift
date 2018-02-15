//
//  TasksTableViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

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
        let json: [String: Any] = ["subject_id": sub_id, "subject_name": subject?.name, "students_id": students_added_array]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // post request to change students in a database
        let url = URL(string: "http://127.0.0.1:8000/polls/add_student/")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(raw_token!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
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
                    
                    // adding students first then removing
                    let json_remove: [String: Any] = ["subject_id": sub_id, "students_id": students_removed_array]
                    let jsonDataRemove = try? JSONSerialization.data(withJSONObject: json_remove)
                    // post request to change students in a database
                    let url_remove = URL(string: "http://127.0.0.1:8000/polls/remove_student/")!
                    var request_remove = URLRequest(url: url_remove)
                    request_remove.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request_remove.addValue(self.raw_token!, forHTTPHeaderField: "Authorization")
                    request_remove.httpMethod = "POST"
                    request_remove.httpBody = jsonDataRemove
                    
                    let task_remove = URLSession.shared.dataTask(with: request_remove) { data, response, error in
                        guard let data = data, error == nil else {
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
                            } else {
                                // Unable to remove students in a database
                                print(error?.localizedDescription ?? "Unable to remove students in a database")
                            }
                        }
                    }
                    task_remove.resume()
                    
                } else {
                    // Unable to add students in a database
                    print(error?.localizedDescription ?? "Unable to add students in a database")
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
    
    //MARK: Actions
    
    @IBAction func unwindToTasksList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewTaskViewController,
            let new_task = sourceViewController.task {
            // Add a new task
            let newIndexPath = IndexPath(row: tasks.count, section: 0)
            
            if tasks.count > 0 {
                // keeping students data up to date
                let last_task = tasks[tasks.count - 1]
                dict_tasks[new_task] = dict_tasks[last_task]
                let dict_keys = dict_tasks[new_task]?.keys
                // setiing grades for a new task to 0
                for each_user in dict_keys! {
                    dict_tasks[new_task]?[each_user] = 0
                }
            }
            tasks.append(new_task)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        } 
        else if let sourceViewController = sender.source as? EditTasksTableViewController {
            var counter = 0
            for each_task in sourceViewController.list_of_tasks {
                if tasks[counter] != each_task {

                    // for keeping database correct
                    let json: [String: Any] = ["subject_id": String(describing: self.subject?.uid), "old_task_name": tasks[counter].name, "new_task_name": each_task.name]
                    let jsonData = try? JSONSerialization.data(withJSONObject: json)
                    // post request to change task in a database
                    let url = URL(string: "http://127.0.0.1:8000/polls/change_task/")!
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue(raw_token!, forHTTPHeaderField: "Authorization")
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            
                            if responseJSON["status"] as? String == "ok" {
                                
                                // for keeping Dict instance up to date with the changes
                                if let value_dict = self.dict_tasks.removeValue(forKey: self.tasks[counter]) {
                                    self.dict_tasks[each_task] = value_dict
                                }
                                
                                // keeping cells up to date
                                self.tasks[counter] = each_task
                            } else {
                                // Unable to change task
                                print(error?.localizedDescription ?? "Unable to change task in a database")
                            }
                        }
                    }
                    task.resume()
                }
                counter += 1
            }
            tableView.reloadData()
        }
        else if let sourceViewController = sender.source as? StudentGradesTableViewController {
            let new_users_grades = sourceViewController.user_grades
            let current_task = sourceViewController.current_task
            let old_users_grades = dict_tasks[current_task!]?.keys
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
                    request.addValue(raw_token!, forHTTPHeaderField: "Authorization")
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print(error?.localizedDescription ?? "No data")
                            return
                        }
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                        if let responseJSON = responseJSON as? [String: Any] {
                            
                            if responseJSON["status"] as? String == "ok" {
                                
                                // for keeping Dict instance up to date with the changes
                                if let value_for_user = self.dict_tasks[current_task!]!.removeValue(forKey: key)
                                {
                                    self.dict_tasks[current_task!]![key] = new_users_grades[key]
                                }
                            } else {
                                // Unable to change user's grade
                                print(error?.localizedDescription ?? "Unable to change user's grade in a database")
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
                toViewController.raw_token = self.raw_token
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
        else if segue.identifier == "NewTaskSegue" {
            if let navigationController = segue.destination as? UINavigationController,
                let newTaskController = navigationController.topViewController as? NewTaskViewController {
                newTaskController.raw_token = self.raw_token
                newTaskController.subject = self.subject
            } else {
                fatalError("Unable to send data to NewTaskViewController")
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
        self.delegate?.tasksChanged(self.dict_tasks, tasks: self.tasks, atSubject: self.subject!)
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
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
