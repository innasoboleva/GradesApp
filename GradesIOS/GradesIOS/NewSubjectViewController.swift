//
//  NewSubjectViewController.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit
import os.log

class NewSubjectViewController: UIViewController, UITextFieldDelegate {
    // MARK: properties
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var newSubjectName: UITextField!
    
    var raw_token: String?
    var subject: Subject?
    
    // MARK: navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = newSubjectName.text ?? ""
        if newSubjectName.text != nil {
            
            let json: [String: Any] = ["subject": name]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            // post request to add new subject to database
            let url = URL(string: "http://127.0.0.1:8000/polls/add_new_subject/")!
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(raw_token!, forHTTPHeaderField: "Authorization")
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
                        let subject_id = responseJSON["subject_id"] as? String
                        let id = Int(subject_id!)
                        self.subject = Subject(uid: id!, name: name)
                    }
                }
            }
            task.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field’s user input through delegate callbacks.
        newSubjectName.delegate = self
        
        // Enable the Save button only if the text field has a valid Subject name.
   //     updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private Methods
//    private func updateSaveButtonState() {
//        // Disable the Save button if the text field is empty.
//        let text = newSubjectName.text ?? ""
//        saveButton.isEnabled = !text.isEmpty
//    }

}
