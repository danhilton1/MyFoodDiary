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
    var protein = 0.0
    var carbs = 0.0
    var fat = 0.0
    var sugar = 0.0
    var saturatedFat = 0.0
    var fibre = 0.0


    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        getTotalValuesOfNutrients()
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
        getTotalValuesOfNutrients()
        tableView.reloadData()
    }

    func getTotalValuesOfNutrients() {
        calories = 0
        protein = 0.0
        carbs = 0.0
        fat = 0.0
        sugar = 0.0
        saturatedFat = 0.0
        fibre = 0.0
        
        if let foods = foodList {
            for food in foods {
                calories += food.calories
                protein += food.protein
                carbs += food.carbs
                sugar += food.sugar
                fat += food.fat
                saturatedFat += food.saturatedFat
                fibre += food.fibre
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
            
            cell.configurePieChart(calories: calories, protein: protein, carbs: carbs, fat: fat)
            
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
                cell.typeLabel.text = "  - Sugar:"
                cell.numberLabel.text = "\(sugar.removePointZeroEndingAndConvertToString()) g"
                cell.typeLabel.font = UIFont(name: "Montserrat-Light", size: 15)
                cell.numberLabel.font = UIFont(name: "Montserrat-Light", size: 15)
            case 3:
                cell.typeLabel.text = "Fat:"
                cell.numberLabel.text = "\(fat.removePointZeroEndingAndConvertToString()) g"
            case 4:
                cell.typeLabel.text = "  - Saturated Fat:"
                cell.numberLabel.text = "\(saturatedFat.removePointZeroEndingAndConvertToString()) g"
                cell.typeLabel.font = UIFont(name: "Montserrat-Light", size: 15)
                cell.numberLabel.font = UIFont(name: "Montserrat-Light", size: 15)
            case 5:
                cell.typeLabel.text = "Fibre:"
                cell.numberLabel.text = "\(fibre.removePointZeroEndingAndConvertToString()) g"
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
