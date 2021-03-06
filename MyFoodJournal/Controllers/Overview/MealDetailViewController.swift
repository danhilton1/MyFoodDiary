//
//  MealDetailViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 13/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase

class MealDetailViewController: UITableViewController, NewEntryDelegate {
    
    //MARK:- Properties
    
    let db = Firestore.firestore()
    
    var calories = 0
    var selectedFoodList: [Food]? {
        didSet {
            guard let foodList = selectedFoodList else { return }
            calories = 0
            for food in foodList {
                calories += food.calories
            }
        }
    }
    var allFood: [Food]?

    var delegate: NewEntryDelegate?
    var date: Date?
    var meal: Food.Meal = .breakfast
    var noEntriesToDisplay = false
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        noEntriesToDisplay = false
    }
    
    func setUpViews() {
        self.navigationController?.navigationBar.tintColor = .white
        
        if UIScreen.main.bounds.height < 600 {
            caloriesLabel.font = caloriesLabel.font.withSize(20)
        }
        caloriesLabel.text = "   Calories: \(calories)"
        
        tableView.tableFooterView = UIView()
        if selectedFoodList?.count == 0 {
            tableView.separatorStyle = .none
        }
    }
    
    //MARK:- Delegate Methods
    
    func reloadFood(entry: Food?, new: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
            if new {
                self.selectedFoodList?.append(entry!)
            }
            else {
                var index = 0
                for food in self.selectedFoodList! {
                    if food.name == entry?.name {
                        self.selectedFoodList?.remove(at: index)
                        self.selectedFoodList?.insert(entry!, at: index)
                        break
                    }
                    index += 1
                }
            }

            self.reloadSelectedMeal()
            self.tableView.reloadData()
            self.tableView.separatorStyle = .singleLine
        }
    }
    
    func reloadSelectedMeal() {
        
        guard let foodList = selectedFoodList else { return }
        calories = 0
        for food in foodList {
            calories += food.calories
        }
        caloriesLabel.text = "   Calories: \(calories)"
    }
    
    //MARK:- Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToPopUp" {
            let popUpNC = segue.destination as! UINavigationController
            let destVC = popUpNC.viewControllers.first as! NewEntryViewController
            destVC.allFood = allFood
            destVC.date = date
            destVC.meal = meal
            destVC.mealDelegate = self
            destVC.delegate = delegate
        }
        else if segue.identifier == "GoToFoodDetail" {
            let destVC = segue.destination as! FoodDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            destVC.delegate = delegate
            destVC.mealDelegate = self
            destVC.date = date
            destVC.food = selectedFoodList![indexPath.section]
            destVC.selectedSegmentIndex = meal.intValue
            destVC.isEditingExistingEntry = true
        }
    }
    
}
    
    
// MARK: - Table view data source and delegate methods

extension MealDetailViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedFoodList?.count == 0 && !noEntriesToDisplay {
            return 1
        }
        return selectedFoodList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedFoodList?.count == 0 {
            return 1
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if UIScreen.main.bounds.height < 600 {
                return 48
            }
            else {
                return 52
            }
        }
        if UIScreen.main.bounds.height < 600 {
            return 28
        }
        else {
            return 35
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let food = selectedFoodList {
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
        cell.totalServingLabel.text = totalServing.removePointZeroEndingAndConvertToString() + " \(food.servingSizeUnit)"
        
        if UIScreen.main.bounds.height < 600 {
            cell.foodNameLabel.font = cell.foodNameLabel.font.withSize(16)
            cell.caloriesLabel.font = cell.caloriesLabel.font.withSize(16)
            cell.totalServingLabel.font = cell.totalServingLabel.font.withSize(16)
            cell.mealDetailEqualWidthConstraint.constant = -120
        }
        
        return cell
    }
    
    
    private func setMealDetailCell(indexPath: IndexPath, nutrient: Double, nutrientType: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
        cell.isUserInteractionEnabled = false
        var nutrient = nutrient
        let roundedNutrientValue = nutrient.removePointZeroEndingAndConvertToString()
        cell.typeLabel.text = nutrientType + ":"
        cell.numberLabel.text = "\(roundedNutrientValue) g"
        if UIScreen.main.bounds.height < 600 {
            cell.typeLabel.font = cell.typeLabel.font.withSize(15)
            cell.numberLabel.font = cell.numberLabel.font.withSize(15)
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return true
        }
        return false
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let fc = FoodConstants.self
            guard let user = Auth.auth().currentUser?.uid else { return }
            guard let food = selectedFoodList?[indexPath.section] else { return }
            let foodRef = db.collection("users").document(user).collection(fc.collection).document("\(food.name!) \(food.uuid)")
            
            foodRef.updateData([
                fc.isDeleted: true,
                fc.dateLastEdited: Date()
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document \(food.name ?? "") successfully updated")
                }
            }
            
            let nav = parent as! UINavigationController
            let PVC = nav.viewControllers.first as! OverviewPageViewController
            let overviewVC = PVC.viewControllers?.first as! OverviewViewController
            
            var index = 0
               for entry in allFood! {
                if entry.name == food.name && entry.uuid == food.uuid {
                        selectedFoodList?.remove(at: indexPath.section)
                        PVC.allFood[index].isDeleted = true
                        overviewVC.allFood?[index].isDeleted = true
                        overviewVC.loadFoodData()
                        break
                   }
                   index += 1
               }
            
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            
            if tableView.numberOfSections == 1 {
                noEntriesToDisplay = true
            }
            tableView.deleteSections(indexSet, with: .automatic)
            
            
            reloadSelectedMeal()
            
        }
    }


}
