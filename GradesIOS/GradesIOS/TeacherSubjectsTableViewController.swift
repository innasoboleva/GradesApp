//
//  teacherSubjectsTableViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/22/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit
import os.log

class TeacherSubjectsTableViewController: UITableViewController, TasksDelegate {
    // protocol to set data TasksDelegate
    func tasksChanged(_ newTasks: [Task: [User: Int]], tasks: [Task], atSubject: Subject) {
        dict[atSubject] = newTasks
        self.tasks[atSubject] = tasks
    }
    
    // MARK: initial data
    var raw_token: String?
    var data_subjects =  [String: String]()
    var data_tasks =  [String: [String: String]]()
    var all_data = [String: [String: [[String]]]]()
    var all_students_data = [String: [String]]()
    
    // for easier view controller access to it's cells
    var subjects = [Subject]()
    var tasks = [Subject: [Task]]()
    var all_students = [User]()
    var dict = [Subject: [Task: [User: Int]]]()
    
    // MARK: properties
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: Actions
    @IBAction func logout(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        guard let nextController = story.instantiateInitialViewController() else {
            assertionFailure("Unable to load main view controller")
            return
        }
        OperationQueue.main.addOperation {
            self.present(nextController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func unwindToSubjectsList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewSubjectViewController,
            let name = sourceViewController.newSubjectName.text {
            if !(name.isEmpty) {
                
                let json: [String: Any] = ["subject": name]
                let jsonData = try? JSONSerialization.data(withJSONObject: json)
                // post request to add new subject to database
                let url = URL(string: "http://127.0.0.1:8000/polls/add_new_subject/")!
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
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
                            if let subject_id = responseJSON["subject_id"] as? String {
                                let id = Int(subject_id)
                                let new_subject = Subject(uid: id!, name: name)
                                
                                // Add a new subject.
                                let newIndexPath = IndexPath(row: self.subjects.count, section: 0)
                                self.subjects.append(new_subject!)
                                self.tasks[new_subject!] = [Task]()
                                self.dict[new_subject!] = [Task: [User: Int]]()
                                
                                OperationQueue.main.addOperation {
                                    self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                                }
                                
                            }
                        } else if responseJSON["detail"] as? String == "Signature has expired." {
                           self.logout()
                        }
                        else {
                            self.present_alert("Could not add new class, please try again.")
                        }
                    }
                }
                task.resume()
            }
            
        } else if let sourceViewController = sender.source as? EditSubjectTableViewController {
            var counter = 0
            let old_subjects = self.subjects
            let old_dict = self.dict
            let old_task = self.tasks
            var save_error = false
            for each_subject in sourceViewController.list_of_subjects {
                if subjects[counter] != each_subject {
                    // for keeping Dict instance up to date with the changes
                    if let value_dict = self.dict.removeValue(forKey: self.subjects[counter]) {
                        self.dict[each_subject] = value_dict
                    }
                    if let value_task = self.tasks.removeValue(forKey: self.subjects[counter]) {
                        self.tasks[each_subject] = value_task
                    }
                    // keeping cells up to date
                    self.subjects[counter] = each_subject
                }
                counter += 1
            }
            tableView.reloadData()
            counter = 0
            for each_subject in sourceViewController.list_of_subjects {
                if each_subject != old_subjects[counter] {
                    // for keeping database correct
                    let json: [String: Any] = ["subject_id": old_subjects[counter].uid, "subject_name": each_subject.name]
                    let jsonData = try? JSONSerialization.data(withJSONObject: json)
                    // post request to add new subject to database
                    let url = URL(string: "http://127.0.0.1:8000/polls/change_subject/")!
                    var request = URLRequest(url: url)
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
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
                                self.present_alert("Could not change class name, please try again.")
                                
                                self.subjects = old_subjects
                                self.dict = old_dict
                                self.tasks = old_task
                                save_error = true
                                self.tableView.reloadData()
                            }
                        }
                    }
                    task.resume()
                }
                if save_error {
                    break
                }
                counter += 1
            }
        }
    }
    
    //MARK: Private Methods
    
    private func loadData() {
        
        let subject_keys = data_subjects.keys
        for key in subject_keys {
            let key_int = Int(key)
            let new_subject = Subject(uid: key_int!, name: data_subjects[key]!)
            self.subjects.append(new_subject!)
            dict[new_subject!] = [Task: [User: Int]]()
            self.tasks[new_subject!] = []
            // new_subject is each subject in dict
            let tasks_keys = data_tasks[key]?.keys
            for task_key in tasks_keys! {
                let int_key_task = Int(task_key)
                let new_task = Task(uid: int_key_task!, name: data_tasks[key]![task_key]!)
                tasks[new_subject!]!.append(new_task!)
                dict[new_subject!]![new_task!] = [User: Int]()
                let task_name = data_tasks[key]![task_key]!
                if let students_exist = all_data[key]![task_name] {
                    for each_student in students_exist
                    { // each_student[0] - id, each_student[1] - name, each_student[2] - grade
                        let new_grade = Int(each_student[2])
                        let new_user = User(uid: Int(each_student[0])!, name: each_student[1])
                        dict[new_subject!]![new_task!]![new_user!] = new_grade
                    }
                }
            }
        }
        
        let students_keys = all_students_data.keys
        for key in students_keys {
            let new_id = Int(key)
            // let first = all_students_data[key]![0]
            let last = all_students_data[key]![1]
            let new_student = User(uid: new_id!, name: "\(last)")
            all_students.append(new_student!)
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
    
    // MARK: segues information transfer
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowDetailsSegue" {
            if let toViewController = segue.destination as? TasksTableViewController {
                if let dict_not_empty = dict[subjects[tableView.indexPathForSelectedRow!.row]] {
                    toViewController.dict_tasks = dict_not_empty
                }
                toViewController.subject = subjects[tableView.indexPathForSelectedRow!.row]
                toViewController.all_students = self.all_students
                if let tasks_not_empty = tasks[subjects[tableView.indexPathForSelectedRow!.row]] {
                    toViewController.tasks = tasks_not_empty
                }
                
                toViewController.raw_token = self.raw_token
                toViewController.delegate = self
        } else {
            fatalError("Unable to send data to Tasks view controller")
            }
        }
        
        else if segue.identifier == "EditSubjectSegue" {
            if let navigationController = segue.destination as? UINavigationController,
                let editSubjectController = navigationController.topViewController as? EditSubjectTableViewController {
                    editSubjectController.list_of_subjects = self.subjects
            } else {
                fatalError("Unable to send data to EditSubjectTableViewController")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelectionDuringEditing = false
        tableView.delegate = self
        tableView.dataSource = self

        loadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return subjects.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SubstTableViewCell"

        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SubstTableViewCell else {
            fatalError("The dequeued cell is not an instance of substTableViewCell.")
        }

        // Fetches the appropriate subject for the data source layout.
        let subject = subjects[indexPath.row]
        
        cell.subjectName.text = subject.name
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.picked_cell = indexPath.row
//    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // deleting subject
            let old_task = tasks.removeValue(forKey: subjects[indexPath.row])
            let old_dict = dict.removeValue(forKey: subjects[indexPath.row])
            let removed_subject = subjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let json: [String: Any] = ["subject_id": removed_subject.uid]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // post request to delete subject in database
            let url = URL(string: "http://127.0.0.1:8000/polls/remove_subject/")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("JWT \(raw_token!)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
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
                        self.present_alert("Could not delete \(removed_subject.name) subject, please try again.")
                        
                        self.subjects.append(removed_subject)
                        self.tasks[removed_subject] = old_task
                        self.dict[removed_subject] = old_dict
                        tableView.reloadData()
                    }
                }
            }
            task.resume()
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
