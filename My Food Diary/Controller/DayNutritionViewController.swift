//
//  DayNutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class DayNutritionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let defaults = UserDefaults()
    
    var foodList: [Food]?
    var calories = 0
    
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

    var proteinPercentage: Double {
        get { (protein / (protein + carbs + fat)) * 100 }
        set { }
    }
    var carbsPercentage: Double {
        get { (carbs / (protein + carbs + fat)) * 100 }
        set { }
    }
    var fatPercentage: Double {
        get { (fat / (protein + carbs + fat)) * 100 }
        set { }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        foodList = realm.objects(Food.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DayNutritionCell", bundle: nil), forCellReuseIdentifier: "DayNutritionCell")
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
    }
    
    
    func reloadFood() {
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 3
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
            
//            let proteinArray = (foodList?.value(forKey: "protein")) as! [Double]
//            protein = proteinArray.reduce(0, +)
//            let carbsArray = (foodList?.value(forKey: "carbs")) as! [Double]
//            carbs = carbsArray.reduce(0, +)
//            let fatArray = (foodList?.value(forKey: "fat")) as! [Double]
//            fat = fatArray.reduce(0, +)

            var chartDataSet: PieChartDataSet
            if protein == 0 && carbs == 0 && fat == 0.0 {
                chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1),
                                                             PieChartDataEntry(value: 1),
                                                             PieChartDataEntry(value: 1)], label: nil)
            }
            else {
                chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: protein),
                                                             PieChartDataEntry(value: carbs),
                                                             PieChartDataEntry(value: fat)], label: nil)
            }
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
            chartDataSet.selectionShift = 0
            let chartData = PieChartData(dataSet: chartDataSet)
            
            cell.pieChart.data = chartData
            
            cell.proteinValueLabel.text = protein.removePointZeroEndingAndConvertToString() + " g"
            cell.carbsValueLabel.text = carbs.removePointZeroEndingAndConvertToString() + " g"
            cell.fatValueLabel.text = fat.removePointZeroEndingAndConvertToString() + " g"
            
            var goalProtein = defaults.value(forKey: UserDefaultsKeys.goalProtein) as? Double ?? 0
            var goalCarbs = defaults.value(forKey: UserDefaultsKeys.goalCarbs) as? Double ?? 0
            var goalFat = defaults.value(forKey: UserDefaultsKeys.goalFat) as? Double ?? 0
            var remainingProtein = goalProtein - protein
            var remainingCarbs = goalCarbs - carbs
            var remainingFat = goalFat - fat
            
            cell.remainingProteinLabel.text = remainingProtein.removePointZeroEndingAndConvertToString() + " g"
            cell.remainingCarbsLabel.text = remainingCarbs.removePointZeroEndingAndConvertToString() + " g"
            cell.remainingFatLabel.text = remainingFat.removePointZeroEndingAndConvertToString() + " g"
            
            cell.goalProteinLabel.text = goalProtein.removePointZeroEndingAndConvertToString() + " g"
            cell.goalCarbsLabel.text = goalCarbs.removePointZeroEndingAndConvertToString() + " g"
            cell.goalFatLabel.text = goalFat.removePointZeroEndingAndConvertToString() + " g"
            
            if proteinPercentage.isNaN && carbsPercentage.isNaN && fatPercentage.isNaN {
                cell.proteinPercentLabel.text = "0"
                cell.carbsPercentLabel.text = "0"
                cell.fatPercentLabel.text = "0"
            }
            else {
                cell.proteinPercentLabel.text = proteinPercentage.removePointZeroEndingAndConvertToString()
                cell.carbsPercentLabel.text = carbsPercentage.removePointZeroEndingAndConvertToString()
                cell.fatPercentLabel.text = fatPercentage.removePointZeroEndingAndConvertToString()
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
            
            switch indexPath.row {
            case 0:
                cell.typeLabel.text = "Protein:"
                cell.numberLabel.text = "\(protein.removePointZeroEndingAndConvertToString()) g"
            case 1:
                cell.typeLabel.text = "Carbs:"
                cell.numberLabel.text = "\(carbs.removePointZeroEndingAndConvertToString()) g"
            case 2:
                cell.typeLabel.text = "Fat:"
                cell.numberLabel.text = "\(fat.removePointZeroEndingAndConvertToString()) g"
            default:
                return cell
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            return 350
        }
        else {
            return 40
        }
    }
    
    
    func getTotalValueOfNutrient(_ nutrient: macroNutrient) -> Double {
        var nutrientArray = [Double]()
        for food in foodList! {
            switch nutrient {
            case .protein:
                nutrientArray.append(food.protein)
            case .carbs:
                nutrientArray.append(food.carbs)
            default:
                nutrientArray.append(food.fat)
            }
//            nutrientArray.append(food.value(forKey: nutrient.stringValue) as! Double)
        }
        
        //let nutrientArray = (foodList?.value(forKey: nutrient.stringValue)) as! [Double]
        return nutrientArray.reduce(0, +)
    }
    
    
    enum macroNutrient {
        case protein
        case carbs
        case fat
        
        var stringValue: String {
            switch self {
            case .protein:
                return "protein"
            case .carbs:
                return "carbs"
            case .fat:
                return "fat"
            }
        }
    }

}
