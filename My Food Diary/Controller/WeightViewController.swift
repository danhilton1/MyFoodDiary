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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LineChartCell", bundle: nil), forCellReuseIdentifier: "LineChartCell")
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
            
            let chartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: 69), ChartDataEntry(x: 1, y: 69.4), ChartDataEntry(x: 2, y: 69.6), ChartDataEntry(x: 3, y: 69.5)], label: "Weight")
            
            chartDataSet.colors = [Color.skyBlue]
            chartDataSet.circleColors = [Color.skyBlue]
            chartDataSet.valueFont = UIFont(name: "Montserrat-SemiBold", size: 12)!
            
            let chartData = LineChartData(dataSet: chartDataSet)
            cell.lineChart.animate(yAxisDuration: 0.5)
            cell.lineChart.data = chartData
            
            return cell
        default:
            let cell = UITableViewCell()
            
            cell.textLabel?.text = "Entry: 69.5 kg"
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
