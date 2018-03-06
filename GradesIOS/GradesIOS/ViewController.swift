//
//  ViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/19/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
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
            let json: [String: Any] = ["password": sourceViewController.passwordText.text as Any, "username": sourceViewController.usernameText.text as Any, "email":sourceViewController.emailText.text as Any, "first_name": sourceViewController.firstName.text as Any, "last_name": sourceViewController.lastName.text as Any, "is_teacher": teacher]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // post request to register a new user and recieve a token
            let url = URL(string: "http://127.0.0.1:8000/polls/new_user/")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    if error?._code == NSURLErrorTimedOut {
                        self.present_alert("Server is not responding. Please, try again later.")
                    }
                    else if error?._code == NSURLErrorCannotConnectToHost {
                        self.present_alert("Server is not responding. Please, try again later.")
                    }
                    else if error?._code == NSURLErrorNetworkConnectionLost {
                        // make second request, to try again
                        
                        let taskTry = URLSession.shared.dataTask(with: request) { dataTry, responseTry, errorTry in
                            guard let dataTry = dataTry, errorTry == nil else {
                                self.present_alert("Please, try again later.")
                                print(errorTry?.localizedDescription ?? "No data")
                                return
                            }
                            let responseJSON = try? JSONSerialization.jsonObject(with: dataTry, options: [])
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
                        taskTry.resume()
                    }
                    print(error?.localizedDescription ?? "No data")
                    return
                }
            // the actual request response
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
        let url = URL(string: "http://127.0.0.1:8000/polls/api-token-auth/")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                if error?._code == NSURLErrorTimedOut {
                    self.present_alert("Server is not responding. Please, try again later.")
                }
                else if error?._code == NSURLErrorCannotConnectToHost {
                    self.present_alert("Server is not responding. Please, try again later.")
                }
                else if error?._code == NSURLErrorNetworkConnectionLost {
                    // make second request, to try again
                    
                    let taskTry = URLSession.shared.dataTask(with: request) { dataTry, responseTry, errorTry in
                        guard let dataTry = dataTry, errorTry == nil else {
                                self.present_alert("Please, try again later.")
                            print(errorTry?.localizedDescription ?? "No data")
                            return
                        }
                        // teh actual dataTask request response
                        let responseJSONTry = try? JSONSerialization.jsonObject(with: dataTry, options: [])
                        if let responseJSONTry = responseJSONTry as? [String: Any] {
                            if let token = responseJSONTry["token"] as? String {
                                self.raw_token = token
                                
                                // post request to get info about user
                                let url2 = URL(string: "http://127.0.0.1:8000/polls/check_login/")!
                                var request2 = URLRequest(url: url2)
                                request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
                                request2.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                                request2.httpMethod = "POST"
                                
                                let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
                                    guard let data2 = data2, error2 == nil else {
                                        print(error2?.localizedDescription ?? "No data")
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
                                            self.present_alert("Incorrect login or password, please try again.")
                                        }
                                    }
                                }
                                task2.resume()
                            } else {
                                self.present_alert("Could not access your page, please try again.")
                            }
                        }
                    }
                    taskTry.resume()
                }
                print(error?.localizedDescription ?? "No data")
                return
            }
            // the actual dataTask request response
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let token = responseJSON["token"] as? String {
                    self.raw_token = token
 
                // post request to get info about user
                let url2 = URL(string: "http://127.0.0.1:8000/polls/check_login/")!
                var request2 = URLRequest(url: url2)
                request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request2.addValue("JWT \(self.raw_token!)", forHTTPHeaderField: "Authorization")
                request2.httpMethod = "POST"

                let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
                    guard let data2 = data2, error2 == nil else {
                        if error2?._code == NSURLErrorTimedOut {
                            self.present_alert("Server is not responding. Please, try again later.")
                        }
                        else if error2?._code == NSURLErrorCannotConnectToHost {
                            self.present_alert("Server is not responding. Please, try again later.")
                        }
                        else if error2?._code == NSURLErrorNetworkConnectionLost {
                            // make second request, to try again
                            
                            let taskTry = URLSession.shared.dataTask(with: request2) { dataTry, responseTry, errorTry in
                                guard let dataTry = dataTry, errorTry == nil else {
                                    self.present_alert("Please, try again later.")
                                    print(errorTry?.localizedDescription ?? "No data")
                                    return
                                }
                                
                                let responseJSON2 = try? JSONSerialization.jsonObject(with: dataTry, options: [])
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
                                        self.present_alert("Incorrect login or password, please try again.")
                                    }
                                }
                            }
                            taskTry.resume()
                        } else {
                            self.present_alert("Could not access your page, please try again.")
                        }

                        print(error2?.localizedDescription ?? "No data")
                        return
                    }
                    // the actual request response
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
                            self.present_alert("Incorrect login or password, please try again.")
                        }
                    }
                }
                task2.resume()
                } else {
                    self.present_alert("Could not access your page, please try again.")
                }
            }
        }
        task.resume()
    }
    
    private func present_alert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        alertController.addAction(okAction)
        OperationQueue.main.addOperation {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginText.delegate = self
        self.passwordText.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

