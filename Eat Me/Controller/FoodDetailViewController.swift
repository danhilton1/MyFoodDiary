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
    var date: Date?
    var selectedSegmentIndex = 0
    var workingCopy: Food = Food()
    private let formatter = DateFormatter()
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var mealPicker: UISegmentedControl!
    @IBOutlet weak var servingSizeButton: UIButton!
    @IBOutlet weak var servingTextField: UITextField!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    
    //MARK:- View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white

        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        
        formatter.dateFormat = "E, d MMM"
        
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
        
        tableView.tableFooterView = UIView()
        servingTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        servingSizeButton.addTarget(self, action: #selector(servingButtonTapped), for: .touchUpInside)
        foodNameLabel.text = workingCopy.name
        mealPicker.tintColor = Color.skyBlue
        mealPicker.selectedSegmentIndex = selectedSegmentIndex
        servingSizeButton.setTitle(workingCopy.servingSize, for: .normal)
        caloriesLabel.text = "\(workingCopy.calories)"
        proteinLabel.text = workingCopy.protein.removePointZeroEndingAndConvertToString()
        carbsLabel.text = workingCopy.carbs.removePointZeroEndingAndConvertToString()
        fatLabel.text = workingCopy.fat.removePointZeroEndingAndConvertToString()
        servingTextField.text = workingCopy.serving.removePointZeroEndingAndConvertToString()
        
    }

    // MARK: - Add and save data methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        workingCopy.date = formatter.string(from: date ?? Date())
        
        switch mealPicker.selectedSegmentIndex {
        case 0:
            workingCopy.meal = Food.Meal.breakfast.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
        case 1:
            workingCopy.meal = Food.Meal.lunch.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
        case 2:
            workingCopy.meal = Food.Meal.dinner.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
        case 3:
            workingCopy.meal = Food.Meal.other.stringValue
            workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
            save(workingCopy)
        default:
            print("Error determining meal type.")
        }

        dismissViewWithAnimation()
        delegate?.reloadFood()
        mealDelegate?.reloadFood()
        
    }
    
    
    private func save(_ food: Object) {
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let servingSizeNumber = Double((food?.servingSize ?? "100").filter("01234567890.".contains)) ?? 100
        let servingSizeButtonNumber = Double((servingSizeButton.title(for: .normal) ?? "100").filter("01234567890.".contains)) ?? 100
        var totalServing: Double {
            return (Double(textField.text ?? "1") ?? 1) * servingSizeButtonNumber
        }
        let calories1g = Double(food?.calories ?? 0) / (servingSizeNumber * (food?.serving ?? 0))
        let protein1g = (food?.protein ?? 0) / (servingSizeNumber * (food?.serving ?? 0))
        let carbs1g = (food?.carbs ?? 0) / (servingSizeNumber * (food?.serving ?? 0))
        let fat1g = (food?.fat ?? 0) / (servingSizeNumber * (food?.serving ?? 0))

        if textField.text == "" || textField.text == "0" || textField.text == "0." {
            caloriesLabel.text = "0"
            proteinLabel.text = "0.0"
            carbsLabel.text = "0.0"
            fatLabel.text = "0.0"

        }
        else {
            workingCopy.calories = Int(round(calories1g * totalServing))
            workingCopy.protein = protein1g * totalServing
            workingCopy.carbs = carbs1g * totalServing
            workingCopy.fat = fat1g * totalServing
            
            caloriesLabel.text = "\(workingCopy.calories)"
            proteinLabel.text = workingCopy.protein.removePointZeroEndingAndConvertToString()
            carbsLabel.text = workingCopy.carbs.removePointZeroEndingAndConvertToString()
            fatLabel.text = workingCopy.fat.removePointZeroEndingAndConvertToString()
        }
    }
    
    @objc func servingButtonTapped(_ sender: UIButton) {   // NEEDS CLEANING UP


        let alertController = UIAlertController(title: "Choose Serving Size", message: nil, preferredStyle: .actionSheet)
        
        
        if let food = food {
            let servingSizeNumber = Double(food.servingSize.filter("01234567890.".contains)) ?? 100
            let calories1g = (Double(food.calories) / (servingSizeNumber * (food.serving)))
            let protein1g = (food.protein) / (servingSizeNumber * (food.serving))
            let carbs1g = (food.carbs) / (servingSizeNumber * (food.serving))
            let fat1g = (food.fat) / (servingSizeNumber * (food.serving))
            
            if food.servingSize != "100g" {
                
                addAction(for: alertController, title: "1g",
                          calories: round(10 * calories1g) / 10,
                          protein: round(100 * protein1g) / 100,
                          carbs: round(100 * carbs1g) / 100,
                          fat: round(100 * fat1g) / 100)
                
                addAction(for: alertController, title: food.servingSize,
                          calories: Double(food.calories),
                          protein: food.protein,
                          carbs: food.carbs,
                          fat: food.fat)

                addAction(for: alertController, title: "100g",
                          calories: round((Double(food.calories) / servingSizeNumber) * 100),
                          protein: (food.protein / servingSizeNumber) * 100,
                          carbs: (food.carbs / servingSizeNumber) * 100,
                          fat: (food.fat / servingSizeNumber) * 100)

            } else {
                addAction(for: alertController, title: "1g",
                          calories: round(10 * calories1g) / 10,
                          protein: round(100 * protein1g) / 100,
                          carbs: round(100 * carbs1g) / 100,
                          fat: round(100 * fat1g) / 100)

                addAction(for: alertController, title: "100g",
                          calories: Double(food.calories),
                          protein: food.protein.roundToXDecimalPoints(decimalPoints: 1),
                          carbs: food.carbs.roundToXDecimalPoints(decimalPoints: 1),
                          fat: food.fat.roundToXDecimalPoints(decimalPoints: 1))

            }
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)

    }
    
    
    func addAction(for alertController: UIAlertController, title: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        
        var protein = protein
        var carbs = carbs
        var fat = fat
        
        alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (UIAlertAction) in
            self.servingSizeButton.setTitle(title, for: .normal)
            self.caloriesLabel.text = "\(round(calories))"
            self.proteinLabel.text = "\(protein.roundToXDecimalPoints(decimalPoints: 1))"
            self.carbsLabel.text = "\(carbs.roundToXDecimalPoints(decimalPoints: 1))"
            self.fatLabel.text = "\(fat.roundToXDecimalPoints(decimalPoints: 1))"
            self.servingTextField.text = "1"
            
            self.workingCopy.servingSize = title
            self.workingCopy.calories = Int(round(calories))
            self.workingCopy.protein = protein.roundToXDecimalPoints(decimalPoints: 1)
            self.workingCopy.carbs = carbs.roundToXDecimalPoints(decimalPoints: 1)
            self.workingCopy.fat = fat.roundToXDecimalPoints(decimalPoints: 1)
        }))
        
    }
    

}


