//
//  ViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class EatMeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    
    var breakfastFoods: Results<BreakfastFood>?
    var lunchFoods: Results<LunchFood>?
    var dinnerFoods: Results<DinnerFood>?
    var otherFoods: Results<OtherFood>?

    @IBOutlet weak var eatMeTableView: UITableView!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    
    var totalCals = 0
    
    
    var refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eatMeTableView.delegate = self
        eatMeTableView.dataSource = self
        
        eatMeTableView.separatorStyle = .none
        
        eatMeTableView.register(UINib(nibName: "MealOverviewCell", bundle: nil), forCellReuseIdentifier: "mealOverviewCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        eatMeTableView.addSubview(refreshControl)
        
        loadBreakfastFood()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadBreakfastFood()
    }
    
    @objc func refresh() {
        loadBreakfastFood()
        refreshControl.endRefreshing()
    }
    
    
    //MARK: - Tableview Data Source Methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.black
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 21)
        
        switch section {
        case 0:
            label.text = "   Breakfast"
        case 1:
            label.text = "   Lunch"
        case 2:
            label.text = "   Dinner"
        case 3:
            label.text = "   Other"
        default:
            label.text = ""
        }
        
       return label
            
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealOverviewCell", for: indexPath) as! MealOverviewCell
        
//        let food = foodList?[indexPath.section] ?? BreakfastFood()
//        var breakfastFood = BreakfastFood()
//        if let lastFoodIndex = breakfastFoods?.endIndex {
//            if lastFoodIndex > 0 {
//            breakfastFood = breakfastFoods?[lastFoodIndex - 1] ?? BreakfastFood()
//            }
//        }
        
        switch indexPath.section {
        case 0:
//            setCellData(cell: cell, calories: breakfastFood.calories, protein: breakfastFood.protein, carbs: breakfastFood.carbs, fat: breakfastFood.fat)
            getSumOfPropertiesForMeal(meal: breakfastFoods, cell: cell)
            
//        case 1:
//            setCellData(cell: cell, calories: lunchFood.calories, protein: lunchFood.protein, carbs: lunchFood.carbs, fat: lunchFood.fat)
//        case 2:
//            setCellData(cell: cell, calories: dinnerFood.calories, protein: dinnerFood.protein, carbs: dinnerFood.carbs, fat: dinnerFood.fat)
//        case 3:
//            setCellData(cell: cell, calories: otherFood.calories, protein: otherFood.protein, carbs: otherFood.carbs, fat: otherFood.fat)
        default:
            cell.calorieLabel.text = "0"
            cell.proteinLabel.text = "0"
            cell.carbsLabel.text = "0"
            cell.fatLabel.text = "0"
        }
        
        
        
        
        return cell
        
    }
    
//    func setCellData(cell: MealOverviewCell, calories: NSNumber?, protein: NSNumber?, carbs: NSNumber?, fat: NSNumber?) {
//        cell.calorieLabel.text = (calories?.stringValue ?? "0") + "kcal"
//        cell.proteinLabel.text = (protein?.stringValue ?? "0") + " g"
//        cell.carbsLabel.text = (carbs?.stringValue ?? "0") + " g"
//        cell.fatLabel.text = (fat?.stringValue ?? "0") + " g"
//    }
    
    func loadBreakfastFood() {
        
        breakfastFoods = realm.objects(BreakfastFood.self)
        
        totalCaloriesLabel.text = "Total Calories: \(totalCals)"
        
        eatMeTableView.reloadData()
        
    }
    
    func getSumOfPropertiesForMeal(meal: Results<BreakfastFood>?, cell: MealOverviewCell) {
        
        var calorieArray = [NSNumber]()
        var proteinArray = [NSNumber]()
        var carbsArray = [NSNumber]()
        var fatArray = [NSNumber]()
        var breakfastCalories = 0
        var breakfastProtein = 0.0
        var breakfastCarbs = 0.0
        var breakfastFat = 0.0
        
        if let foodList = meal {
            for i in 0..<foodList.count {
                calorieArray.append(foodList[i].calories ?? 0)
                proteinArray.append(foodList[i].protein ?? 0)
                carbsArray.append(foodList[i].carbs ?? 0)
                fatArray.append(foodList[i].fat ?? 0)
            }
            
            for i in 0..<calorieArray.count {
                breakfastCalories += Int(truncating: calorieArray[i])
                breakfastProtein += Double(truncating: proteinArray[i])
                breakfastCarbs += Double(truncating: carbsArray[i])
                breakfastFat += Double(truncating: fatArray[i])
                
            }
            
        }
        cell.calorieLabel.text = "\(breakfastCalories) kcal"
        cell.proteinLabel.text = "\(breakfastProtein) g"
        cell.carbsLabel.text = "\(breakfastCarbs) g"
        cell.fatLabel.text = "\(breakfastFat) g"
        
        totalCals += breakfastCalories
        
    }
    
//    func getSumOfProteinForMeal(meal: Results<BreakfastFood>?, cell: MealOverviewCell) {
//
//        var proteinArray = [NSNumber]()
//        var breakfastProtein = 0
//
//        if let foodList = meal {
//            for i in 0..<foodList.count {
//                proteinArray.append(foodList[i].protein ?? 0)
//            }
//
//            for i in 0..<proteinArray.count {
//                breakfastProtein += Int(proteinArray[i])
//            }
//
//        }
//        cell.proteinLabel.text = "\(breakfastProtein) g"
//
//    }
    
//    func getSumOfFoodEntries(list: Results<AnyRealmCollection>) {
//
//
//
//    }


}

