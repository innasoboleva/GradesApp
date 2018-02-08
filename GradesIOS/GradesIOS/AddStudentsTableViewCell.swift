//
//  AddStudentsTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class AddStudentsTableViewCell: UITableViewCell {
    
    // MARK: properties
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var buttonAdd: UIButton!
    weak var delegating: AddStudentsTableViewController?
    
    // MARK: actions
    @IBAction func addRemoveStudent(_ sender: Any) {
        if buttonAdd.titleLabel?.text == "Add" {
            buttonAdd.setTitle("Remove", for: UIControlState.normal)
            self.delegating?.addStudent(name: studentName.text!)
        } else {
            buttonAdd.setTitle("Add", for: UIControlState.normal)
            self.delegating?.deleteStudent(name: studentName.text!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
