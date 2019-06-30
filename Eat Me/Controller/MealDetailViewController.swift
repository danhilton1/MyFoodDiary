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

//        self.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "big-plus2"), style: .plain, target: <#T##Any?#>, action: <#T##Selector?#>)
        self.navigationController?.navigationBar.tintColor = .white
        
        caloriesLabel.text = "   Calories: \(calories)"
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
        
        let cell = UITableViewCell()
        
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        
        if let food = selectedMeal {
            for i in 0..<food.count {
                if indexPath.section == i {
                    switch indexPath.row {
                    case 0:
                        cell.textLabel?.text = "Calories: \(food[i].calories ?? 0) kcal"
                    case 1:
                        cell.textLabel?.text = "Protein: \(food[i].protein ?? 0) g"
                    case 2:
                        cell.textLabel?.text = "Carbs: \(food[i].carbs ?? 0) g"
                    case 3:
                        cell.textLabel?.text = "Fat: \(food[i].fat ?? 0) g"
                    default:
                        cell.textLabel?.text = "0"
                    }
                }
               
            }
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    

}
