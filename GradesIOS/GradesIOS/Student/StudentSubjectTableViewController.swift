//
//  StudentSubjectTableViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class StudentSubjectTableViewController: UITableViewController {
    
    // initial data
    var raw_token: String?
    var data_subjects = [String: String]() // id:name
    var data_grades = [String: [String: String]]() // subject_id: [task_name: task_grade]
    
    var subjects = [String]()
    
//    var subjects = ["Astronomy", "Math", "Pysics", "Astrology", "Literature"]
//    var tasks = [["Stars", "Asteroids", "Meteors"], ["Logarithm"], ["One"], ["Two"], ["Three"]]
//    var grades = [["A", "B", "C"], ["A"],["A"], ["B"], ["B"]]
    
    // navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let toViewController = segue.destination as? TaskGradesTableViewController {
            toViewController.tasks_to_show = data_grades[subjects[tableView.indexPathForSelectedRow!.row]]!
        } else {
            fatalError("Unable to send data to Tasks view")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subjects = Array(data_subjects.keys)
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
        
        let cellIdentifier = "StudentSubjectTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StudentSubjectTableViewCell else {
            fatalError("The dequeued cell is not an instance of StudentSubjectTableViewCell.")
        }
        // Fetches the appropriate subject for the data source layout.
        cell.subjectName.text = data_subjects[subjects[indexPath.row]]
        
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
