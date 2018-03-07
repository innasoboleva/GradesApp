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
    
    // actions
    @IBAction func logout(_ sender: Any) {
        KeychainService.removePassword(service: "GradesIOS", account: "token")
        let story = UIStoryboard(name: "Main", bundle: nil)
        guard let nextController = story.instantiateInitialViewController() else {
            assertionFailure("Unable to load main view controller")
            return
        }
        OperationQueue.main.addOperation {
            self.present(nextController, animated: true, completion: nil)
        }
    }
    
    
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
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // deleting class
            let old_dict = data_subjects.removeValue(forKey: subjects[indexPath.row])
            let removed_tasks = data_grades.removeValue(forKey: subjects[indexPath.row])
            let removed_subject = self.subjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let json: [String: Any] = ["subject_id": removed_subject]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // post request to delete class in database
            let url = URL(string: "http://127.0.0.1:8000/polls/remove_subject_student/")!
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
                    if responseJSON["detail"] as? String == "Signature has expired." {
                        self.logout()
                    }
                    else if responseJSON["status"] as? String != "ok" {
                        self.present_alert("Could not remove class, please try again.")
                        
                        self.data_grades[self.subjects[indexPath.row]] = removed_tasks
                        self.data_subjects[self.subjects[indexPath.row]] = old_dict
                        self.subjects.append(removed_subject)
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
