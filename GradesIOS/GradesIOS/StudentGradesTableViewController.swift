//
//  StudentGradesTableViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit
import os.log

class StudentGradesTableViewController: UITableViewController, ReturnGrade  {
    // protocol ReturnGrade
    func getGrade(_ grade: Int, atIndex: Int) {
        users_array[atIndex].user_grade = grade
        user_grades[users_array[atIndex].user] = grade
    }
    
    // MARK: properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    weak var delegating: TasksTableViewController?
    
    var subject: Subject?
    var current_task: Task?
    var all_students = [User]()
    var user_grades = [User: Int]()
    var raw_token: String?
    // for displaying tableview controller
    struct Users {
        var user_name : String
        var user: User
        var user_grade : Int
    }
    var users_array = [Users]()
    
    // navigation 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "AddStudents" {
            if let navigationController = segue.destination as? UINavigationController,
                let editStudentListController = navigationController.topViewController as? AddStudentsTableViewController {
                editStudentListController.all_students = self.all_students
                editStudentListController.current_students = self.user_grades
                editStudentListController.delegate = delegating
            } else {
                fatalError("Unable to send data to Tasks view")
            }
        }
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dict_keys = user_grades.keys
        for key in dict_keys {
            users_array.append(Users(user_name: key.name, user: key, user_grade: user_grades[key]!))
        }

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
        return users_array.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "StudentGradesTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StudentGradesTableViewCell else {
            fatalError("The dequeued cell is not an instance of StudentGradesTableViewCell.")
        }
        // Fetches the appropriate student info for the data source layout.
        let student = users_array[indexPath.row]
        cell.delegating = self
        cell.studentName.text = student.user_name
        cell.index = indexPath.row
        cell.current_grade = student.user_grade
        cell.studentGrade.selectRow(student.user_grade, inComponent: 0, animated: false)

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
