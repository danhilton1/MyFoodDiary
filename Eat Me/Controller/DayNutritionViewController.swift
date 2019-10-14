//
//  DayNutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class DayNutritionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    var calories = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DayNutritionCell", bundle: nil), forCellReuseIdentifier: "DayNutritionCell")
        tableView.allowsSelection = false
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayNutritionCell", for: indexPath) as! DayNutritionCell
        
        let text = """
                   \(calories)
                   kcal
                   """
        let font = UIFont(name: "Montserrat-Medium", size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font!,
            .paragraphStyle: paragraphStyle
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        cell.pieChart.centerAttributedText = attributedText
        
        let chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1.0),
                                                     PieChartDataEntry(value: 1.0),
                                                     PieChartDataEntry(value: 1.0)], label: nil)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
        chartDataSet.selectionShift = 0
        let chartData = PieChartData(dataSet: chartDataSet)
        
        cell.pieChart.data = chartData
        
        
        
        return cell
    }
    

}
