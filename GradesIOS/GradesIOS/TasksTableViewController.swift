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
    func studentsChanged(_ students: [Subject], list_added: Set<Int>,list_removed: Set<Int>) {
        
        var counter = 0
        for _ in tasks_to_view {
            for z in list_removed {
                let name = all_students[z]
                let st = Subject(name: name)
                let index = student_to_show.index(of: st!)
                grades[counter].remove(at: index!)
            }
            for _ in list_added {
                grades[counter].append(0)
            }
            counter += 1
        }
        self.student_to_show = students
    }
    
    // MARK: properties
    weak var delegate: TeacherSubjectsTableViewController?
    
    var subject: Subject?
    var all_students = [User]()
    var tasks = [Task]()
    var dict_tasks = [Task: [User: Int]]()
    var raw_token: String?
    
//    var tasks_to_view = [Subject]()
//    var student_to_show = [Subject]()
//    var all_students = [String]()
//    var grades = [[Int]]()
    
    var cell = Int()
    
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
            self.tasks_to_view = sourceViewController.list_of_tasks
            tableView.reloadData()
        }
        else if let sourceViewController = sender.source as? StudentGradesTableViewController {
            self.grades[sourceViewController.indexTask] = sourceViewController.grades
        }
    }

    
    // MARK: segues information transfer
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowDetailStudent" {
            if let toViewController = segue.destination as? StudentGradesTableViewController {
                toViewController.students = student_to_show
                toViewController.all_students = self.all_students
                toViewController.grades = self.grades[tableView.indexPathForSelectedRow!.row]
                toViewController.indexTask = tableView.indexPathForSelectedRow!.row
                toViewController.delegating = self
                
            } else {
                fatalError("Unable to send data to Student Grades Controller")
            }
        }
        else if segue.identifier == "EditTasksSegue" {
            if let navigationController = segue.destination as? UINavigationController,
                let editSubjectController = navigationController.topViewController as? EditTasksTableViewController {
                    editSubjectController.list_of_tasks = self.tasks_to_view
            } else {
                fatalError("Unable to send data to EditTasksTableViewController")
            }
        }
        else if segue.identifier == "NewTaskSegue" {
            if let navigationController = segue.destination as? UINavigationController,
                let newTaskController = navigationController.topViewController as? NewTaskViewController {
                    newTaskController.raw_token = self.raw_token
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
        self.delegate?.tasksChanged(tasks_to_view, new_students: student_to_show, new_grades: grades, atRow: cell)
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
