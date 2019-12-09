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
    var foodListCopy: Results<Food>?
    
    var date: Date?
    
    var protein: Double {
        get { getTotalValueOfNutrient(.protein, foodList: foodList) }
        set { }
    }
    var carbs: Double {
        get { getTotalValueOfNutrient(.carbs, foodList: foodList) }
        set { }
    }
    var fat: Double {
        get { getTotalValueOfNutrient(.fat, foodList: foodList) }
        set { }
    }
    var calories: Double {
        get { getTotalValueOfNutrient(.calories, foodList: foodList) }
        set { }
    }
    
    
    var proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)], label: "Protein") {
        didSet {
            proteinChartDataSetCopy = proteinChartDataSet
        }
    }
    var carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)], label: "Carbs") {
        didSet {
            carbsChartDataSetCopy = carbsChartDataSet
        }
    }
    var fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: 0)], label: "Fat") {
        didSet {
            fatChartDataSetCopy = fatChartDataSet
        }
    }
    var lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0)], label: "Calories") {
        didSet {
            lineChartDataSetCopy = lineChartDataSet
        }
    }
    
    var proteinChartDataSetCopy: BarChartDataSet!
    var carbsChartDataSetCopy: BarChartDataSet!
    var fatChartDataSetCopy: BarChartDataSet!
    var lineChartDataSetCopy: LineChartDataSet!
    
    
    var averageProtein: Double {
        get { getAverageOfValue(dataSet: proteinChartDataSet) }
        set { }
    }
    var averageCarbs: Double {
        get { getAverageOfValue(dataSet: carbsChartDataSet) }
        set { }
    }
    var averageFat: Double {
        get { getAverageOfValue(dataSet: fatChartDataSet) }
        set { }
    }
    
    var averageProteinCopy: Double {
        get { getAverageOfValue(dataSet: proteinChartDataSetCopy) }
        set { }
    }
    var averageCarbsCopy: Double {
        get { getAverageOfValue(dataSet: carbsChartDataSetCopy) }
        set { }
    }
    var averageFatCopy: Double {
        get { getAverageOfValue(dataSet: fatChartDataSetCopy) }
        set { }
    }
    
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

    
    func getTotalValueOfNutrient(_ nutrient: macroNutrient, foodList: Results<Food>?) -> Double {
        let nutrientArray = (foodList?.value(forKey: nutrient.stringValue)) as! [Double]
        return nutrientArray.reduce(0, +)
    }
    
    
    func getAverageOfValue(dataSet: ChartDataSet) -> Double {
        var average = 0.0
        for value in dataSet.entries {
            average += value.y
        }
        return average / Double(dataSet.entries.count)
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
    
    
    public class XValueFormatter: NSObject, IValueFormatter {

        public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            var numberString = String(value)
            if numberString.hasSuffix(".0") && value != 0 {
                numberString.removeLast(2)
                return numberString
            }
            
            
            return value <= 0.0 ? "" : String(describing: value)
        }
    }
    
}


extension WeekNutritionViewController {
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
            chartData.setValueFormatter(XValueFormatter())
            chartData.barWidth = 0.23
            chartData.groupBars(fromX: 0, groupSpace: 0.16, barSpace: 0.05)
            cell.barChart.animate(yAxisDuration: 0.5)
            cell.barChart.data = chartData
            
            cell.proteinLabel.text = averageProtein.removePointZeroEndingAndConvertToString() + " g"
            cell.carbsLabel.text = averageCarbs.removePointZeroEndingAndConvertToString() + " g"
            cell.fatLabel.text = averageFat.removePointZeroEndingAndConvertToString() + " g"
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            let defaults = UserDefaults()
            if let goalCalories = (defaults.value(forKey: "GoalCalories") as? Double) {
                let limitLine = ChartLimitLine(limit: goalCalories, label: "")
                limitLine.lineDashLengths = [8]
                limitLine.lineWidth = 1.5
                limitLine.lineColor = Color.mint
                limitLine.valueFont = UIFont(name: "Montserrat-Regular", size: 12)!
                
                cell.lineChart.leftAxis.addLimitLine(limitLine)
            }
            
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            cell.lineChart.animate(yAxisDuration: 0.5)
            cell.lineChart.data = chartData
            
            var averageCalories = round(getAverageOfValue(dataSet: lineChartDataSet))
            cell.caloriesLabel.text = averageCalories.removePointZeroEndingAndConvertToString()
            cell.goalValueLabel.text = "\(defaults.value(forKey: "GoalCalories") ?? 0)"
            
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
}
