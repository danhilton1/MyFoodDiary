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
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeightLabel: UILabel!
    @IBOutlet weak var goalWeightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentWeightTextLabel: UILabel!
    @IBOutlet weak var goalWeightTextLabel: UILabel!
    //Constraints
    @IBOutlet weak var dateLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var goalStackViewBottomConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    
    let db = Firestore.firestore()

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
    
    enum WeightUnits {
        static let kg = "kg"
        static let lbs = "lbs"
        static let st = "st"
    }
    
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpNavBar()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
        setUpWeekData(direction: .backward, date: Date(), considerToday: true)
        setUpLabels()
        checkDeviceAndUpdateLayoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        setUpLabels()
    }
    
    func checkDeviceAndUpdateLayoutIfNeeded() {
        if UIScreen.main.bounds.height < 600 {
            dateLabelWidthConstraint.constant = 200
            dateLabel.font = dateLabel.font.withSize(16)
            settingsButtonWidthConstraint.constant = 18
            settingsButtonHeightConstraint.constant = 18
            settingsButtonTrailingConstraint.constant = 15
            currentStackViewBottomConstraint.constant = 5
            goalStackViewBottomConstraint.constant = 5
            currentWeightTextLabel.font = currentWeightTextLabel.font.withSize(16)
            goalWeightTextLabel.font = goalWeightTextLabel.font.withSize(16)
            currentWeightLabel.font = currentWeightLabel.font.withSize(16)
            goalWeightLabel.font = goalWeightLabel.font.withSize(16)
        }
    }
    
    func setUpNavBar() {
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = Color.skyBlue
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        } else {
            navigationController?.navigationBar.barTintColor = Color.skyBlue
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
    }
    
    func setUpLabels() {
            
        dateLabelFormatter.dateFormat = "E, d MMM"
        dateLabel.text = "Week Starting: \(dateLabelFormatter.string(from: startOfWeekDate ?? Date()))"
        let weightUnit = defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String
        
        var closestInterval: TimeInterval = .greatestFiniteMagnitude
        var mostCurrentEntry: Weight?

        if let allWeight = allWeightEntries {
            for entry in allWeight {
                let interval: TimeInterval = abs(entry.date.timeIntervalSinceNow)
                if interval < closestInterval {
                    closestInterval = interval
                    mostCurrentEntry = entry
                }
            }
        }
        if var currentWeight = mostCurrentEntry?.weight {
            currentWeightLabel.text = "\(currentWeight.removePointZeroEndingAndConvertToString()) \(weightUnit ?? "kg")"
        }
        else {
            currentWeightLabel.text = "0 \(weightUnit ?? "kg")"
        }
        
        goalWeightLabel.text = "\(defaults.value(forKey: UserDefaultsKeys.goalWeight) ?? "0") \(weightUnit ?? "kg")"
        
    }
    
    //MARK:- Data methods
    
    func loadWeightEntries(date: Date?) {
        
        formatter.dateFormat = "E, dd MMM YYYY"
        
        weightEntries = [Weight]()
        if let allWeight = allWeightEntries {
            for weightEntry in allWeight {
                if weightEntry.dateString == formatter.string(from: date ?? Date()) {
                    weightEntries!.append(weightEntry)
                }
            }
        }
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
        if let allWeight = allWeightEntries {
            var isUpdatingDayEntry = false
            for weight in allWeight {
                if weightEntry.dateString == weight.dateString {
                    weight.weight = weightEntry.weight
                    weight.unit = weightEntry.unit
                    weight.date = weightEntry.date
                    weight.dateLastEdited = weightEntry.dateLastEdited
                    isUpdatingDayEntry = true
                    break
                }
            }
            if !isUpdatingDayEntry {
                allWeightEntries?.append(weightEntry)
            }
        }
        setUpLabels()
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LineChartCell
        setUpWeekData(direction: .backward, date: date, considerToday: true)
        tableView.reloadData()
        cell.lineChart.animate(yAxisDuration: 0.5)
    }
    
    
    //MARK:- Button Methods
    
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
            self.goalWeightLabel.text = "\(self.defaults.value(forKey: UserDefaultsKeys.goalWeight) ?? 0) \(self.allWeightEntries?.last?.unit ?? "kg")"
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LineChartCell
            cell.goalValueLabel.text = "\(self.defaults.value(forKey: UserDefaultsKeys.goalWeight) ?? 0) \(self.allWeightEntries?.last?.unit ?? "kg")"
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Weight Unit", message: "Please select your preferred unit of weight.", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: WeightUnits.kg, style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.tableView.alpha = 0
            strongSelf.setWeightUnitAndReloadData(unit: WeightUnits.kg)
            UIView.animate(withDuration: 0.2) {
                strongSelf.tableView.alpha = 1
            }
        })
        
        ac.addAction(UIAlertAction(title: WeightUnits.lbs, style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.tableView.alpha = 0
            strongSelf.setWeightUnitAndReloadData(unit: WeightUnits.lbs)
            UIView.animate(withDuration: 0.2) {
                strongSelf.tableView.alpha = 1
            }
        })
        
        ac.addAction(UIAlertAction(title: WeightUnits.st, style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.tableView.alpha = 0
            strongSelf.setWeightUnitAndReloadData(unit: WeightUnits.st)
            UIView.animate(withDuration: 0.2) {
                strongSelf.tableView.alpha = 1
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    //MARK:- Weight Unit Change Method
    
    func setWeightUnitAndReloadData(unit: String) {
        if let allWeight = allWeightEntries {
            
            switch unit {
                
            case WeightUnits.lbs:
                
                if defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String == "kg" {
                    
                    for weight in allWeight {
                        let weightValue = weight.weight * 2.205
                        setWeightValuesAndUnit(unit: "lbs", weight: weight, weightValue: weightValue)
                    }
                    
                    defaults.set("lbs", forKey: UserDefaultsKeys.weightUnit)
                    if var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double {
                        goalWeight = goalWeight * 2.205
                        defaults.set((goalWeight.roundToXDecimalPoints(decimalPoints: 1)), forKey: UserDefaultsKeys.goalWeight)
                    }
                    updateDisplayAfterUnitChange()
                }
                else if defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String == "st" {
                    
                    for weight in allWeight {
                        let weightValue = weight.weight * 14
                        setWeightValuesAndUnit(unit: "lbs", weight: weight, weightValue: weightValue)
                    }
                    
                    defaults.set("lbs", forKey: UserDefaultsKeys.weightUnit)
                    if var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double {
                        goalWeight = goalWeight * 14
                        defaults.set((goalWeight.roundToXDecimalPoints(decimalPoints: 1)), forKey: UserDefaultsKeys.goalWeight)
                    }
                    updateDisplayAfterUnitChange()
                }
                
            case WeightUnits.st:
                
                if defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String == "kg" {
                    
                    for weight in allWeight {
                        let weightValue = weight.weight / 6.35
                        setWeightValuesAndUnit(unit: WeightUnits.st, weight: weight, weightValue: weightValue)
                    }
                    
                    defaults.set("st", forKey: UserDefaultsKeys.weightUnit)
                    if var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double {
                        goalWeight = goalWeight / 6.35
                        defaults.set((goalWeight.roundToXDecimalPoints(decimalPoints: 1)), forKey: UserDefaultsKeys.goalWeight)
                    }
                    updateDisplayAfterUnitChange()
                }
                else if defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String == "lbs" {
                    
                    for weight in allWeight {
                        let weightValue = weight.weight / 14
                        setWeightValuesAndUnit(unit: WeightUnits.st, weight: weight, weightValue: weightValue)
                    }
                    
                    defaults.set("st", forKey: UserDefaultsKeys.weightUnit)
                    if var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double {
                        goalWeight = goalWeight / 14
                        defaults.set((goalWeight.roundToXDecimalPoints(decimalPoints: 1)), forKey: UserDefaultsKeys.goalWeight)
                    }
                    updateDisplayAfterUnitChange()
                }
                
            default:
                
                if defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String == "lbs" {
                    
                    for weight in allWeight {
                        
                        let weightValue = weight.weight / 2.205
                        setWeightValuesAndUnit(unit: WeightUnits.kg, weight: weight, weightValue: weightValue)
                    }
                    
                    defaults.set("kg", forKey: UserDefaultsKeys.weightUnit)
                    if var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double {
                        goalWeight = goalWeight / 2.205
                        defaults.set((goalWeight.roundToXDecimalPoints(decimalPoints: 1)), forKey: UserDefaultsKeys.goalWeight)
                    }
                    updateDisplayAfterUnitChange()
                }
                else if defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String == "st" {
                    
                    for weight in allWeight {
                        let weightValue = weight.weight * 6.35
                        setWeightValuesAndUnit(unit: WeightUnits.kg, weight: weight, weightValue: weightValue)
                    }
                    
                    defaults.set("kg", forKey: UserDefaultsKeys.weightUnit)
                    if var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double {
                        goalWeight = goalWeight * 6.35
                        defaults.set((goalWeight.roundToXDecimalPoints(decimalPoints: 1)), forKey: UserDefaultsKeys.goalWeight)
                    }
                    updateDisplayAfterUnitChange()
                }
            }
        }
    }
    
    func setWeightValuesAndUnit(unit: String, weight: Weight, weightValue: Double) {
        var weightValue = weightValue
        let user = Auth.auth().currentUser?.email ?? ""
        
        weight.weight = weightValue.roundToXDecimalPoints(decimalPoints: 1)
        print(weight.weight)
        let weightDocument = db.collection("users").document(user).collection("weight").document("\(weight.dateString!)")
        
        weightDocument.updateData([
            "weight": weight.weight,
            "unit": unit
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }

        setUpLabels()
        let date = startOfWeekDate?.next(.monday, direction: .forward, considerToday: false)
        setUpWeekData(direction: .backward, date: date, considerToday: false)
        tableView.reloadData()

    }
    
    func updateDisplayAfterUnitChange() {
        setUpLabels()
        let date = startOfWeekDate?.next(.monday, direction: .forward, considerToday: false)
        setUpWeekData(direction: .backward, date: date, considerToday: false)
        tableView.reloadData()
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
            }
            
        }
    }
    
    public func setXaxisDateValues(date: Date, lineChartCell: LineChartCell?, barChartCell: BarChartNutritionCell?) {
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
        
        let weightUnit = defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String
        
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
                cell.caloriesLabel.text = "0 \(weightUnit ?? "kg")"
            }
            else {
                cell.lineChart.leftAxis.axisMinimum = (averageWeight - 10)
                cell.lineChart.leftAxis.axisMaximum = (averageWeight + 10)
                cell.caloriesLabel.text = "\(averageWeight.roundToXDecimalPoints(decimalPoints: 1)) \(weightUnit ?? "kg")"
            }
            
            cell.lineChart.xAxis.axisMaximum = 6.5
            cell.lineChart.xAxis.granularityEnabled = true
            cell.caloriesTitleLabel.text = "Weight"
            cell.caloriesTitleLabel.isHidden = true
            cell.averageTitleLabel.text = "Average Daily Weight:"
            cell.goalValueLabel.text = "\(defaults.value(forKey: UserDefaultsKeys.goalWeight) ?? 0) \(weightUnit ?? "kg")"
            cell.lineChart.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
            
            lineChartDataSet.colors = [Color.skyBlue]
            lineChartDataSet.circleColors = [Color.skyBlue]
            lineChartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            
            let chartData = LineChartData(dataSet: lineChartDataSet)
            chartData.setValueFormatter(XValueFormatter())
            cell.lineChart.data = chartData
            
            let dayNumberDate = startOfWeekDate ?? Date()
            
            setXaxisDateValues(date: dayNumberDate, lineChartCell: cell, barChartCell: nil)
            
            cell.isUserInteractionEnabled = false
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
            
            if UIScreen.main.bounds.height < 600 {
                cell.typeLabel.font = UIFont(name: "Montserrat-Regular", size: 15)!
                cell.numberLabel.font = UIFont(name: "Montserrat-Medium", size: 15)!
            }
            else {
                cell.typeLabel.font = UIFont(name: "Montserrat-Regular", size: 17)!
                cell.numberLabel.font = UIFont(name: "Montserrat-Medium", size: 17)!
            }
            let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            if lineChartDataSet.entries[indexPath.row].y == 0 {
                cell.typeLabel.text = "\(days[indexPath.row]): "
                cell.numberLabel.text = "-"
                cell.isUserInteractionEnabled = false
            }
            else {
                cell.typeLabel.text = "\(days[indexPath.row]):"
                cell.numberLabel.text = "\(lineChartDataSet.entries[indexPath.row].y) \(weightUnit ?? "kg")"
                cell.isUserInteractionEnabled = true
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let weightUnit = defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String ?? "kg"
        var index = 0
        for entry in allWeightEntries! {
            if entry.weight == lineChartDataSet.entries[indexPath.row].y && entry.date == weightEntriesDates![indexPath.row] {
                weightEntryToEdit = allWeightEntries?[index]
                weightEntryToEdit?.unit = weightUnit
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if UIScreen.main.bounds.height < 600 {
            header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 15)!
        }
        else {
            header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            if UIScreen.main.bounds.height < 600 {
                return 24
            }
            else {
                return 28
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if UIScreen.main.bounds.height < 600 {
                return 350
            }
            else if UIScreen.main.bounds.height < 700 {
                return 420
            }
            else {
                return 450
            }
        }
        else {
            if UIScreen.main.bounds.height < 600 {
                return 35
            }
            else {
                return 40
            }
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
            
            guard let user = Auth.auth().currentUser?.uid else { return }
            let date = weightEntriesDates![indexPath.row]
            let dateString = formatter.string(from: date)
            
            db.collection("users").document(user).collection("weight").document(dateString).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document: \(dateString) successfully removed!")
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
            setUpLabels()
        }
    }
}
