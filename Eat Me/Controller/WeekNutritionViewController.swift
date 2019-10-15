//
//  WeekNutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class WeekNutritionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BarChartNutritionCell", bundle: nil), forCellReuseIdentifier: "BarNutritionCell")
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
        tableView.allowsSelection = false
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BarNutritionCell", for: indexPath) as! BarChartNutritionCell
        
        let proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 120),
                                                            BarChartDataEntry(x: 1, y: 100),
                                                            BarChartDataEntry(x: 2, y: 110),
                                                            BarChartDataEntry(x: 3, y: 86),
                                                            BarChartDataEntry(x: 4, y: 98),
                                                            BarChartDataEntry(x: 5, y: 74),
                                                            BarChartDataEntry(x: 6, y: 103)],
                                                            label: "Protein")
        let carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 230),
                                                          BarChartDataEntry(x: 1, y: 260),
                                                          BarChartDataEntry(x: 2, y: 195),
                                                          BarChartDataEntry(x: 3, y: 207),
                                                          BarChartDataEntry(x: 4, y: 214),
                                                          BarChartDataEntry(x: 5, y: 257),
                                                          BarChartDataEntry(x: 6, y: 220)],
                                                          label: "Carbs")
        let fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 80),
                                                        BarChartDataEntry(x: 1, y: 90),
                                                        BarChartDataEntry(x: 2, y: 72),
                                                        BarChartDataEntry(x: 3, y: 79),
                                                        BarChartDataEntry(x: 4, y: 89),
                                                        BarChartDataEntry(x: 5, y: 104),
                                                        BarChartDataEntry(x: 6, y: 77)],
                                                        label: "Fat")
        let chartDataSets = [proteinChartDataSet, carbsChartDataSet, fatChartDataSet]
        proteinChartDataSet.colors = [Color.mint]
        carbsChartDataSet.colors = [Color.skyBlue]
        fatChartDataSet.colors = [Color.salmon]
        let chartData = BarChartData(dataSets: chartDataSets)
        chartData.barWidth = 0.24
        chartData.groupBars(fromX: 0, groupSpace: 0.16, barSpace: 0.04)
        cell.barChart.data = chartData
        
        
        return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            
            let chartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 2450),
                                                          ChartDataEntry(x: 1, y: 2582),
                                                          ChartDataEntry(x: 2, y: 2340),
                                                          ChartDataEntry(x: 3, y: 2120),
                                                          ChartDataEntry(x: 4, y: 2460),
                                                          ChartDataEntry(x: 5, y: 2890),
                                                          ChartDataEntry(x: 6, y: 3102),], label: "Calories")
            chartDataSet.colors = [Color.skyBlue]
            chartDataSet.circleColors = [Color.skyBlue]
            chartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
//            for value in chartDataSet.entries {
//                if value.y >= 2400 || value.y <= 2600 {
//
////                    chartDataSet.circleColors = [Color.mint]
//                } else {
//                    chartDataSet.setCircleColor(Color.salmon)
//                    //chartDataSet.circleColors = [Color.salmon]
//                }
//            }
            let chartData = LineChartData(dataSet: chartDataSet)
            cell.lineChart.data = chartData
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 440
        }
        else {
            return 400
        }
    }
    
}
