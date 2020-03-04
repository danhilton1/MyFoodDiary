//
//  CalculatedGoalsViewController.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 03/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class CalculatedGoalsViewController: UIViewController {

    var user: Person!
    var TDEE = 0.0
    var calories = 0.0
    var protein = 0.0
    var carbs = 0.0
    var fat = 0.0
    
    @IBOutlet weak var TDEELabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        
    }
    
    func setUpViews() {
        TDEELabel.text = TDEE.roundWholeAndRemovePointZero()
        caloriesLabel.text = TDEE.roundWholeAndRemovePointZero()
        var protein = user.weight * 2
        proteinLabel.text = protein.roundWholeAndRemovePointZero()
        var fat = user.weight
        fatLabel.text = fat.roundWholeAndRemovePointZero()
        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        let carbsCalories = round(TDEE) - (proteinCalories + fatCalories)
        var carbs = carbsCalories / 4
        carbsLabel.text = carbs.roundWholeAndRemovePointZero()
        
    }
    
    
    
    @IBAction func goalSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {

            animateNumbersInLabels {
                DispatchQueue.main.async {
                    self.calories = round(self.TDEE) - 500
                    self.caloriesLabel.text = self.calories.roundWholeAndRemovePointZero()
                    
                    self.protein = (self.calories * 0.30) / 4
                    self.carbs = (self.calories * 0.5) / 4
                    self.fat = (self.calories * 0.20) / 9
                    self.proteinLabel.text = self.protein.roundWholeAndRemovePointZero()
                    self.carbsLabel.text = self.carbs.roundWholeAndRemovePointZero()
                    self.fatLabel.text = self.fat.roundWholeAndRemovePointZero()
                }
            }

            
        }
        
    }
    
    func animateNumbersInLabels(completed: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for _ in 0...20 {
                DispatchQueue.main.async {
                    self.caloriesLabel.text = "\(Int.random(in: 1000...3000))"
                    self.proteinLabel.text = "\(Int.random(in: 50...400))"
                    self.carbsLabel.text = "\(Int.random(in: 50...400))"
                    self.fatLabel.text = "\(Int.random(in: 50...400))"
                }
                usleep(1000)
            }
            completed()
        }
        
    }
    
}
