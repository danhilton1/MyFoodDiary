//
//  MealDetailCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 03/07/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class MealDetailCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
