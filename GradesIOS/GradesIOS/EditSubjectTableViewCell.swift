//
//  EditSubjectTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/24/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class EditSubjectTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegating: EditSubjectTableViewController?
    var indexNum = Int()

    @IBOutlet weak var subjectText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    

    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        self.delegating?.changeCell(self, atIndex: indexNum, name: subjectText.text!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
