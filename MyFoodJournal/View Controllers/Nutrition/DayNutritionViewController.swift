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
    
    //MARK:- Properties
    
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

    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
    }
    
    func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DayNutritionCell", bundle: nil), forCellReuseIdentifier: "DayNutritionCell")
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }
    
    //MARK:- Data Methods
    
    func reloadFood() {
        tableView.reloadData()
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
        }
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

    //MARK:- Tableview Data Source/Delegate Methods
    
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
            
            if UIScreen.main.bounds.height < 600 {
                cell.pieChartWidthConstraint.constant = 150
                cell.pieChartHeightConstraint.constant = 150
                cell.proteinKeyWidthConstraint.constant = 15
                cell.proteinKeyHeightConstraint.constant = 15
                cell.goalProteinLabelCenterXConstraint.isActive = false
                
                cell.proteinTextLabel.font = cell.proteinTextLabel.font.withSize(14)
                cell.carbsTextLabel.font = cell.carbsTextLabel.font.withSize(14)
                cell.fatTextLabel.font = cell.fatTextLabel.font.withSize(14)
                cell.proteinValueLabel.font = cell.proteinValueLabel.font.withSize(14)
                cell.carbsValueLabel.font = cell.carbsValueLabel.font.withSize(14)
                cell.fatValueLabel.font = cell.fatValueLabel.font.withSize(14)
                cell.goalProteinLabel.font = cell.goalProteinLabel.font.withSize(14)
                cell.goalCarbsLabel.font = cell.goalCarbsLabel.font.withSize(14)
                cell.goalFatLabel.font = cell.goalFatLabel.font.withSize(14)
                cell.remainingProteinLabel.font = cell.remainingProteinLabel.font.withSize(14)
                cell.remainingCarbsLabel.font = cell.remainingCarbsLabel.font.withSize(14)
                cell.remainingFatLabel.font = cell.remainingFatLabel.font.withSize(14)
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
            
            if UIScreen.main.bounds.height < 600 {
                cell.typeLabel.font = cell.typeLabel.font.withSize(15)
                cell.numberLabel.font = cell.numberLabel.font.withSize(15)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            if UIScreen.main.bounds.height < 600 {
                return 300
            }
            else {
                return 350
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if UIScreen.main.bounds.height < 600 {
            header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 15)!
        }
        else {
            header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)!
        }
    }
    

}
