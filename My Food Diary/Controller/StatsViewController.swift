//
//  StatsViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 19/01/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

//TODO:- Update allFood when new entry is made


import Foundation
import UIKit

class StatsViewController: UIViewController {
    
    //MARK:- Properties
    
    var allFood: [Food]?
    
    @IBOutlet weak var numberOneFoodLabel: UILabel!
    @IBOutlet weak var numberTwoFoodLabel: UILabel!
    @IBOutlet weak var numberThreeFoodLabel: UILabel!
    @IBOutlet weak var numberOneEntriesLabel: UILabel!
    @IBOutlet weak var numberTwoEntriesLabel: UILabel!
    @IBOutlet weak var numberThreeEntriesLabel: UILabel!
    
    @IBOutlet weak var number3BottomConstraint: NSLayoutConstraint!
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        if UIScreen.main.bounds.height < 600 {
            number3BottomConstraint.constant = 50
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
    }
   
    func setUpViews() {
        if let foodEntries = allFood {
            if foodEntries.count < 3 {
                numberOneFoodLabel.text = "Not enough entries made"
                numberTwoFoodLabel.text = "Not enough entries made"
                numberThreeFoodLabel.text = "Not enough entries made"
                numberOneEntriesLabel.isHidden = true
                numberTwoEntriesLabel.isHidden = true
                numberThreeEntriesLabel.isHidden = true
            }
            else {
                var foodNames = [String]()
                for food in foodEntries {
                    foodNames.append(food.name!)
                }
                
                var foodCountDictionary = [String: Int]()
                for name in foodNames {
                    foodCountDictionary[name] = (foodCountDictionary[name] ?? 0) + 1
                }
                
                let sortedFood = foodCountDictionary.sorted { $0.value > $1.value }
                
                setLabelText(foodLabel: numberOneFoodLabel, entriesLabel: numberOneEntriesLabel, foodName: sortedFood[0].key, numberOfEntries: sortedFood[0].value)
                setLabelText(foodLabel: numberTwoFoodLabel, entriesLabel: numberTwoEntriesLabel, foodName: sortedFood[1].key, numberOfEntries: sortedFood[1].value)
                setLabelText(foodLabel: numberThreeFoodLabel, entriesLabel: numberThreeEntriesLabel, foodName: sortedFood[2].key, numberOfEntries: sortedFood[2].value)
            }
        }
    }

    func setLabelText(foodLabel: UILabel, entriesLabel: UILabel, foodName: String, numberOfEntries: Int) {
        foodLabel.text = foodName
        if numberOfEntries < 2 {
            entriesLabel.text = "\(numberOfEntries) entry"
        }
        else {
            entriesLabel.text = "\(numberOfEntries) entries"
        }
    }
    
    
}
