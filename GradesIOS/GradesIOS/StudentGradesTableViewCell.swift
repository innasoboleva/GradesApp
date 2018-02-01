//
//  StudentGradesTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/23/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class StudentGradesTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
   
    let grades = [" ", "A","B","C","D","E"]
    var current_grade = Int()
    
    weak var delegating: StudentGradesTableViewController?
    var index = Int()
    
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
    

    // MARK: properties
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var studentGrade: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        studentGrade.dataSource = self
        studentGrade.delegate = self
        
   //     studentGrade.selectRow(self.current_grade, inComponent: 0, animated: false)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
