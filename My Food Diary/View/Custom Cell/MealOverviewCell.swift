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
    
    @IBOutlet weak var pieChartWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pieChartTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        proteinTextLabel.textColor = Color.mint
        carbsTextLabel.textColor = Color.skyBlue
        fatTextLabel.textColor = Color.salmon
        
        checkDeviceAndUpdateConstraints()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func checkDeviceAndUpdateConstraints() {
        if UIScreen.main.bounds.height < 600 {
            pieChartWidthConstraint.constant = 100
            pieChartTrailingConstraint.constant = 2
//            proteinTextLabel.text = "P"
//            carbsTextLabel.text = "C"
//            fatTextLabel.text = "F"
            proteinLabel.font = proteinLabel.font.withSize(14)
            carbsLabel.font = carbsLabel.font.withSize(14)
            fatLabel.font = fatLabel.font.withSize(14)
            proteinTextLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
            carbsTextLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
            fatTextLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
            
            calorieLabel.font = calorieLabel.font.withSize(20)
        }
    }
    
}
