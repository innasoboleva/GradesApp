//
//  AddStudentsTableViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class AddStudentsTableViewController: UITableViewController, AddRemoveStudents {
    
    weak var delegate: TasksTableViewController?
 //   weak var delegating: StudentGradesTableViewController?
    
    func addStudent(name: String) {
        let new_student = Subject(name: name)
        subject_students.append(new_student!)
        let indexOfName = all_students.index(of: name)
        list_of_added_students.insert(indexOfName!)
    }
    
    func deleteStudent(name: String) {
        let student = Subject(name: name)
        let indexOfPerson = subject_students.index(of: student!)
        subject_students.remove(at: indexOfPerson!)
        let indexOfName = all_students.index(of: name)
        list_of_removed_students.insert(indexOfName!)
        
    }
    
    
    var all_students = [String]()
    var students = [Subject]()
    var subject_students = [Subject]()
    var list_of_added_students = Set<Int>()
    var list_of_removed_students = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleSubjects()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.studentsChanged(subject_students, list_added: list_of_added_students, list_removed: list_of_removed_students)
      //  self.delegating?.newStudents(subject_students)
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
        return students.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AddStudentsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddStudentsTableViewCell else {
            fatalError("The dequeued cell is not an instance of AddStudentsTableViewCell.")
        }
        // Fetches the appropriate task for the data source layout.
        let student = students[indexPath.row]
        
        cell.studentName.text = student.name
        cell.delegating = self
        
        for x in subject_students {
            if x.name == student.name
            {
                cell.buttonAdd.setTitle("Remove", for: UIControlState.normal)
                break
            }
        }
        

        return cell
    }
 

    // MARK: private methods
    
    private func loadSampleSubjects() {
        for i in all_students {
            guard let student = Subject(name: i) else {
                fatalError("Unable to instantiate Student named: "+"\(i)")
            }
            students.append(student)
        }
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
