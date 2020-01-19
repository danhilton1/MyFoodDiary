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
    

    var allFood: [Food]?
    
    @IBOutlet weak var numberOneFoodLabel: UILabel!
    @IBOutlet weak var numberTwoFoodLabel: UILabel!
    @IBOutlet weak var numberThreeFoodLabel: UILabel!
    @IBOutlet weak var numberOneEntriesLabel: UILabel!
    @IBOutlet weak var numberTwoEntriesLabel: UILabel!
    @IBOutlet weak var numberThreeEntriesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
    }
   
    func setUpViews() {
        if var foodEntries = allFood {
            foodEntries.sort { $0.numberOfTimesAdded > $1.numberOfTimesAdded }
            
            setLabelText(foodLabel: numberOneFoodLabel, entriesLabel: numberOneEntriesLabel, entry: foodEntries[0])
            setLabelText(foodLabel: numberTwoFoodLabel, entriesLabel: numberTwoEntriesLabel, entry: foodEntries[1])
            setLabelText(foodLabel: numberThreeFoodLabel, entriesLabel: numberThreeEntriesLabel, entry: foodEntries[2])
        }
    }

    func setLabelText(foodLabel: UILabel, entriesLabel: UILabel, entry: Food) {
        foodLabel.text = entry.name
        if entry.numberOfTimesAdded < 2 {
            entriesLabel.text = "\(entry.numberOfTimesAdded) entry"
        }
        else {
            entriesLabel.text = "\(entry.numberOfTimesAdded) entries"
        }
    }
    
    
}
