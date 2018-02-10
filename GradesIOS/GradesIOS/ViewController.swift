//
//  ViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/19/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: properties
    @IBOutlet weak var loginText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    var raw_token: String?
    
    // MARK: actions
    @IBAction func checkUserButton(_ sender: Any) {
        login()
    }
    
    // MARK: navigation
    
    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? RegisterTableViewController{
            var teacher = String()
            if sourceViewController.isTeacher.isOn == true {
                teacher = "true"
            } else {
                teacher = "false"
            }
            let json: [String: Any] = ["password": sourceViewController.passwordText.text, "username": sourceViewController.usernameText.text, "email":sourceViewController.emailText.text, "first_name": sourceViewController.firstName.text, "last_name": sourceViewController.lastName.text, "is_teacher": teacher]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // post request to register a new user and recieve a token
            let url = URL(string: "http://127.0.0.1:8000/polls/new_user/")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    self.raw_token = responseJSON["token"] as? String
                }
            }
            
            task.resume()
            
            if sourceViewController.isTeacher.isOn == true {
                //loadPage("Teacher")
            } else {
                //loadPage("Student")
            }
        }
    }
    
    // MARK: private method
    private func login() {
        
        let json: [String: Any] = ["password": passwordText.text, "username": loginText.text]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // post request to get info about user
        let url = URL(string: "http://127.0.0.1:8000/polls/login/")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                
                self.raw_token = responseJSON["token"] as? String
                if responseJSON["is_teacher"] as! String? == "true" {
                    
                    let data_subjects = responseJSON["data_subjects"] as! [String: String]
                    let data_tasks = responseJSON["data_task"] as! [String: [String]]
                    let all_data = responseJSON["all_data"] as! [String: [String: [String]]]
                    let all_students = responseJSON["all_students"] as! [String: (String, String)]
                    
                }
                else {
                    
                    let data_subjects = responseJSON["data_subject_student"] as! [String: String]
                    let data_grades = responseJSON["data_task_student"] as! [String: [String: String]]
                }
                
            }
        }
        
        task.resume()
        
    }
    
    private func loadPage(_ name: String, subjects: Any?, tasks: Any?, all_data: Any?, all_students: Any?) {
        let story = UIStoryboard(name: name, bundle: nil)
        
        guard let nextController = story.instantiateInitialViewController() else {
            assertionFailure("Unable to load teacher view controller")
            return
        }
        if let navigationController = nextController as? UINavigationController,
            let teacherSubjectController = navigationController.topViewController as? TeacherSubjectsTableViewController {
            
            var data_subjects = ["Astronomy", "Data Science", "Math", "Education", "Physics"]
            var data_tasks = [["Planets", "Mercury", "Asteroids"],["Programming"], ["Logarithm", "Squares"], [],["Laws of nature"]]
            var data_students = [["Anna","Maria","Inna"],
                                 ["Alex"],
                                 ["Alex", "Inna"],
                                 ["James", "Jacob"],
                                 ["Inna","Alex"]]
            var all_students = ["Inna", "Alex", "Maria", "Tony", "Carla", "Jamie", "Anna", "James", "Jacob"]
            var students_grades = [[[Int]]]()
            
            //teacherSubjectController.data_subjects
            
        }
        present(nextController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

