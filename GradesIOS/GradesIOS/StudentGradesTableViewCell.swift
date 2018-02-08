//
//  StudentGradesTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class StudentGradesTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
   
    // MARK: propeties
    
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var studentGrade: UIPickerView!
    
    weak var delegating: StudentGradesTableViewController?
    
    var index = Int()
    let grades = [" ", "A","B","C","D","E"]
    var current_grade = Int()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        studentGrade.dataSource = self
        studentGrade.delegate = self
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return grades.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return grades[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.delegating?.getGrade(row, atIndex: self.index)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
