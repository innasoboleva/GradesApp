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
    // MARK: actions
    @IBAction func checkUserButton(_ sender: Any) {
        loadTeacher()
    }
    
    private func loadTeacher() {
        let story = UIStoryboard(name: "Teacher", bundle: nil)
        
        guard let teacherController = story.instantiateInitialViewController() else {
            assertionFailure("Unable to load teacher view controller")
            return
        }
        
        present(teacherController, animated: true, completion: nil)
    }
    
    private func loadStudent() {

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

