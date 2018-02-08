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
    var token = "JWT "
    var raw_token: String?
    
    // MARK: actions
    @IBAction func checkUserButton(_ sender: Any) {
        checkUser3()
        //loadPage("Student")
    }
    
    // JSON data
    
    // MARK: private method
    private func checkUser3() {
        
        let json: [String: Any] = ["password": passwordText.text, "username": loginText.text]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // post request
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
                print(responseJSON)
                self.raw_token = responseJSON["token"] as? String
                
                let url2 = URL(string: "http://127.0.0.1:8000/polls/load/")!
                var request2 = URLRequest(url: url2)
//                let tok = String("Token \(self.raw_token!)")
                 let tok = String(self.raw_token!)
                request2.addValue(tok, forHTTPHeaderField: "Authorization")
                //request2.addValue("application/json", forHTTPHeaderField: "Content-Type")
                //request2.httpMethod = "GET"
                //request2.httpBody = data2
                
                let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
                    let resp = try? JSONSerialization.jsonObject(with: data2!, options: [])
                    if let resp = resp as? [String: Any] {
                        print(resp)
                    }
                    
                }
                task2.resume()
            }
        }
        
        task.resume()
        
    }
    
    private func loadPage(_ name: String) {
        let story = UIStoryboard(name: name, bundle: nil)
        
        guard let nextController = story.instantiateInitialViewController() else {
            assertionFailure("Unable to load teacher view controller")
            return
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

