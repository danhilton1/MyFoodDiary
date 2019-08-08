//
//  MealOverviewCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class MealOverviewCell: UITableViewCell {

    
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
   
    @IBOutlet weak var proteinTextLabel: UILabel!
    @IBOutlet weak var carbsTextLabel: UILabel!
    @IBOutlet weak var fatTextLabel: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        proteinTextLabel.textColor = UIColor.flatMint()
        carbsTextLabel.textColor = UIColor.flatSkyBlue()
        fatTextLabel.textColor = UIColor.flatWatermelon()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
