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
        if let sourceViewController = sender.source as? RegistrationViewController{
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
                    self.raw_token = responseJSON["token"] as? String
                    
                    if teacher == "true" {
                        let story = UIStoryboard(name: "Teacher", bundle: nil)
                        guard let nextController = story.instantiateInitialViewController() else {
                            assertionFailure("Unable to load teacher view controller")
                            return
                        }
                        if let navigationController = nextController as? UINavigationController,
                            let teacherSubjectController = navigationController.topViewController as? TeacherSubjectsTableViewController {
                            
                            teacherSubjectController.raw_token = self.raw_token
                            teacherSubjectController.all_students_data = (responseJSON["all_students"] as? [String: [String]])!
                        }
                        self.present(nextController, animated: true, completion: nil)
                    } else {
                        
                        let story = UIStoryboard(name: "Student", bundle: nil)
                        guard let nextController = story.instantiateInitialViewController() else {
                            assertionFailure("Unable to load student view controller")
                            return
                        }
                        if let navigationController = nextController as? UINavigationController,
                            let studentSubjectController = navigationController.topViewController as? StudentSubjectTableViewController {
                            
                            studentSubjectController.raw_token = self.raw_token
                        }
                        self.present(nextController, animated: true, completion: nil)
                    }
                }
            }
            task.resume()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    // MARK: private method
    private func login() {
        let json: [String: String] = ["password": passwordText.text!, "username": loginText.text!]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        // post request to get info about user
        let url = URL(string: "http://127.0.0.1:8000/polls/get_auth_token/")!
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
                if let token = responseJSON["token"] as? String {
                    self.raw_token = token
 //                   NSLog("\(self.raw_token)")
                
                    
//                    // token authentification in django
//                    let url2 = URL(string: "http://127.0.0.1:8000/polls/check_login_token/")!
//                    var request2 = URLRequest(url: url2)
//                    request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                    request2.addValue("Token \(self.raw_token!)", forHTTPHeaderField: "Authorization")
//                    request2.httpMethod = "POST"
                    
                    
                // post request to get info about user
                let url2 = URL(string: "http://127.0.0.1:8000/polls/check_login/")!
                var request2 = URLRequest(url: url2)
                request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request2.addValue(self.raw_token!, forHTTPHeaderField: "Authorization")
                request2.httpMethod = "POST"

                let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
                    guard let data2 = data2, error2 == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON2 = try? JSONSerialization.jsonObject(with: data2, options: [])
                    if let responseJSON2 = responseJSON2 as? [String: Any] {

                        if responseJSON2["status"] as? String == "ok" {

                            if responseJSON2["is_teacher"] as! String? == "true" {

                                let data_subjects = responseJSON2["data_subjects"] as! [String: String]
                                let data_tasks = responseJSON2["data_task"] as! [String: [String: String]]
                                let all_data = responseJSON2["all_data"] as! [String: [String: [[String]]]]
                                let all_students = responseJSON2["all_students"] as! [String: [String]]

                                let story = UIStoryboard(name: "Teacher", bundle: nil)
                                guard let nextController = story.instantiateInitialViewController() else {
                                    assertionFailure("Unable to load teacher view controller")
                                    return
                                }
                                if let navigationController = nextController as? UINavigationController,
                                    let teacherSubjectController = navigationController.topViewController as? TeacherSubjectsTableViewController {

                                    teacherSubjectController.raw_token = self.raw_token
                                    teacherSubjectController.data_subjects = data_subjects
                                    teacherSubjectController.data_tasks = data_tasks
                                    teacherSubjectController.all_data = all_data
                                    teacherSubjectController.all_students_data = all_students
                                    
                                    OperationQueue.main.addOperation {
                                        self.present(nextController, animated: true, completion: nil)
                                }
                                
                                }
                            }
                            else {
                                let story = UIStoryboard(name: "Student", bundle: nil)
                                guard let nextController = story.instantiateInitialViewController() else {
                                    assertionFailure("Unable to load student view controller")
                                    return
                                }
                                if let navigationController = nextController as? UINavigationController,
                                    let studentSubjectController = navigationController.topViewController as? StudentSubjectTableViewController {

                                    studentSubjectController.raw_token = self.raw_token
                                    if let data_subjects = responseJSON2["data_subject_student"] as? [String: String] {
                                        studentSubjectController.data_subjects = data_subjects
                                    }
                                    if let data_grades = responseJSON2["data_task_student"] as? [String: [String: String]] {
                                        studentSubjectController.data_grades = data_grades
                                    }
                                    
                                    
                                    OperationQueue.main.addOperation {
                                        self.present(nextController, animated: true, completion: nil)
                                }
                                
                                }
                            }
                        }
                        else {
                            let alertController = UIAlertController(title: "No user was found", message: "Incorrect login or password, please try again.", preferredStyle: UIAlertControllerStyle.alert)

                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                            alertController.addAction(okAction)
                            
                            OperationQueue.main.addOperation {
                                self.present(alertController, animated: true, completion: nil)
                            }
                            
                        }

                    }
                }
                task2.resume()
                } else {
                    let alertController = UIAlertController(title: "No token", message: "Could not access your page, please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        task.resume()
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

