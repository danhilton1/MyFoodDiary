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
                    calories += foodList[food].calories
                }
            }
        }
    }
    
    @IBOutlet weak var caloriesLabel: UILabel!
    
    
    //MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .white
        
        caloriesLabel.text = "   Calories: \(calories)"
        
        tableView.allowsSelection = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = .blue
    }

    
    // MARK: - Table view data source and delegate methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectedMeal?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UITableViewCell()
        header.frame.size.height = 30
        header.backgroundColor = UIColor.flatSkyBlue()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor =  UIColor.flatSkyBlue() // UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.white
        label.font = UIFont(name: "Montserrat-SemiBold", size: 18)
        header.addSubview(label)
        
        let servingLabel = UILabel()
        servingLabel.translatesAutoresizingMaskIntoConstraints = false
        servingLabel.backgroundColor =  UIColor.flatSkyBlue() // UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        servingLabel.textColor = UIColor.white
        servingLabel.font = UIFont(name: "Montserrat-Regular", size: 18)
        servingLabel.textAlignment = .right
        header.addSubview(servingLabel)
        
        if let foodList = selectedMeal {    // NEEDS LOOKING AT
            for food in foodList {
                for i in 0..<foodList.count {
                    if section == i {
                        label.text = "    \(food.name ?? "Unknown Name")"
                        let result = food.servingSize.filter("01234567890.".contains)
                        if let servingSize = Double(result) {
                            var totalServingString = String(servingSize * food.serving)
                            if totalServingString.hasSuffix(".0") {
                                totalServingString.removeLast()
                                totalServingString.removeLast()
                                servingLabel.text = totalServingString + "g"
                            } else {
                                servingLabel.text = "\(servingSize * food.serving) g"
                            }
                        }
                    }
                }
            }
        }
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            
            servingLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            servingLabel.trailingAnchor.constraint(equalTo: header.layoutMarginsGuide.trailingAnchor)
        
        ])
        
        return header
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealDetailCell", for: indexPath) as! MealDetailCell
        
        if let food = selectedMeal {
            for i in 0..<food.count {
                if indexPath.section == i {
                    switch indexPath.row {
                    case 0:
                        cell.typeLabel?.text = "Calories:"
                        cell.numberLabel.text = "\(food[i].calories) kcal"
                    case 1:
//                        let roundedNumberOfGrams = food[i].protein.roundToXDecimalPoints(decimalPoints: 1)
                        cell.typeLabel.text = "Protein:"
                        cell.numberLabel.text = "\(food[i].protein) g"
                    case 2:
//                        let roundedNumberOfGrams = food[i].carbs.roundToXDecimalPoints(decimalPoints: 1)
                        cell.typeLabel.text = "Carbs:"
                        cell.numberLabel.text = "\(food[i].carbs) g"
                    case 3:
//                        let roundedNumberOfGrams = food[i].fat.roundToXDecimalPoints(decimalPoints: 1)
                        cell.typeLabel.text = "Fat:"
                        cell.numberLabel.text = "\(food[i].fat) g"
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
