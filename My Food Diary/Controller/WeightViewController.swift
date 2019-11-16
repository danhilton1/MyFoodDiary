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

class WeightViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentWeightLabel: UILabel!
    @IBOutlet weak var goalWeightLabel: UILabel!
    
    let realm = try! Realm()
    var weightEntries: Results<Weight>?
    
    let calendar = Calendar.current
    private let formatter = DateFormatter()
    var lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 0 )], label: "Weight")
    var startOfWeekDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
        
        setUpWeekData(direction: .backward, date: Date(), considerToday: true)
    }
    
    
    func loadWeightEntries(date: Date?) {
        
        formatter.dateFormat = "dd MMM YYYY"
        
        weightEntries = realm.objects(Weight.self)
        
        let predicate = NSPredicate(format: "dateString contains[c] %@", formatter.string(from: date ?? Date()))
        weightEntries = weightEntries?.filter(predicate)
    }
    
    
    func setUpWeekData(direction: Calendar.SearchDirection, date: Date?, considerToday: Bool) {
        
        guard let today = date else { return }
        let monday = today.next(.monday, direction: direction, considerToday: considerToday)
        startOfWeekDate = monday
        loadWeightEntries(date: startOfWeekDate)
        lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: weightEntries?.last?.weight ?? 0)], label: "Weight")
        
        var dateCopy = startOfWeekDate
        // Append new entries to data sets from each day of the week
        for i in 1...6 {
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())!
            loadWeightEntries(date: dateCopy)
            lineChartDataSet.append(ChartDataEntry(x: Double(i), y: weightEntries?.last?.weight ?? 0))
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartCell", for: indexPath) as! LineChartCell
            
            cell.lineChart.leftAxis.axisMinimum = 60
            cell.lineChart.leftAxis.axisMaximum = 80
            cell.lineChart.xAxis.axisMaximum = 6
            cell.lineChart.xAxis.granularityEnabled = true
            cell.caloriesTitleLabel.text = "Weight"
            cell.caloriesTitleLabel.isHidden = true
            cell.averageTitleLabel.text = "Average Daily Weight:"
            cell.caloriesLabel.text = "72.3 kg"
            cell.goalValueLabel.text = "75 kg"
            
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
            cell.textLabel?.text = "\(days[indexPath.row - 1]): \(lineChartDataSet.entries[indexPath.row - 1].y) kg"
            cell.detailTextLabel?.text = "Monday"
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 450
        }
        else {
            return 40
        }
    }
    

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func leftArrowTapped(_ sender: UIButton) {
    }
    
    @IBAction func rightArrowTapped(_ sender: UIButton) {
    }
    
}
