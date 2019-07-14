//
//  MealDetailViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 13/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class MealDetailViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var calories = 0
    var selectedMeal: Results<Food>? {
        didSet {
            if let foodList = selectedMeal {
                for food in 0..<foodList.count {
                    calories += Int(truncating: foodList[food].calories ?? 0)
                }
            }
        }
    }
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .white
        
        caloriesLabel.text = "   Calories: \(calories)"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .blue
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        return selectedMeal?.count ?? 0
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = UIColor.flatMint() // UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.white
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        
        if let foodList = selectedMeal {
            for i in 0..<foodList.count {
                if section == i {
                    label.text = "    \(foodList[i].name!)"
                }
            }
        }
        
       
        
        return label
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
        
        if let food = selectedMeal {
            for i in 0..<food.count {
                if indexPath.section == i {
                    switch indexPath.row {
                    case 0:
                        cell.typeLabel?.text = "Calories:"
                        cell.numberLabel.text = "\(food[i].calories ?? 0) kcal"
                    case 1:
                        let roundedNumberOfGrams = round(10 * Double(truncating: food[i].protein ?? 0)) / 10
                        cell.typeLabel.text = "Protein:"
                        cell.numberLabel.text = "\(roundedNumberOfGrams) g"
                    case 2:
                        let roundedNumberOfGrams = round(10 * Double(truncating: food[i].carbs ?? 0)) / 10
                        cell.typeLabel.text = "Carbs:"
                        cell.numberLabel.text = "\(roundedNumberOfGrams) g"
                    case 3:
                        let roundedNumberOfGrams = round(10 * Double(truncating: food[i].fat ?? 0)) / 10
                        cell.typeLabel.text = "Fat:"
                        cell.numberLabel.text = "\(roundedNumberOfGrams) g"
                    default:
                        cell.typeLabel.text = ""
                        cell.numberLabel.text = ""
                    }
                }
               
            }
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }

    

}
