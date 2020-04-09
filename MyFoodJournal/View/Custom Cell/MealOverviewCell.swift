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

    
    @IBOutlet weak var mainView: UIView!
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
        
        mainView.layer.cornerRadius = 18
        mainView.layer.shadowColor = UIColor.lightGray.cgColor
        mainView.layer.shadowOpacity = 0.35
        mainView.layer.shadowOffset = .zero
        mainView.layer.shadowRadius = 3
        
        checkDeviceAndUpdateConstraints()
        
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
        else if UIScreen.main.bounds.height < 850 {
            proteinLabel.font = proteinLabel.font.withSize(15)
            carbsLabel.font = carbsLabel.font.withSize(15)
            fatLabel.font = fatLabel.font.withSize(15)
            proteinTextLabel.font = proteinTextLabel.font.withSize(15)
            carbsTextLabel.font = carbsTextLabel.font.withSize(15)
            fatTextLabel.font = fatTextLabel.font.withSize(15)
        }
    }
    
    
    func setUpPieChart(section1 protein: Double, section2 carbs: Double, section3 fat: Double) {
        
        pieChart.legend.enabled = false
        pieChart.holeRadiusPercent = 0.5
        pieChart.highlightPerTapEnabled = false
        pieChart.rotationEnabled = false
        
        // If no user entries/data then set default equal values of pie chart to display equal sections
        if protein == 0 && carbs == 0 && fat == 0 {
            
            let chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1.0),
                                                         PieChartDataEntry(value: 1.0),
                                                         PieChartDataEntry(value: 1.0)], label: nil)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
            chartDataSet.selectionShift = 0
            let chartData = PieChartData(dataSet: chartDataSet)
            
            pieChart.data = chartData
            
        } else {
            // Set pie chart data to the total values of protein, carbs and fat from user's entries
            let pieChartEntries = [PieChartDataEntry(value: protein),
                                   PieChartDataEntry(value: carbs),
                                   PieChartDataEntry(value: fat)]
            let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
            chartDataSet.selectionShift = 0
            let chartData = PieChartData(dataSet: chartDataSet)
            
            pieChart.data = chartData
        }
    }
    
}
