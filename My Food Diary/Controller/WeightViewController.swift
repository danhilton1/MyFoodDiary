//
//  WeightViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 02/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class WeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WeightDelegate {
    
    //MARK:- Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeightLabel: UILabel!
    @IBOutlet weak var goalWeightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    let realm = try! Realm()
    var weightEntries: Results<Weight>?
    private var allWeightEntries: Results<Weight>?
    
    private let calendar = Calendar.current
    private let defaults = UserDefaults()
    private let formatter = DateFormatter()
    private let dateLabelFormatter = DateFormatter()
    private var lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0 )], label: "Weight")
    private var startOfWeekDate: Date?
    
    private var averageWeight: Double = 0.0
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
        
        allWeightEntries = realm.objects(Weight.self)
        setUpWeekData(direction: .backward, date: Date(), considerToday: true)
        setUpLabels()
    }
    
    //MARK:- Data methods
    
    func loadWeightEntries(date: Date?) {
        
        formatter.dateFormat = "dd MMM YYYY"
        
        weightEntries = realm.objects(Weight.self)
        let predicate = NSPredicate(format: "dateString contains[c] %@", formatter.string(from: date ?? Date()))
        weightEntries = weightEntries?.filter(predicate)
    }
    
    func setUpLabels() {
        
        dateLabelFormatter.dateFormat = "E, d MMM"
        dateLabel.text = "Week Starting: \(dateLabelFormatter.string(from: startOfWeekDate ?? Date()))"

        var closestInterval: TimeInterval = .greatestFiniteMagnitude
        var mostCurrentEntry: Weight?
        for entry in allWeightEntries! {
            let interval: TimeInterval = abs(entry.date.timeIntervalSinceNow)
            if interval < closestInterval {
                closestInterval = interval
                mostCurrentEntry = entry
            }
        }
        if let currentWeight = mostCurrentEntry?.weight {
            currentWeightLabel.text = "\(currentWeight) kg"
        }
        else {
            currentWeightLabel.text = "0 kg"
        }
        goalWeightLabel.text = "\(defaults.value(forKey: "GoalWeight") ?? "0") kg"
        
    }
    
    func setUpWeekData(direction: Calendar.SearchDirection, date: Date?, considerToday: Bool) {
        
        guard let today = date else { return }
        let monday = today.next(.monday, direction: direction, considerToday: considerToday)
        startOfWeekDate = monday
        loadWeightEntries(date: startOfWeekDate)
        var entry = weightEntries?.last?.weight ?? 0
        lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: entry.roundToXDecimalPoints(decimalPoints: 1))], label: "Weight")
        
        var dateCopy = startOfWeekDate
        // Append new entries to data sets from each day of the week
        for i in 1...6 {
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())!
            loadWeightEntries(date: dateCopy)
            var entry = weightEntries?.last?.weight ?? 0
            lineChartDataSet.append(ChartDataEntry(x: Double(i), y: entry.roundToXDecimalPoints(decimalPoints: 1)))
        }
    }
    
    func reloadData(date: Date?) {
        setUpLabels()
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LineChartCell
        setUpWeekData(direction: .backward, date: date, considerToday: true)
        tableView.reloadData()
        cell.lineChart.animate(yAxisDuration: 0.5)
    }
    
    
    //MARK:- Button Methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func leftArrowTapped(_ sender: UIButton) {
        setUpWeekData(direction: .backward, date: startOfWeekDate, considerToday: false)
        dateLabel.text = "Week Starting: \(dateLabelFormatter.string(from: startOfWeekDate ?? Date()))"

        tableView.frame = tableView.frame.offsetBy(dx: -view.frame.width, dy: 0)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            var viewRightFrame = self.tableView.frame
            viewRightFrame.origin.x += viewRightFrame.size.width
            self.tableView.frame = viewRightFrame
            
        }, completion: nil)
        
        tableView.reloadData()
    }
    
    @IBAction func rightArrowTapped(_ sender: UIButton) {
        setUpWeekData(direction: .forward, date: startOfWeekDate, considerToday: false)
        dateLabel.text = "Week Starting: \(dateLabelFormatter.string(from: startOfWeekDate ?? Date()))"

        tableView.frame = tableView.frame.offsetBy(dx: view.frame.width, dy: 0)
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            var viewLeftFrame = self.tableView.frame
            viewLeftFrame.origin.x -= viewLeftFrame.size.width
            self.tableView.frame = viewLeftFrame
            
        }, completion: nil)
        
        tableView.reloadData()
    }
    
    
    @IBAction func goalButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Goal Weight", message: "Please set your goal weight", preferredStyle: .alert)
        
        ac.addTextField { (textField) in
            textField.text = "\(self.defaults.value(forKey: "GoalWeight") ?? 0)"
            textField.placeholder = "Enter value here"
            textField.keyboardType = .decimalPad
        }
        
        ac.addAction(UIAlertAction(title: "Set", style: .default, handler: { (UIAlertAction) in
            self.defaults.setValue(Double(ac.textFields![0].text ?? "0"), forKey: "GoalWeight")
            self.goalWeightLabel.text = "\(self.defaults.value(forKey: "GoalWeight") ?? 0) kg"
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LineChartCell
            cell.goalValueLabel.text = "\(self.defaults.value(forKey: "GoalWeight") ?? 0) kg"
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    
    //MARK:- Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToNewWeightEntry" {
            let NC = segue.destination as! UINavigationController
            let VC = NC.viewControllers.first as! NewWeightEntryViewController
            VC.delegate = self
        }
    }
    
}


//MARK:- Extension for Table View methods

extension WeightViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            
            var average = 0.0
            var numberOfEntries = 0.0
            for value in lineChartDataSet.entries {
                if value.y > 0.0 {
                    average += value.y
                    numberOfEntries += 1
                }
            }
            averageWeight = average / numberOfEntries
            
            if averageWeight.isNaN {
                cell.lineChart.leftAxis.axisMinimum = 0
                cell.lineChart.leftAxis.axisMaximum = 20
                cell.caloriesLabel.text = "0 kg"
            }
            else {
                cell.lineChart.leftAxis.axisMinimum = (averageWeight - 10)
                cell.lineChart.leftAxis.axisMaximum = (averageWeight + 10)
                cell.caloriesLabel.text = "\(averageWeight.roundToXDecimalPoints(decimalPoints: 1)) kg"
            }
            
            cell.lineChart.xAxis.axisMaximum = 6.5
            cell.lineChart.xAxis.granularityEnabled = true
            cell.caloriesTitleLabel.text = "Weight"
            cell.caloriesTitleLabel.isHidden = true
            cell.averageTitleLabel.text = "Average Daily Weight:"
            cell.goalValueLabel.text = "\(defaults.value(forKey: "GoalWeight") ?? 0) kg"
            
            
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            cell.lineChart.data = chartData
            
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)!
            let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            if lineChartDataSet.entries[indexPath.row].y == 0 {
                cell.textLabel?.text = "\(days[indexPath.row]): No weight entered"
            }
            else {
                cell.textLabel?.text = "\(days[indexPath.row]): \(lineChartDataSet.entries[indexPath.row].y) kg"
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        else {
            return "Entries"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 450
        }
        else {
            return 40
        }
    }
}

//MARK:- WeightDelegate Protocol

protocol WeightDelegate: class {
    func reloadData(date: Date?)
}
