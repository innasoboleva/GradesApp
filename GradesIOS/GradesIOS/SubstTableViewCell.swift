//
//  substTableViewCell.swift
//  GradesIOS
//
//  Created by Inna Soboleva on 1/19/18.
//  Copyright © 2018 Inna Soboleva. All rights reserved.
//

import UIKit

class SubstTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var subjectName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
