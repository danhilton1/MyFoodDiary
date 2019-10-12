//
//  WeekNutritionCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class WeekNutritionCell: UITableViewCell {

    @IBOutlet weak var barChart: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        barChart.leftAxis.drawAxisLineEnabled = true
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.centerAxisLabelsEnabled = true
        barChart.xAxis.axisMinimum = 0
        barChart.xAxis.axisMaximum = 7
        barChart.xAxis.drawAxisLineEnabled = true
        barChart.xAxis.drawGridLinesEnabled = true
        barChart.rightAxis.enabled = false
//        barChart.rightAxis.drawGridLinesEnabled = false
//        barChart.rightAxis.drawAxisLineEnabled = false
        
        
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    
   
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
