//
//  FoodDetailTableViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class FoodDetailViewController: UITableViewController {
    
    let realm = try! Realm()
    
    let foodName: String! = ""
    let servingSize: String! = ""
    let serving: String = ""
    let calories: Int = 0
    let protein: Double? = 0
    let carbs: Double? = 0
    let fat: Double? = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 1:
            return 3
        case 2:
            return 4
        default:
            return 1
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let foodNameCell = tableView.dequeueReusableCell(withIdentifier: "FoodNameCell", for: indexPath) as! FoodNameCell
        let servingSizeCell = tableView.dequeueReusableCell(withIdentifier: "ServingSizeCell", for: indexPath) as! ServingSizeCell
        let servingCell = tableView.dequeueReusableCell(withIdentifier: "ServingCell", for: indexPath) as! ServingCell
        let nutritionCell = tableView.dequeueReusableCell(withIdentifier: "NutritionCell", for: indexPath) as! NutritionCell
        
        foodNameCell.nameLabel.text = foodName
        servingSizeCell.servingSizeButton.titleLabel?.text = servingSize
        servingCell.servingTextField.text = serving
        
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                return foodNameCell
            case 1:
                return servingSizeCell
            case 2:
                return servingCell
            default:
                return UITableViewCell()
            }
        case 2:
            switch indexPath.row {
            case 0:
                nutritionCell.nutritionTypeLabel.text = "Calories:"
                nutritionCell.quantityLabel.text = String(calories)
                return nutritionCell
            case 1:
                nutritionCell.nutritionTypeLabel.text = "Protein:"
                nutritionCell.quantityLabel.text = String(describing: protein)
                return nutritionCell
            case 2:
                nutritionCell.nutritionTypeLabel.text = "Carbs:"
                nutritionCell.quantityLabel.text = String(describing: carbs)
                return nutritionCell
            case 3:
                nutritionCell.nutritionTypeLabel.text = "Fat:"
                nutritionCell.quantityLabel.text = String(describing: fat)
                return nutritionCell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }

        
    }


}
