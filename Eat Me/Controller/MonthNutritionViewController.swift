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

class MonthNutritionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "WeekNutritionCell", bundle: nil), forCellReuseIdentifier: "WeekNutritionCell")
        tableView.allowsSelection = false
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekNutritionCell", for: indexPath) as! WeekNutritionCell
        
        cell.barChart.xAxis.axisMaximum = 5
        
        cell.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["30th - 6th", "7th - 13th", "14th - 20th", "21st - 27th"])
        let proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 120),
                                                            BarChartDataEntry(x: 1, y: 100),
                                                            BarChartDataEntry(x: 2, y: 110),
                                                            BarChartDataEntry(x: 3, y: 86)],
                                                            label: "Average Protein")
        let carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 230),
                                                          BarChartDataEntry(x: 1, y: 260),
                                                          BarChartDataEntry(x: 2, y: 195),
                                                          BarChartDataEntry(x: 3, y: 207)],
                                                          label: "Average Carbs")
        let fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 80),
                                                        BarChartDataEntry(x: 1, y: 90),
                                                        BarChartDataEntry(x: 2, y: 72),
                                                        BarChartDataEntry(x: 3, y: 79)],
                                                        label: "Average Fat")
        let chartDataSets = [proteinChartDataSet, carbsChartDataSet, fatChartDataSet]
        proteinChartDataSet.colors = [Color.mint]
        carbsChartDataSet.colors = [Color.skyBlue]
        fatChartDataSet.colors = [Color.salmon]
        let chartData = BarChartData(dataSets: chartDataSets)
        chartData.barWidth = 0.28
        chartData.groupBars(fromX: 0, groupSpace: 0.2, barSpace: 0.05)
        cell.barChart.data = chartData
        
        
        return cell
    }
    

}
