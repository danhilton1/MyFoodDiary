//
//  WeekNutritionCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class BarChartNutritionCell: UITableViewCell {

    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var averageValuesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        proteinLabel.textColor = Color.mint
        carbsLabel.textColor = Color.skyBlue
        fatLabel.textColor = Color.salmon
        averageValuesLabel.font = UIFont(name: "Montserrat-Medium", size: 18)!
        
        barChart.highlightPerTapEnabled = false
        barChart.highlightPerDragEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = true
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.centerAxisLabelsEnabled = true
        barChart.xAxis.axisMinimum = 0
        barChart.xAxis.axisMaximum = 7
        barChart.xAxis.drawAxisLineEnabled = true
        barChart.xAxis.drawGridLinesEnabled = true
        barChart.rightAxis.enabled = false
        barChart.leftAxis.axisMinimum = 0
        if UIScreen.main.bounds.height < 600 {
            barChart.xAxis.labelFont = barChart.xAxis.labelFont.withSize(8)
        }
        
//        barChart.rightAxis.drawGridLinesEnabled = false
//        barChart.rightAxis.drawAxisLineEnabled = false
        
        
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    
   
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
