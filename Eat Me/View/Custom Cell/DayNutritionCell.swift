//
//  DayNutritionCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class DayNutritionCell: UITableViewCell {
    
    
    @IBOutlet weak var proteinKey: UIView!
    @IBOutlet weak var carbsKey: UIView!
    @IBOutlet weak var fatKey: UIView!
    
    
    @IBOutlet weak var pieChart: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pieChart.legend.enabled = false
        pieChart.holeRadiusPercent = 0.4
        pieChart.transparentCircleRadiusPercent = 0.4
        pieChart.highlightPerTapEnabled = false
        pieChart.rotationEnabled = false
        
        proteinKey.layer.cornerRadius = proteinKey.frame.size.width / 2
        carbsKey.layer.cornerRadius = carbsKey.frame.size.width / 2
        fatKey.layer.cornerRadius = fatKey.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
