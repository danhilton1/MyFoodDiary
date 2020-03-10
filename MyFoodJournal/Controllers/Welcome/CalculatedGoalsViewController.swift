//
//  CalculatedGoalsViewController.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 03/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation
import UIKit
import Firebase

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
    @IBOutlet weak var weightChangeLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var continueWithoutButton: UIButton!
    
    enum WeightChangeMessages {
        static let maintain = "+/- 0 lbs/kg per week"
        static let lose = "- ~1 lbs (~0.45 kg) per week"
        static let gain = "+ 0.3-0.7 lbs (0.14-0.32 kg) per week"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        
    }
    
    func setUpViews() {
        acceptButton.layer.cornerRadius = 22
        continueWithoutButton.layer.cornerRadius = 17
        acceptButton.setTitleColor(Color.skyBlue, for: .normal)
        continueWithoutButton.setTitleColor(Color.salmon, for: .normal)
        
        TDEELabel.text = TDEE.roundWholeAndRemovePointZero()
        weightChangeLabel.text = WeightChangeMessages.maintain
        caloriesLabel.text = TDEE.roundWholeAndRemovePointZero()
        calories = round(TDEE)
        protein = round(user.weight * 2.2)
        let proteinCalories = protein * 4
        fat = round((TDEE * 0.20) / 9)
        let fatCalories = fat * 9
        let carbsCalories = calories - (proteinCalories + fatCalories)
        carbs = round(carbsCalories / 4)
        
        proteinLabel.text = protein.roundWholeAndRemovePointZero()
        fatLabel.text = fat.roundWholeAndRemovePointZero()
        carbsLabel.text = carbs.roundWholeAndRemovePointZero()
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func goalInfoButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Estimated Nutritional Goals", message: "", preferredStyle: .alert)
        
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

        let messageAttrString = NSMutableAttributedString(string: "\nThese values are only estimates based upon the information you provided and will vary depending on your daily activity level. If you find these targets are not working for you then please adjust the values accordingly.", attributes: messageFont)

        ac.setValue(messageAttrString, forKey: "attributedMessage")
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    
    @IBAction func goalSegmentChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            weightChangeLabel.text = WeightChangeMessages.lose
            animateNumbersInLabels {
                self.calories = round(self.TDEE) - 500
                self.updateNutritionLabels(calories: self.calories, proteinWeightMultiplier: 2.3)
            }
        }
        else if sender.selectedSegmentIndex == 1 {
            weightChangeLabel.text = WeightChangeMessages.maintain
            animateNumbersInLabels {
                self.calories = round(self.TDEE)
                self.updateNutritionLabels(calories: self.calories, proteinWeightMultiplier: 2.2)
            }
        }
        else {
            weightChangeLabel.text = WeightChangeMessages.gain
            animateNumbersInLabels {
                self.calories = round(self.TDEE) + 300
                self.updateNutritionLabels(calories: self.calories, proteinWeightMultiplier: 2)
            }
        }
        
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "GoToTabBar", sender: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Continue", message: "You can set your own custom goals in the 'Goals' section under the 'More' tab.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "ContinueWithoutGoals", sender: nil)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    func animateNumbersInLabels(completed: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            for _ in 0...18 {
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
    
    func updateNutritionLabels(calories: Double, proteinWeightMultiplier: Double) {
        
        DispatchQueue.main.async {
            var calories = calories
            self.caloriesLabel.text = calories.roundWholeAndRemovePointZero()
            
            self.protein = round(self.user.weight * proteinWeightMultiplier)
            let proteinCalories = self.protein * 4
            self.fat = round((self.calories * 0.20) / 9)
            let fatCalories = self.fat * 9
            let carbsCalories = self.calories - (proteinCalories + fatCalories)
            self.carbs = round(carbsCalories / 4)
            
            self.proteinLabel.text = self.protein.roundWholeAndRemovePointZero()
            self.carbsLabel.text = self.carbs.roundWholeAndRemovePointZero()
            self.fatLabel.text = self.fat.roundWholeAndRemovePointZero()
        }
    }
    
    func setGoalsAndInitalWeight(segue: UIStoryboardSegue) {
        let defaults = UserDefaults()
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM YYYY"
        
        defaults.set(Int(calories), forKey: UserDefaultsKeys.goalCalories)
        defaults.set(protein, forKey: UserDefaultsKeys.goalProtein)
        defaults.set(carbs, forKey: UserDefaultsKeys.goalCarbs)
        defaults.set(fat, forKey: UserDefaultsKeys.goalFat)
        defaults.set(user.weightUnit.stringValue, forKey: UserDefaultsKeys.weightUnit)
        
        let initalWeight = Weight()
        initalWeight.weight = user.weight
        initalWeight.unit = user.weightUnit.stringValue
        initalWeight.date = Date()
        initalWeight.dateLastEdited = Date()
        initalWeight.dateString = formatter.string(from: Date())
        guard let user = Auth.auth().currentUser?.uid else { return }
        initalWeight.saveWeight(user: user)
        
        let tabController = segue.destination as! UITabBarController
        let weightNavController = tabController.viewControllers?[1] as! UINavigationController
        let weightVC = weightNavController.viewControllers.first as! WeightViewController
        weightVC.allWeightEntries = [initalWeight]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToTabBar" {
            
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            setGoalsAndInitalWeight(segue: segue)
            
        }
        else if segue.identifier == "ContinueWithoutGoals" {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    
}
