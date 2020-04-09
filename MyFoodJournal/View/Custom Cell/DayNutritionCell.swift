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
    @IBOutlet weak var proteinTextLabel: UILabel!
    @IBOutlet weak var carbsTextLabel: UILabel!
    @IBOutlet weak var fatTextLabel: UILabel!
    @IBOutlet weak var proteinValueLabel: UILabel!
    @IBOutlet weak var carbsValueLabel: UILabel!
    @IBOutlet weak var fatValueLabel: UILabel!
    
    @IBOutlet weak var remainingProteinLabel: UILabel!
    @IBOutlet weak var remainingCarbsLabel: UILabel!
    @IBOutlet weak var remainingFatLabel: UILabel!
    
    
    @IBOutlet weak var proteinPercentLabel: UILabel!
    @IBOutlet weak var carbsPercentLabel: UILabel!
    @IBOutlet weak var fatPercentLabel: UILabel!
    
    @IBOutlet weak var goalProteinLabel: UILabel!
    @IBOutlet weak var goalCarbsLabel: UILabel!
    @IBOutlet weak var goalFatLabel: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var pieChartHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pieChartWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var proteinKeyWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var proteinKeyHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var goalProteinLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var proteinValueLabelLeadingConstraint: NSLayoutConstraint!
    
    
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
        
        carbsPercentLabel.textColor = Color.skyBlue
    }

    
    
    func configurePieChart(calories: Int, protein: Double, carbs: Double, fat: Double) {
        var protein = protein
        var carbs = carbs
        var fat = fat
        let defaults = UserDefaults()
        
        let text = """
                   \(calories)
                   kcal
                   """
        let font = UIFont(name: "Montserrat-Medium", size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font!,
            .paragraphStyle: paragraphStyle
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        pieChart.centerAttributedText = attributedText

        var chartDataSet: PieChartDataSet
        if protein == 0 && carbs == 0 && fat == 0.0 {
            chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1),
                                                         PieChartDataEntry(value: 1),
                                                         PieChartDataEntry(value: 1)], label: nil)
        }
        else {
            chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: protein),
                                                         PieChartDataEntry(value: carbs),
                                                         PieChartDataEntry(value: fat)], label: nil)
        }
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
        chartDataSet.selectionShift = 0
        let chartData = PieChartData(dataSet: chartDataSet)
        
        pieChart.data = chartData
        
        proteinValueLabel.text = protein.removePointZeroEndingAndConvertToString() + " g"
        carbsValueLabel.text = carbs.removePointZeroEndingAndConvertToString() + " g"
        fatValueLabel.text = fat.removePointZeroEndingAndConvertToString() + " g"
        
        var goalProtein = defaults.value(forKey: UserDefaultsKeys.goalProtein) as? Double ?? 0
        var goalCarbs = defaults.value(forKey: UserDefaultsKeys.goalCarbs) as? Double ?? 0
        var goalFat = defaults.value(forKey: UserDefaultsKeys.goalFat) as? Double ?? 0
        var remainingProtein = goalProtein - protein
        var remainingCarbs = goalCarbs - carbs
        var remainingFat = goalFat - fat
        
        remainingProteinLabel.text = remainingProtein.removePointZeroEndingAndConvertToString() + " g"
        remainingCarbsLabel.text = remainingCarbs.removePointZeroEndingAndConvertToString() + " g"
        remainingFatLabel.text = remainingFat.removePointZeroEndingAndConvertToString() + " g"
        
        goalProteinLabel.text = goalProtein.removePointZeroEndingAndConvertToString() + " g"
        goalCarbsLabel.text = goalCarbs.removePointZeroEndingAndConvertToString() + " g"
        goalFatLabel.text = goalFat.removePointZeroEndingAndConvertToString() + " g"
        
        var proteinPercentage = (protein / (protein + carbs + fat)) * 100
        var carbsPercentage = (carbs / (protein + carbs + fat)) * 100
        var fatPercentage = (fat / (protein + carbs + fat)) * 100
        
        if proteinPercentage.isNaN && carbsPercentage.isNaN && fatPercentage.isNaN {
            proteinPercentLabel.text = "0"
            carbsPercentLabel.text = "0"
            fatPercentLabel.text = "0"
        }
        else {
            proteinPercentLabel.text = proteinPercentage.removePointZeroEndingAndConvertToString()
            carbsPercentLabel.text = carbsPercentage.removePointZeroEndingAndConvertToString()
            fatPercentLabel.text = fatPercentage.removePointZeroEndingAndConvertToString()
        }
        
        if UIScreen.main.bounds.height < 600 {
            pieChartWidthConstraint.constant = 150
            pieChartHeightConstraint.constant = 150
            proteinKeyWidthConstraint.constant = 15
            proteinKeyHeightConstraint.constant = 15
            goalProteinLabelCenterXConstraint.isActive = false
            
            proteinTextLabel.font = proteinTextLabel.font.withSize(14)
            carbsTextLabel.font = carbsTextLabel.font.withSize(14)
            fatTextLabel.font = fatTextLabel.font.withSize(14)
            proteinValueLabel.font = proteinValueLabel.font.withSize(14)
            carbsValueLabel.font = carbsValueLabel.font.withSize(14)
            fatValueLabel.font = fatValueLabel.font.withSize(14)
            goalProteinLabel.font = goalProteinLabel.font.withSize(14)
            goalCarbsLabel.font = goalCarbsLabel.font.withSize(14)
            goalFatLabel.font = goalFatLabel.font.withSize(14)
            remainingProteinLabel.font = remainingProteinLabel.font.withSize(14)
            remainingCarbsLabel.font = remainingCarbsLabel.font.withSize(14)
            remainingFatLabel.font = remainingFatLabel.font.withSize(14)
        }
    }
    
}
