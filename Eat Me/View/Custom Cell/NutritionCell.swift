//
//  NutritionViewCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 13/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class NutritionCell: UITableViewCell {

    @IBOutlet weak var nutrientLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}