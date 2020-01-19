//
//  WeightViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 02/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts
import Firebase

class WeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WeightDelegate {
    
    //MARK:- Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeightLabel: UILabel!
    @IBOutlet weak var goalWeightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let db = Firestore.firestore()

//    var weightEntries: Results<Weight>?
//    private var allWeightEntries: Results<Weight>?
    var weightEntries: [Weight]?
    var allWeightEntries: [Weight]?
    var weightEntriesDates: [Date]?
    var weightEntryToEdit: Weight?
    private var averageWeight: Double = 0.0
    
    private let calendar = Calendar.current
    private let defaults = UserDefaults()
    private let formatter = DateFormatter()
    private let dateLabelFormatter = DateFormatter()
    private var lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0 )], label: "Weight")
    private var startOfWeekDate: Date?
    
    
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
//        allWeightEntries = realm.objects(Weight.self)
        setUpWeekData(direction: .backward, date: Date(), considerToday: true)
        setUpLabels()
    }
    
    //MARK:- Data methods
    
    func loadWeightEntries(date: Date?) {
        
        formatter.dateFormat = "E, dd MMM YYYY"
        
//        weightEntries = realm.objects(Weight.self)
//        let predicate = NSPredicate(format: "dateString contains[c] %@", formatter.string(from: date ?? Date()))
//        weightEntries = weightEntries?.filter(predicate)
        
        weightEntries = [Weight]()
        for weightEntry in allWeightEntries! {
            if weightEntry.dateString == formatter.string(from: date ?? Date()) {
                weightEntries!.append(weightEntry)
            }
        }
        //print(weightEntries)
    }
    
    func setUpLabels() {
        
        dateLabelFormatter.dateFormat = "E, d MMM"
        dateLabel.text = "Week Starting: \(dateLabelFormatter.string(from: startOfWeekDate ?? Date()))"

        var closestInterval: TimeInterval = .greatestFiniteMagnitude
        var mostCurrentEntry: Weight?
        print(allWeightEntries)
        for entry in allWeightEntries! {
            let interval: TimeInterval = abs(entry.date.timeIntervalSinceNow)
            if interval < closestInterval {
                closestInterval = interval
                mostCurrentEntry = entry
            }
        }
        if let currentWeight = mostCurrentEntry?.weight {
            currentWeightLabel.text = "\(currentWeight) \(mostCurrentEntry?.unit ?? "kg")"
        }
        else {
            currentWeightLabel.text = "0 kg"
        }
        goalWeightLabel.text = "\(defaults.value(forKey: "GoalWeight") ?? "0") kg"
        
    }
    
    func setUpWeekData(direction: Calendar.SearchDirection, date: Date?, considerToday: Bool) {
        
        weightEntriesDates = [Date]()
        
        guard let today = date else { return }
        let monday = today.next(.monday, direction: direction, considerToday: considerToday)
        startOfWeekDate = monday
        loadWeightEntries(date: startOfWeekDate)
        
        let calendar = Calendar.current
        let defaultDateComponents = DateComponents(calendar: calendar, timeZone: .current, year: 2019, month: 1, day: 1)
        weightEntriesDates?.append(weightEntries?.last?.date ?? calendar.date(from: defaultDateComponents)!)
        
        var entry = weightEntries?.last?.weight ?? 0
        
        lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: entry.roundToXDecimalPoints(decimalPoints: 1))], label: "Weight")
        
        var dateCopy = startOfWeekDate
        // Append new entries to data sets from each day of the week
        for i in 1...6 {
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())!
            loadWeightEntries(date: dateCopy)
            weightEntriesDates?.append(weightEntries?.last?.date ?? calendar.date(from: defaultDateComponents)!)
            var entry = weightEntries?.last?.weight ?? 0
            lineChartDataSet.append(ChartDataEntry(x: Double(i), y: entry.roundToXDecimalPoints(decimalPoints: 1)))
        }
    }
    
    func reloadData(weightEntry: Weight, date: Date?) {
        allWeightEntries?.append(weightEntry)
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
        weightEntriesDates = [Date]()
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
        weightEntriesDates = [Date]()
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
            textField.text = "\(self.defaults.value(forKey: "GoalWeight") ?? "")"
            textField.placeholder = "Enter value here"
            textField.keyboardType = .decimalPad
        }
        
        
        ac.addAction(UIAlertAction(title: "Set", style: .default, handler: { (UIAlertAction) in
            self.defaults.setValue(Double(ac.textFields![0].text ?? "0"), forKey: UserDefaultsKeys.goalWeight)
            self.goalWeightLabel.text = "\(self.defaults.value(forKey: "GoalWeight") ?? 0) \(self.allWeightEntries?.last?.unit ?? "kg")"
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LineChartCell
            cell.goalValueLabel.text = "\(self.defaults.value(forKey: "GoalWeight") ?? 0) \(self.allWeightEntries?.last?.unit ?? "kg")"
            
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
        else if segue.identifier == "GoToEditWeightEntry" {
            let VC = segue.destination as! NewWeightEntryViewController
            VC.delegate = self
            
            if let weightEntry = weightEntryToEdit {
                VC.weightEntry = weightEntry
                VC.isEditingExistingEntry = true
                switch weightEntry.unit {
                case "lbs":
                    VC.selectedSegmentIndex = 1
                default:
                    VC.selectedSegmentIndex = 0
                }
                
            }
            
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
        
        let lastEntryUnit = allWeightEntries?.last?.unit ?? "kg"
        
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
                cell.caloriesLabel.text = "0 \(lastEntryUnit)"
            }
            else {
                cell.lineChart.leftAxis.axisMinimum = (averageWeight - 10)
                cell.lineChart.leftAxis.axisMaximum = (averageWeight + 10)
                cell.caloriesLabel.text = "\(averageWeight.roundToXDecimalPoints(decimalPoints: 1)) \(lastEntryUnit)"
            }
            
            cell.lineChart.xAxis.axisMaximum = 6.5
            cell.lineChart.xAxis.granularityEnabled = true
            cell.caloriesTitleLabel.text = "Weight"
            cell.caloriesTitleLabel.isHidden = true
            cell.averageTitleLabel.text = "Average Daily Weight:"
            cell.goalValueLabel.text = "\(defaults.value(forKey: "GoalWeight") ?? 0) \(lastEntryUnit)"
            cell.lineChart.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
            
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            cell.lineChart.data = chartData
            
            cell.isUserInteractionEnabled = false
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
            
            cell.typeLabel.font = UIFont(name: "Montserrat-Regular", size: 17)!
            cell.numberLabel.font = UIFont(name: "Montserrat-Medium", size: 17)!
            let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            if lineChartDataSet.entries[indexPath.row].y == 0 {
                cell.typeLabel.text = "\(days[indexPath.row]): "
                cell.numberLabel.text = "-"
                cell.isUserInteractionEnabled = false
            }
            else {
                cell.typeLabel.text = "\(days[indexPath.row]):"
                cell.numberLabel.text = "\(lineChartDataSet.entries[indexPath.row].y) \(lastEntryUnit)"
                cell.isUserInteractionEnabled = true
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var index = 0
        for entry in allWeightEntries! {
            if entry.weight == lineChartDataSet.entries[indexPath.row].y && entry.date == weightEntriesDates![indexPath.row] {
                weightEntryToEdit = allWeightEntries?[index]
                break
            }
            index += 1
        }
        performSegue(withIdentifier: "GoToEditWeightEntry", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
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
            if UIScreen.main.bounds.height < 700 {
                return 420
            }
            else {
                return 450
            }
        }
        else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as? MealDetailCell

        if indexPath.section == 1 && cell?.numberLabel.text != "-" {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let user = Auth.auth().currentUser?.email else { return }
            let weight = lineChartDataSet.entries[indexPath.row].y
            let date = weightEntriesDates![indexPath.row]
            let weightDocument = "\(weight) \(date)"
            
            db.collection("users").document(user).collection("weight").document(weightDocument).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document: \(weightDocument) successfully removed!")
                }
            }
            
            var index = 0
            for entry in allWeightEntries! {
                if entry.weight == lineChartDataSet.entries[indexPath.row].y && entry.date == weightEntriesDates![indexPath.row] {
                    allWeightEntries?.remove(at: index)
                    break
                }
                index += 1
            }
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LineChartCell
            lineChartDataSet.entries[indexPath.row].y = 0
            cell.lineChart.animate(yAxisDuration: 0.5)

            tableView.reloadData()

        }
    }
}

//MARK:- WeightDelegate Protocol

protocol WeightDelegate: class {
    func reloadData(weightEntry: Weight, date: Date?)
}
