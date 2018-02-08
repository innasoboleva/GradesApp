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
    func tasksChanged(_ newTasks: [Subject], new_students:[Subject], new_grades: [[Int]], atRow: Int) {
        self.tasks[atRow] = newTasks
        self.students_grades[atRow] = new_grades
        self.students[atRow] = new_students
    }
    
    // MARK: initial data
    let data_subjects =  [String: String]()
    let data_tasks =  [String: [String: String]]()
    let all_data = [String: [String: (String, String)]]()
    let all_students = [String: (String, String)]()
    
//    var data_subjects = ["Astronomy", "Data Science", "Math", "Education", "Physics"]
//    var data_tasks = [["Planets", "Mercury", "Asteroids"],["Programming"], ["Logarithm", "Squares"], [],["Laws of nature"]]
//    var data_students = [["Anna","Maria","Inna"],
//                    ["Alex"],
//                    ["Alex", "Inna"],
//                    ["James", "Jacob"],
//                    ["Inna","Alex"]]
//    var all_students = ["Inna", "Alex", "Maria", "Tony", "Carla", "Jamie", "Anna", "James", "Jacob"]
    
    var students_grades = [[[Int]]]()
    
    var subjects = [Int: Subject]()
    var tasks = [Subject: [Int: Task]]()
//    var students = [[Subject]]()
    
    var dict = [Subject: [Task: (Subject, Int)]]()
    
    // MARK: properties
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //MARK: Actions
    
    @IBAction func unwindToSubjectsList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewSubjectViewController, let newsubject = sourceViewController.subject {
            // Add a new subject.
            let newIndexPath = IndexPath(row: subjects.count, section: 0)
            subjects.append(newsubject)
            tasks.append([])
            students.append([])
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        } else if let sourceViewController = sender.source as? EditSubjectTableViewController {
            self.subjects = sourceViewController.listOfSubjects
            tableView.reloadData()
        }
    }
    
    //MARK: Private Methods
    
    private func loadData() {
        
        let subject_keys = data_subjects.keys
        for key in subject_keys {
            let key_int = Int(key)
            let new_subject = Subject(uid: key_int!, name: data_subjects[key]!)
            self.subjects[key_int!] = new_subject
            // new_subject is each subject in dict
            let tasks_keys = data_tasks[key]?.keys
            for task_key in tasks_keys! {
                let int_key_task = Int(task_key)
                let new_task = Task(uid: int_key_task!, name: data_tasks[key]![task_key]!)
                
                tasks[new_subject!][int_key_task!] = new_task
            }
        }
        
        
    }
    
    // MARK: segues information transfer
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowDetailsSegue" {
            if let toViewController = segue.destination as? TasksTableViewController {
                toViewController.tasks_to_view = tasks[tableView.indexPathForSelectedRow!.row]
                toViewController.student_to_show = students[tableView.indexPathForSelectedRow!.row]
                toViewController.grades = students_grades[tableView.indexPathForSelectedRow!.row]
                toViewController.all_students = self.all_students
                toViewController.cell = tableView.indexPathForSelectedRow!.row
                toViewController.delegate = self
        } else {
            fatalError("Unable to send data to Tasks view")
            }
        }
        
        else if segue.identifier == "EditSubjectSegue" {
            if let navigationController = segue.destination as? UINavigationController,
                let editSubjectController = navigationController.topViewController as? EditSubjectTableViewController {
                editSubjectController.listOfSubjects = self.subjects
            } else {
                fatalError("Unable to send data to EditSubjectTableViewController view")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        // Load the sample data.
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
