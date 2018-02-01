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
    /*
     This value is either passed by `NewSubjectViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new subject.
     */
    var subject: Subject?
    
    // MARK: actions
    
    
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
        subject = Subject(name: name)
    }
    
    //MARK: UITextFieldDelegate
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        // Disable the Save button while editing.
//        saveButton.isEnabled = false
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        updateSaveButtonState()
//        navigationItem.title = textField.text
//    }
    
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
