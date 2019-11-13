//
//  MealDetailViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 13/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class MealDetailViewController: UITableViewController, NewEntryDelegate {
    
    let realm = try! Realm()
    
    var calories = 0
    var selectedMeal: Results<Food>? {
        didSet {
            let predicate = NSPredicate(format: "isDeleted == FALSE")
            selectedMeal = selectedMeal?.filter(predicate)
            
            guard let foodList = selectedMeal else { return }
            calories = 0
            for food in foodList {
                calories += food.calories
            }
        }
    }
    
    var date: Date?
    var meal: Food.Meal = .breakfast
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    
    //MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .white
        
        caloriesLabel.text = "   Calories: \(calories)"
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        if selectedMeal?.count == 0 {
            tableView.separatorStyle = .none
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .blue
    }
    
    
    func reloadFood() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
            self.reloadSelectedMeal()
            self.tableView.reloadData()
            self.tableView.separatorStyle = .singleLine
        }
    }
    
    func reloadSelectedMeal() {
        let predicate = NSPredicate(format: "isDeleted == FALSE")
        selectedMeal = selectedMeal?.filter(predicate)
        
        guard let foodList = selectedMeal else { return }
        calories = 0
        for food in foodList {
            calories += food.calories
        }
        caloriesLabel.text = "   Calories: \(calories)"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToPopUp" {
            let popUpNC = segue.destination as! UINavigationController
            let destVC = popUpNC.viewControllers.first as! NewEntryViewController
            destVC.date = date
            destVC.meal = meal
            destVC.mealDelegate = self
        }
    }
    
    
    
    // MARK: - Table view data source and delegate methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedMeal?.count == 0 {
            return 1
        }
        return selectedMeal?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedMeal?.count == 0 {
            return 1
        }
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let food = selectedMeal {
            for i in 0..<food.count {
                if indexPath.section == i {
                    switch indexPath.row {
                    case 0:
                        return setFoodHistoryCell(indexPath: indexPath, food: food[i])
                    case 1:
                        return setMealDetailCell(indexPath: indexPath, nutrient: food[i].protein, nutrientType: "Protein")
                    case 2:
                        return setMealDetailCell(indexPath: indexPath, nutrient: food[i].carbs, nutrientType: "Carbs")
                    case 3:
                        return setMealDetailCell(indexPath: indexPath, nutrient: food[i].fat, nutrientType: "Fat")
                    default:
                        return UITableViewCell()
                    }
                }
            }
        }
        let defaultCell = UITableViewCell()
        defaultCell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 16)
        defaultCell.textLabel?.text = "No food logged for selected meal."
        return defaultCell
        
    }
    
    private func setFoodHistoryCell(indexPath: IndexPath, food: Food) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodHistoryCell", for: indexPath) as! FoodHistoryCell
        
        cell.backgroundColor = Color.skyBlue
        //                        cell.accessoryType = .disclosureIndicator
        cell.foodNameLabel.textColor = .white
        cell.foodNameLabel.text = food.name
        cell.foodNameLabel.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        cell.caloriesLabel.textColor = .white
        cell.caloriesLabel.font = UIFont(name: "Montserrat-Medium", size: 18)
        cell.caloriesLabel.text = "\(food.calories) kcal"
        cell.totalServingLabel.textColor = .white
        cell.totalServingLabel.font = UIFont(name: "Montserrat-Regular", size: 16)
        let servingSize = Double(food.servingSize.filter("01234567890.".contains)) ?? 100
        var totalServing = servingSize * food.serving
        cell.totalServingLabel.text = totalServing.removePointZeroEndingAndConvertToString() + " g"

        return cell
    }
    
    
    private func setMealDetailCell(indexPath: IndexPath, nutrient: Double, nutrientType: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
        var nutrient = nutrient
        let roundedNutrientValue = nutrient.removePointZeroEndingAndConvertToString()
        cell.typeLabel.text = nutrientType + ":"
        cell.numberLabel.text = "\(roundedNutrientValue) g"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 52
        }
        return 35
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return true
        }
        return false
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            do {
                try realm.write {
                    selectedMeal?[indexPath.section].isDeleted = true
                }
            }
            catch {
                print(error)
            }
            
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            print(indexSet)
            tableView.deleteSections(indexSet, with: .automatic)
            
            reloadSelectedMeal()
            
        }
    }


}
