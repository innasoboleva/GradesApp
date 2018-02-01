//
//  EditTasksTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/29/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class EditTasksTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: properties
    weak var delegating: EditTasksTableViewController?
    var indexNum = Int()
    
    @IBOutlet weak var taskName: UITextField!
    
    // MARK: actions
//    @IBAction func didFinishEditingCell(_ sender: UITextField) {
//
//    }
    
    @IBAction func didEditCell(_ sender: UITextField) {
        self.delegating?.changeCell(self, atIndex: indexNum, name: taskName.text!)
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
