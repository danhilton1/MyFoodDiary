//
//  MonthNutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class MonthNutritionViewController: WeekNutritionViewController {
    
    
    //@IBOutlet weak var tableView: UITableView!
    
    
    var monthAverageProtein: Double?
    var monthAverageCarbs: Double?
    var monthAverageFat: Double?
    var monthAverageCalories: Double?
    var reverse: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(UINib(nibName: "BarChartNutritionCell", bundle: nil), forCellReuseIdentifier: "BarNutritionCell")
//        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
//        tableView.allowsSelection = false
        
    }
    

    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarNutritionCell", for: indexPath) as! BarChartNutritionCell
            
            let VC = parent as? NutritionViewController
            
            cell.barChart.xAxis.granularityEnabled = true
            var chartData: BarChartData
            
            if reverse {
                cell.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: VC?.monthChartLabels.reversed() ?? ["1", "2", "3", "4", "5"])

                cell.barChart.xAxis.axisMaximum = Double(proteinChartDataSet.count)
                let reversedProteinDataSet = BarChartDataSet(entries: proteinChartDataSet.reversed(), label: "Av. Protein / Day")
                let reversedCarbsDataSet = BarChartDataSet(entries: carbsChartDataSet.reversed(), label: "Av. Carbs / Day")
                let reversedFatDataSet = BarChartDataSet(entries: fatChartDataSet.reversed(), label: "Av. Fat / Day")
                let chartDataSets = [reversedProteinDataSet, reversedCarbsDataSet, reversedFatDataSet]
                //let chartDataSets = [proteinChartDataSet, carbsChartDataSet, fatChartDataSet]//.reversed()
                reversedProteinDataSet.colors = [Color.mint]
                reversedCarbsDataSet.colors = [Color.skyBlue]
                reversedFatDataSet.colors = [Color.salmon]
                chartData = BarChartData(dataSets: chartDataSets)
            }
            else {
                cell.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: VC?.monthChartLabels ?? ["1", "2", "3", "4", "5"])
                cell.barChart.xAxis.axisMaximum = Double(proteinChartDataSet.count)
                let chartDataSets = [proteinChartDataSet, carbsChartDataSet, fatChartDataSet]
                proteinChartDataSet.colors = [Color.mint]
                carbsChartDataSet.colors = [Color.skyBlue]
                fatChartDataSet.colors = [Color.salmon]
                chartData = BarChartData(dataSets: chartDataSets)
                
            }
            chartData.setValueFormatter(XValueFormatter())
            chartData.barWidth = 0.23
            chartData.groupBars(fromX: 0, groupSpace: 0.16, barSpace: 0.05)
            cell.barChart.animate(yAxisDuration: 0.5)
            cell.barChart.data = chartData
            
            var averageProtein = 0.0
            var averageCarbs = 0.0
            var averageFat = 0.0
            for value in proteinChartDataSet.entries {
                averageProtein += value.y
            }
            averageProtein = averageProtein / Double(proteinChartDataSet.entries.count)
            for value in carbsChartDataSet.entries {
                averageCarbs += value.y
            }
            averageCarbs = averageCarbs / Double(carbsChartDataSet.entries.count)
            for value in fatChartDataSet.entries {
                averageFat += value.y
            }
            averageFat = averageFat / Double(fatChartDataSet.entries.count)
            
            cell.proteinLabel.text = averageProtein.removePointZeroEndingAndConvertToString() + " g"
            cell.carbsLabel.text = averageCarbs.removePointZeroEndingAndConvertToString() + " g"
            cell.fatLabel.text = averageFat.removePointZeroEndingAndConvertToString() + " g"
            
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            
            cell.lineChart.xAxis.granularityEnabled = true
            cell.lineChart.xAxis.axisMaximum = 3.5
            let limitLine = ChartLimitLine(limit: 2500, label: "") // Set to actual goal
            limitLine.lineDashLengths = [8]
            limitLine.lineWidth = 1.5
            limitLine.lineColor = Color.mint
            limitLine.valueFont = UIFont(name: "Montserrat-Regular", size: 12)!
            
            cell.lineChart.leftAxis.addLimitLine(limitLine)
            cell.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Week 1", "Week 2", "Week 3",
            "Week 4"])
//            print(lineChartDataSet.first)
            //print(lineChartDataSet.reversed())
            //let reversedCalorieDataSet = LineChartDataSet(entries: lineChartDataSet.reversed(), label: "Av. Calories")
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            // NEEDS CHANGING AND FIXING
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            cell.lineChart.data = chartData
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 440
//        }
//        else {
//            return 400
//        }
//    }
    

}
