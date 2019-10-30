//
//  FoodHistoryCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class FoodHistoryCell: UITableViewCell {
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var totalServingLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
