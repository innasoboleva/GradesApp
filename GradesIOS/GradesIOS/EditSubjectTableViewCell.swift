//
//  EditSubjectTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/24/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class EditSubjectTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: properties
    @IBOutlet weak var subjectText: UITextField!
    
    weak var delegating: EditSubjectTableViewController?
    var indexNum = Int()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    @IBAction func testEdited(_ sender: UITextField) {
        self.delegating?.changeCell(atIndex: indexNum, name: subjectText.text!)
    }
    
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
        self.delegating?.changeCell(atIndex: indexNum, name: subjectText.text!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
