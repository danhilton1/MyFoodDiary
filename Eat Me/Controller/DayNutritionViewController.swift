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
    
    var foodList: Results<Food>?
    var calories = 0
    var protein = 1.0
    var carbs = 1.0
    var fat = 1.0
    var proteinArray = [Double]()
    var carbsArray = [Double]()
    var fatArray = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(foodList)
        foodList = realm.objects(Food.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DayNutritionCell", bundle: nil), forCellReuseIdentifier: "DayNutritionCell")
        tableView.allowsSelection = false
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 6
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Nutrients"
        }
        return nil
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 {
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
            
            proteinArray = (foodList?.value(forKey: "protein")) as! [Double]
            protein = proteinArray.reduce(0, +)
            carbsArray = (foodList?.value(forKey: "carbs")) as! [Double]
            carbs = carbsArray.reduce(0, +)
            fatArray = (foodList?.value(forKey: "fat")) as! [Double]
            fat = fatArray.reduce(0, +)

            let chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: protein),
                                                         PieChartDataEntry(value: carbs),
                                                         PieChartDataEntry(value: fat)], label: nil)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
            chartDataSet.selectionShift = 0
            let chartData = PieChartData(dataSet: chartDataSet)
            
            cell.pieChart.data = chartData
            
            cell.proteinValueLabel.text = protein.removePointZeroEndingAndConvertToString() + " g"
            cell.carbsValueLabel.text = carbs.removePointZeroEndingAndConvertToString() + " g"
            cell.fatValueLabel.text = fat.removePointZeroEndingAndConvertToString() + " g"
            
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
            
            cell.typeLabel.text = "Protein:"
            cell.numberLabel.text = "78.2 g"
            
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            return 350
        }
        else {
            return 40
        }
    }
    

}
