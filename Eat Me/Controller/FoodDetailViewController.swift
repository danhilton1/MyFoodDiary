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
    
    //MARK:- Properties
    
    var food: Food?
    var workingCopy: Food = Food()
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var mealPicker: UISegmentedControl!
    @IBOutlet weak var servingSizeButton: UIButton!
    @IBOutlet weak var servingTextField: UITextField!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    weak var delegate: NewEntryDelegate?
    
    //MARK:- View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white

        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        
        
        if let food = food {
            workingCopy = food.copy()
        }

        setUpCells()
        

    }
    
    private func dismissViewWithAnimation() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    private func setUpCells() {
        
        servingTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        servingSizeButton.addTarget(self, action: #selector(servingButtonTapped), for: .touchUpInside)
        foodNameLabel.text = workingCopy.name
        mealPicker.tintColor = UIColor.flatSkyBlue()
        servingSizeButton.setTitle(workingCopy.servingSize, for: .normal)
        caloriesLabel.text = "\(workingCopy.calories)"
        proteinLabel.text = "\(workingCopy.protein)"
        carbsLabel.text = "\(workingCopy.carbs)"
        fatLabel.text = "\(workingCopy.fat)"
        
        var servingString = String(workingCopy.serving)
        if servingString.hasSuffix(".0") {
            servingString.removeLast()
            servingString.removeLast()
            servingTextField.text = servingString
        } else {
            servingTextField.text = String(workingCopy.serving)
        }
        
    }

    // MARK: - Add and save data methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        
        switch mealPicker.selectedSegmentIndex {  // NEEDS FIXING
        case 0:
            workingCopy.meal = Food.Meal.breakfast.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
//            let newBreakfastEntry = Food()
//            addAndSaveNewEntry(food: newBreakfastEntry, meal: .breakfast)
        case 1:
            workingCopy.meal = Food.Meal.lunch.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
//            let newFoodEntry = Food()
//            addAndSaveNewEntry(food: newFoodEntry, meal: .lunch)
        case 2:
            workingCopy.meal = Food.Meal.dinner.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
//            let newFoodEntry = Food()
//            addAndSaveNewEntry(food: newFoodEntry, meal: .dinner)
        case 3:
            workingCopy.meal = Food.Meal.other.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
//            let newOtherFoodEntry = Food()
//            addAndSaveNewEntry(food: newOtherFoodEntry, meal: .other)
        default:
            print("Error determining meal type.")
        }
        
        
    }
    
    private func addAndSaveNewEntry(food: Food, meal: Food.Meal) {
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "E, d MMM"
        food.meal = meal.stringValue
        
//        food.updateProperties(
//            date: workingCopy.date,
//            meal: meal,
//            name: workingCopy.name,
//            servingSize: workingCopy.servingSize,
//            serving: Double(servingTextField.text ?? "1") ?? 1,
//            calories: workingCopy.calories,
//            protein: workingCopy.protein,
//            carbs: workingCopy.carbs,
//            fat: workingCopy.fat
//        )
        
//        save(food: food)
//
//        dismissViewWithAnimation()
//        delegate?.reloadFood()

    }
    
    
    private func save(_ food: Object) {
        
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
        dismissViewWithAnimation()
        delegate?.reloadFood()
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let servingSizeNumber = Double((food?.servingSize ?? "100").filter("01234567890.".contains)) ?? 100
        let servingSizeButtonNumber = Double((servingSizeButton.title(for: .normal) ?? "100").filter("01234567890.".contains)) ?? 100
        var totalServing: Double {
            return (Double(textField.text ?? "1") ?? 1) * servingSizeButtonNumber
        }

        if textField.text == "" {
            caloriesLabel.text = "0"
            proteinLabel.text = "0.0"
            carbsLabel.text = "0.0"
            fatLabel.text = "0.0"

        }
        else if totalServing == 100 && servingSizeNumber == 100 {
            caloriesLabel.text = "\(food?.calories ?? workingCopy.calories)"
            proteinLabel.text = "\(food?.protein ?? workingCopy.protein)"
            carbsLabel.text = "\(food?.carbs ?? workingCopy.carbs)"
            fatLabel.text = "\(food?.fat ?? workingCopy.fat)"
        }
        else {
            
            workingCopy.calories = Int(round((Double(food?.calories ?? 0) / servingSizeNumber) * totalServing))
            workingCopy.protein = ((food?.protein ?? 0) / servingSizeNumber) * totalServing
            workingCopy.carbs = ((food?.carbs ?? 0) / servingSizeNumber) * totalServing
            workingCopy.fat = ((food?.fat ?? 0) / servingSizeNumber) * totalServing
            
            caloriesLabel.text = "\(workingCopy.calories)"
            proteinLabel.text = "\(workingCopy.protein.roundToXDecimalPoints(decimalPoints: 1))"
            carbsLabel.text = "\(workingCopy.carbs.roundToXDecimalPoints(decimalPoints: 1))"
            fatLabel.text = "\(workingCopy.fat.roundToXDecimalPoints(decimalPoints: 1))"

        }
//        else {
//            workingCopy.calories = Int(round((Double(food?.calories ?? 0) / 100) * totalServing))
//            workingCopy.protein = ((food?.protein ?? 0) / 100) * totalServing
//            workingCopy.carbs = ((food?.carbs ?? 0) / 100) * totalServing
//            workingCopy.fat = ((food?.fat ?? 0) / 100) * totalServing
//
//            caloriesLabel.text = "\(workingCopy.calories)"
//            proteinLabel.text = "\(workingCopy.protein.roundToXDecimalPoints(decimalPoints: 1))"
//            carbsLabel.text = "\(workingCopy.carbs.roundToXDecimalPoints(decimalPoints: 1))"
//            fatLabel.text = "\(workingCopy.fat.roundToXDecimalPoints(decimalPoints: 1))"
//        }

    }
    
    @objc func servingButtonTapped(_ sender: UIButton) {   // NEEDS CLEANING UP


        let alertController = UIAlertController(title: "Choose Serving Size", message: nil, preferredStyle: .actionSheet)
        
        
        if let food = food {
            let servingSizeNumber = Double(food.servingSize.filter("01234567890.".contains)) ?? 100
            if food.servingSize != "100g" {
                
                addAction(for: alertController, title: "1g",
                          calories: "\(round(10 * (Double(food.calories)) / servingSizeNumber) / 10)",
                          protein: "\(round(100 * (food.protein / servingSizeNumber)) / 100)",
                          carbs: "\(round(100 * (food.carbs / servingSizeNumber)) / 100)",
                          fat: "\(round(100 * (food.fat / servingSizeNumber)) / 100)")
                
                addAction(for: alertController, title: food.servingSize,
                          calories: "\(food.calories)",
                          protein: "\(food.protein)",
                          carbs: "\(food.carbs)",
                          fat: "\(food.fat)")

                addAction(for: alertController, title: "100g",
                          calories: "\(Int(round((Double(food.calories) / servingSizeNumber) * 100)))",
                          protein: "\((food.protein / servingSizeNumber) * 100)",
                          carbs: "\((food.carbs / servingSizeNumber) * 100)",
                          fat: "\((food.fat / servingSizeNumber) * 100)")

            } else {
                addAction(for: alertController, title: "1g",
                          calories: "\(round(10 * (Double(food.calories)) / 100) / 10)",
                          protein: "\(round(100 * (food.protein / 100)) / 100)",
                          carbs: "\(round(100 * (food.carbs / 100)) / 100)",
                          fat: "\(round(100 * (food.fat / 100)) / 100)")

                addAction(for: alertController, title: "100g",
                          calories: "\(food.calories)",
                          protein: "\(food.protein.roundToXDecimalPoints(decimalPoints: 1))",
                          carbs: "\(food.carbs.roundToXDecimalPoints(decimalPoints: 1))",
                          fat: "\(food.fat.roundToXDecimalPoints(decimalPoints: 1))")

            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)

    }
    
    
    func addAction(for alertController: UIAlertController, title: String, calories: String, protein: String, carbs: String, fat: String) {
        
        alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (UIAlertAction) in
            self.servingSizeButton.setTitle(title, for: .normal)
            self.caloriesLabel.text = calories
            self.proteinLabel.text = protein
            self.carbsLabel.text = carbs
            self.fatLabel.text = fat
            self.servingTextField.text = "1"
            
            self.workingCopy.servingSize = title
            self.workingCopy.calories = Int(calories) ?? 0
            self.workingCopy.protein = Double(protein) ?? 0
            self.workingCopy.carbs = Double(carbs) ?? 0
            self.workingCopy.fat = Double(fat) ?? 0
        }))
        
    }
    

}


