//
//  WeekNutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class WeekNutritionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- Properties
    
    let calendar = Calendar.current
    var startOfWeekDate: Date?
    
    var foodList: [Food]?
    var foodListCopy: [Food]?
    
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
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
    }
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BarChartNutritionCell", bundle: nil), forCellReuseIdentifier: "BarNutritionCell")
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
        tableView.allowsSelection = false
    }
    
    func configureCalorieLabelColour(calories: Int, goalCalories: Int, cell: LineChartCell) {
        
        if calories < (goalCalories - 500) || calories > (goalCalories + 500) || goalCalories == 0 {
            cell.caloriesLabel.textColor = Color.salmon
        }
        else if calories >= (goalCalories - 500) && calories <= (goalCalories + 500) && calories != goalCalories {
            cell.caloriesLabel.textColor = .systemOrange
        }
        else {
            cell.caloriesLabel.textColor = Color.mint
        }
    }
    
    //MARK:- Data Methods
    
    func reloadFood() {
        tableView.reloadData()
    }

    func getTotalValueOfNutrient(_ nutrient: macroNutrient, foodList: [Food]?) -> Double {
        var nutrientArray = [Double]()
        
        for food in foodList! {
            switch nutrient {
            case .protein:
                nutrientArray.append(food.protein)
            case .carbs:
                nutrientArray.append(food.carbs)
            case .fat:
                nutrientArray.append(food.fat)
            default:
                nutrientArray.append(Double(food.calories))
            }
        }
        return nutrientArray.reduce(0, +)
    }
    
    
    func getAverageOfValue(dataSet: ChartDataSet) -> Double {
        var average = 0.0
        var numberOfEntries = 0.0
        for value in dataSet.entries {
            if value.y > 0 {
                average += value.y
                numberOfEntries += 1
            }
        }
        if (average / numberOfEntries).isNaN {
            return 0
        }
        else {
            return average / numberOfEntries
        }
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
    
    
    func setXaxisDateValues(date: Date, lineChartCell: LineChartCell?, barChartCell: BarChartNutritionCell?) {
        var date = date
        let axisDateFormatter = DateFormatter()
        axisDateFormatter.dateFormat = "dd"
        
        let xAxisValues = IndexAxisValueFormatter(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
        var valuesArray = [String]()
        for value in xAxisValues.values {
            valuesArray.append("\(value) \(axisDateFormatter.string(from: date))")
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        lineChartCell?.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: valuesArray)
        barChartCell?.barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: valuesArray)
    }
    
    
}

//MARK:- Extensions for tableView methods

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
            
            let parentVC = parent as! NutritionViewController
            let dayNumberDate = parentVC.startOfWeekVCDate ?? Date()
            setXaxisDateValues(date: dayNumberDate, lineChartCell: nil, barChartCell: cell)
            
            cell.proteinLabel.text = averageProtein.removePointZeroEndingAndConvertToString() + " g"
            cell.carbsLabel.text = averageCarbs.removePointZeroEndingAndConvertToString() + " g"
            cell.fatLabel.text = averageFat.removePointZeroEndingAndConvertToString() + " g"
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            let defaults = UserDefaults()
            
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            cell.lineChart.animate(yAxisDuration: 0.5)
            cell.lineChart.data = chartData
            
            let parentVC = parent as! NutritionViewController
            let dayNumberDate = parentVC.startOfWeekVCDate ?? Date()
            setXaxisDateValues(date: dayNumberDate, lineChartCell: cell, barChartCell: nil)
            
            var averageCalories = round(getAverageOfValue(dataSet: lineChartDataSet))
            
            if let goalCalories = (defaults.value(forKey: "GoalCalories") as? Int) {
                configureCalorieLabelColour(calories: Int(averageCalories), goalCalories: goalCalories, cell: cell)
                
                let limitLine = ChartLimitLine(limit: Double(goalCalories), label: "")
                limitLine.lineDashLengths = [8]
                limitLine.lineWidth = 1.5
                limitLine.lineColor = Color.mint
                limitLine.valueFont = UIFont(name: "Montserrat-Regular", size: 12)!
                
                cell.lineChart.leftAxis.addLimitLine(limitLine)
            }
            
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

//MARK:- XValueFormatter Class

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
