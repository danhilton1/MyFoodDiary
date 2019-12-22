//
//  FoodDetailTableViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class FoodDetailViewController: UITableViewController {
    
    let realm = try! Realm()
    let db = Firestore.firestore()
    
    //MARK:- Properties
    
    var food: Food?
    var date: Date?
    var selectedSegmentIndex = 0
    var isEditingExistingEntry = false
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
        
        self.navigationController?.navigationBar.tintColor = .white
        //tabBarController?.tabBar.isHidden = true
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        
        formatter.dateFormat = "E, d MMM"
        
        if let food = food {
            workingCopy = food.copy()
        }

        setUpCells()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
        presentingViewController?.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }
    
    private func dismissViewWithAnimation() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: {
            self.delegate?.reloadFood(entry: nil, new: true)
            self.presentingViewController?.tabBarController?.tabBar.isHidden = false
        })
        
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
        var roundedServingString = "\(workingCopy.serving.roundToXDecimalPoints(decimalPoints: 2))"
        if roundedServingString.hasSuffix(".0") {
            roundedServingString.removeLast(2)
        }
        servingTextField.text = roundedServingString
        
    }

    // MARK: - Add and save data methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        workingCopy.date = formatter.string(from: date ?? Date())
        if !isEditingExistingEntry {
            workingCopy.dateValue = date
        }
        
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
        if isEditingExistingEntry {
            delegate?.reloadFood(entry: workingCopy, new: false)
            mealDelegate?.reloadFood(entry: workingCopy, new: false)
            navigationController?.popViewController(animated: true)
        }
        else {
            delegate?.reloadFood(entry: workingCopy, new: true)
            mealDelegate?.reloadFood(entry: workingCopy, new: true)
            dismissViewWithAnimation()
        }
        isEditingExistingEntry = false
        
    }
    
    
    private func save(_ food: Food) {
        
        guard let user = Auth.auth().currentUser?.email else { return }
        
        if !isEditingExistingEntry {
            
            food.saveFood(user: user)
            
//            do {
//                try realm.write {
//                    realm.add(food)
//                }
//            } catch {
//                print(error)
//            }
        }
        else {
            let fc = FoodsCollection.self
            let foodEntry = db.collection("users").document(user).collection(fc.collection).document(food.name!)
            
            foodEntry.updateData([
                fc.name: food.name!,
                fc.meal: food.meal ?? Food.Meal.other,
                fc.date: food.date!,
                fc.dateValue: food.dateValue,
                fc.servingSize: food.servingSize,
                fc.serving: food.serving,
                fc.calories: food.calories,
                fc.protein: food.protein,
                fc.carbs: food.carbs,
                fc.fat: food.fat,
                fc.isDeleted: false
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
            
//            do {
//                try realm.write {
//                    let foodList = realm.objects(Food.self)
//                    for entry in foodList {
//                        if entry.dateValue == food.dateValue {
//                            entry.meal = food.meal
//                            entry.name = food.name
//                            entry.servingSize = food.servingSize
//                            entry.serving = food.serving
//                            entry.calories = food.calories
//                            entry.protein = food.protein
//                            entry.carbs = food.carbs
//                            entry.fat = food.fat
//                            entry.isDeleted = food.isDeleted
//                        }
//                    }
//                }
//            } catch {
//                print(error)
//            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let servingSizeNumber = Double((food?.servingSize ?? "100").filter("01234567890.".contains)) ?? 100
        let servingSizeButtonNumber = Double((servingSizeButton.title(for: .normal) ?? "100").filter("01234567890.".contains)) ?? 100
        var totalServing: Double {
            return (Double(textField.text ?? "1") ?? 1) * servingSizeButtonNumber
        }
        //Create 1g values of nutrients to calculate total value of nutrient with serving size
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
            // If calories is less than 10, display calories as a Double with 1 d.p.
            if (calories1g * totalServing) < 10 {
                var calories = calories1g * totalServing
                caloriesLabel.text = calories.removePointZeroEndingAndConvertToString()
            } else {
                workingCopy.calories = Int(round(calories1g * totalServing))
                caloriesLabel.text = "\(workingCopy.calories)"
            }
            
            workingCopy.protein = protein1g * totalServing
            workingCopy.carbs = carbs1g * totalServing
            workingCopy.fat = fat1g * totalServing
            
            proteinLabel.text = workingCopy.protein.removePointZeroEndingAndConvertToString()
            carbsLabel.text = workingCopy.carbs.removePointZeroEndingAndConvertToString()
            fatLabel.text = workingCopy.fat.removePointZeroEndingAndConvertToString()
        }
    }
    
    @objc func servingButtonTapped(_ sender: UIButton) {   // NEEDS CLEANING UP

        let alertController = UIAlertController(title: "Choose Serving Size", message: nil, preferredStyle: .actionSheet)
        
        if let food = food {
            let servingSizeNumber = Double(food.servingSize.filter("01234567890.".contains)) ?? 100 // Serving size as Double
            let calories1g = Double(food.calories) / (servingSizeNumber * (food.serving))
            let protein1g = food.protein / (servingSizeNumber * (food.serving))
            let carbs1g = food.carbs / (servingSizeNumber * (food.serving))
            let fat1g = food.fat / (servingSizeNumber * (food.serving))
            
            if servingSizeNumber != 100 {
                
                addAction(for: alertController, title: "1g",
                          calories: calories1g,
                          protein: protein1g,
                          carbs: carbs1g,
                          fat: fat1g)
                
                addAction(for: alertController, title: food.servingSize,
                          calories: (calories1g * servingSizeNumber),
                          protein: protein1g * servingSizeNumber,
                          carbs: carbs1g * servingSizeNumber,
                          fat: fat1g * servingSizeNumber)

                addAction(for: alertController, title: "100g",
                          calories: calories1g * 100,
                          protein: protein1g * 100,
                          carbs: carbs1g * 100,
                          fat: fat1g * 100)

            } else {
                addAction(for: alertController, title: "1g",
                          calories: calories1g,
                          protein: protein1g,
                          carbs: carbs1g,
                          fat: fat1g)

                addAction(for: alertController, title: "100g",
                          calories: calories1g * 100,
                          protein: protein1g * 100,
                          carbs: carbs1g * 100,
                          fat: fat1g * 100)

            }
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    
    func addAction(for alertController: UIAlertController, title: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        var calories = calories
        var protein = protein
        var carbs = carbs
        var fat = fat
        
        alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (UIAlertAction) in
            self.servingSizeButton.setTitle(title, for: .normal)
            if title == "1g" {  // If 1g serving size selected, display calories as Double with 1 d.p.
                self.caloriesLabel.text = calories.removePointZeroEndingAndConvertToString()
            }
            else {
                self.caloriesLabel.text = "\(Int(round(calories)))"
            }
            self.proteinLabel.text = protein.removePointZeroEndingAndConvertToString()
            self.carbsLabel.text = carbs.removePointZeroEndingAndConvertToString()
            self.fatLabel.text = fat.removePointZeroEndingAndConvertToString()
            self.servingTextField.text = "1"
            
            self.workingCopy.servingSize = title
            self.workingCopy.calories = Int(round(calories))
            self.workingCopy.protein = protein.roundToXDecimalPoints(decimalPoints: 1)
            self.workingCopy.carbs = carbs.roundToXDecimalPoints(decimalPoints: 1)
            self.workingCopy.fat = fat.roundToXDecimalPoints(decimalPoints: 1)
        }))
        
    }
    

}


