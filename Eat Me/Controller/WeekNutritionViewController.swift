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
    
    let realm = try! Realm()
    
    var foodList: Results<Food>?
    var date: Date?
    
    var protein: Double {
        get { getTotalValueOfNutrient(.protein) }
        set { }
    }
    var carbs: Double {
        get { getTotalValueOfNutrient(.carbs) }
        set { }
    }
    var fat: Double {
        get { getTotalValueOfNutrient(.fat) }
        set { }
    }
    var calories: Double {
        get { getTotalValueOfNutrient(.calories) }
        set { }
    }
    
    var proteinChartDataSet =  BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)], label: "Protein")
    var carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)], label: "Carbs")
    var fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)], label: "Fat")
    var lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0)], label: "Calories")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        foodList = realm.objects(Food.self)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BarChartNutritionCell", bundle: nil), forCellReuseIdentifier: "BarNutritionCell")
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
        tableView.allowsSelection = false
        
    }
    
    
    func reloadFood() {
        tableView.reloadData()
    }
    


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BarNutritionCell", for: indexPath) as! BarChartNutritionCell
            
            proteinChartDataSet.valueFont = UIFont(name: "Montserrat-Medium", size: 9)!
            carbsChartDataSet.valueFont = UIFont(name: "Montserrat-Medium", size: 9)!
            fatChartDataSet.valueFont = UIFont(name: "Montserrat-Medium", size: 9)!
            
            let chartDataSets = [proteinChartDataSet, carbsChartDataSet, fatChartDataSet]
            proteinChartDataSet.colors = [Color.mint]
            carbsChartDataSet.colors = [Color.skyBlue]
            fatChartDataSet.colors = [Color.salmon]
            let chartData = BarChartData(dataSets: chartDataSets)
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
            averageProtein = averageProtein / 7
            for value in carbsChartDataSet.entries {
                averageCarbs += value.y
            }
            averageCarbs = averageCarbs / 7
            for value in fatChartDataSet.entries {
                averageFat += value.y
            }
            averageFat = averageFat / 7
            
            cell.proteinLabel.text = averageProtein.removePointZeroEndingAndConvertToString() + " g"
            cell.carbsLabel.text = averageCarbs.removePointZeroEndingAndConvertToString() + " g"
            cell.fatLabel.text = averageFat.removePointZeroEndingAndConvertToString() + " g"
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            
            let limitLine = ChartLimitLine(limit: 2500, label: "Goal") // Set to actual goal
            limitLine.lineDashLengths = [8]
            limitLine.lineWidth = 0.9
            limitLine.lineColor = Color.mint
            limitLine.valueFont = UIFont(name: "Montserrat-Regular", size: 12)!
            cell.lineChart.leftAxis.addLimitLine(limitLine)
            
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            cell.lineChart.animate(yAxisDuration: 0.5)
            cell.lineChart.data = chartData
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 450
        }
        else {
            return 400
        }
    }
    
    
    
    
    func getTotalValueOfNutrient(_ nutrient: macroNutrient) -> Double {
        let nutrientArray = (foodList?.value(forKey: nutrient.stringValue)) as! [Double]
        return nutrientArray.reduce(0, +)
    }
    
    
    enum macroNutrient {
        case protein
        case carbs
        case fat
        case calories
        
        var stringValue: String {
            switch self {
            case .protein:
                return "protein"
            case .carbs:
                return "carbs"
            case .fat:
                return "fat"
            case .calories:
                return "calories"
            }
        }
    }
}
