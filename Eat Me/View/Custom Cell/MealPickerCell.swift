//
//  MealPickerCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 13/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class MealPickerCell: UITableViewCell {

    
    @IBOutlet weak var mealPicker: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
