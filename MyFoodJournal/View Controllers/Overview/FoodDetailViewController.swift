//
//  FoodDetailTableViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 12/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase

class FoodDetailViewController: UITableViewController {
    
    let db = Firestore.firestore()
    
    //MARK:- Properties
    
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    
    var food: Food?
    var date: Date?
    var selectedSegmentIndex = 0
    var isEditingExistingEntry = false
    var workingCopy: Food = Food()
    private let formatter = DateFormatter()
    
    // IBOutlets
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var mealPicker: UISegmentedControl!
    @IBOutlet weak var servingSizeButton: UIButton!
    
    @IBOutlet weak var servingSizeUnitButton: UIButton!
    @IBOutlet weak var servingTextField: UITextField!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var fibreLabel: UILabel!
    
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var caloriesTextLabel: UILabel!
    @IBOutlet weak var proteinTextLabel: UILabel!
    @IBOutlet weak var carbsTextLabel: UILabel!
    @IBOutlet weak var sugarTextLabel: UILabel!
    @IBOutlet weak var fatTextLabel: UILabel!
    @IBOutlet weak var saturatedFatTextLabel: UILabel!
    @IBOutlet weak var fibreTextLabel: UILabel!
    
    
    //MARK:- View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let food = food {
            workingCopy = food.copy()
        }
        setUpCells()
        
        formatter.dateFormat = "E, d MMM"
        
        checkDeviceAndUpdateLayout()
        
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
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false
        servingTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        servingSizeButton.addTarget(self, action: #selector(servingButtonTapped), for: .touchUpInside)
        foodNameLabel.text = workingCopy.name
        mealPicker.tintColor = Color.skyBlue
        mealPicker.selectedSegmentIndex = selectedSegmentIndex
        servingSizeButton.setTitle(workingCopy.servingSize, for: .normal)
        servingSizeUnitButton.setTitle(workingCopy.servingSizeUnit, for: .normal)
        caloriesLabel.text = "\(workingCopy.calories)"
        proteinLabel.text = workingCopy.protein.removePointZeroEndingAndConvertToString()
        carbsLabel.text = workingCopy.carbs.removePointZeroEndingAndConvertToString()
        sugarLabel.text = workingCopy.sugar.removePointZeroEndingAndConvertToString()
        fatLabel.text = workingCopy.fat.removePointZeroEndingAndConvertToString()
        saturatedFatLabel.text = workingCopy.saturatedFat.removePointZeroEndingAndConvertToString()
        fibreLabel.text = workingCopy.fibre.removePointZeroEndingAndConvertToString()
        var roundedServingString = "\(workingCopy.serving.roundToXDecimalPoints(decimalPoints: 2))"
        if roundedServingString.hasSuffix(".0") {
            roundedServingString.removeLast(2)
        }
        servingTextField.text = roundedServingString
        
    }
    
    func checkDeviceAndUpdateLayout() {
        if UIScreen.main.bounds.height < 600 {
            foodNameLabel.font = foodNameLabel.font.withSize(20)
            mealLabel.font = mealLabel.font.withSize(17)
            servingSizeLabel.font = servingSizeLabel.font.withSize(17)
            servingLabel.font = servingLabel.font.withSize(17)
            caloriesTextLabel.font = caloriesTextLabel.font.withSize(17)
            caloriesLabel.font = caloriesLabel.font.withSize(17)
            proteinTextLabel.font = proteinTextLabel.font.withSize(17)
            proteinLabel.font = proteinLabel.font.withSize(17)
            carbsTextLabel.font = carbsTextLabel.font.withSize(17)
            carbsLabel.font = carbsLabel.font.withSize(17)
            sugarTextLabel.font = sugarTextLabel.font.withSize(13)
            sugarLabel.font = sugarLabel.font.withSize(14)
            fatTextLabel.font = fatTextLabel.font.withSize(17)
            fatLabel.font = fatLabel.font.withSize(17)
            saturatedFatTextLabel.font = saturatedFatTextLabel.font.withSize(13)
            saturatedFatLabel.font = saturatedFatLabel.font.withSize(14)
            fibreTextLabel.font = fibreTextLabel.font.withSize(17)
            fibreLabel.font = fibreLabel.font.withSize(17)
            
            mealPicker.setTitle("Bfast", forSegmentAt: 0)
        }
    }

    // MARK: - Add and save data methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        workingCopy.date = formatter.string(from: date ?? Date())
        workingCopy.dateLastEdited = Date()
        workingCopy.isDeleted = false
        
        if !isEditingExistingEntry {
            workingCopy.dateCreated = Date()
            workingCopy.dateLastEdited = Date()
            workingCopy.uuid = UUID().uuidString
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
        
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        if isEditingExistingEntry {
            
            let fc = FoodsCollection.self
            let name = food.name?.replacingOccurrences(of: "/", with: "")
            let foodEntry = db.collection("users").document(user).collection(fc.collection).document("\(name!) \(food.uuid)")
            
            foodEntry.updateData([
                fc.name: food.name!,
                fc.meal: food.meal ?? Food.Meal.other,
                fc.date: food.date!,
                fc.dateCreated: food.dateCreated!,
                fc.dateLastEdited: Date(),
                fc.servingSize: food.servingSize,
                fc.servingSizeUnit: food.servingSizeUnit,
                fc.serving: food.serving,
                fc.calories: food.calories,
                fc.protein: food.protein,
                fc.carbs: food.carbs,
                fc.fat: food.fat,
                fc.sugar: food.sugar,
                fc.saturatedFat: food.saturatedFat,
                fc.fibre: food.fibre,
                fc.isDeleted: false
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document \(food.name!) successfully updated")
                }
            }
        }
        else {
            food.saveFood(user: user)
        }
    }
    
    //MARK:- Button Methods
    
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
        let sugar1g = (food?.sugar ?? 0) / (servingSizeNumber * (food?.serving ?? 0))
        let saturatedFat1g = (food?.saturatedFat ?? 0) / (servingSizeNumber * (food?.serving ?? 0))
        let fibre1g = (food?.fibre ?? 0) / (servingSizeNumber * (food?.serving ?? 0))

        if textField.text == "" || textField.text == "0" || textField.text == "0." {
            caloriesLabel.text = "0"
            proteinLabel.text = "0.0"
            carbsLabel.text = "0.0"
            fatLabel.text = "0.0"
            sugarLabel.text = "0.0"
            saturatedFatLabel.text = "0.0"
            fibreLabel.text = "0.0"

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
            workingCopy.sugar = sugar1g * totalServing
            workingCopy.saturatedFat = saturatedFat1g * totalServing
            workingCopy.fibre = fibre1g * totalServing
            
            proteinLabel.text = workingCopy.protein.removePointZeroEndingAndConvertToString()
            carbsLabel.text = workingCopy.carbs.removePointZeroEndingAndConvertToString()
            fatLabel.text = workingCopy.fat.removePointZeroEndingAndConvertToString()
            sugarLabel.text = workingCopy.sugar.removePointZeroEndingAndConvertToString()
            saturatedFatLabel.text = workingCopy.saturatedFat.removePointZeroEndingAndConvertToString()
            fibreLabel.text = workingCopy.fibre.removePointZeroEndingAndConvertToString()
        }
    }
    
    @IBAction func unitButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Select Serving Size Unit", message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "g", style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.servingSizeUnitButton.setTitle("g", for: .normal)
            strongSelf.workingCopy.servingSizeUnit = "g"
        }))
        ac.addAction(UIAlertAction(title: "ml", style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.servingSizeUnitButton.setTitle("ml", for: .normal)
            strongSelf.workingCopy.servingSizeUnit = "ml"
        }))
        ac.addAction(UIAlertAction(title: "Custom", style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else { return }
            
            let customAC = UIAlertController(title: "Serving Size Unit", message: "Please enter a serving unit", preferredStyle: .alert)
            customAC.addTextField { (textField) in
                textField.placeholder = "Enter Unit"
            }
            customAC.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                strongSelf.servingSizeUnitButton.setTitle(strongSelf.workingCopy.servingSizeUnit, for: .normal)
            })
            customAC.addAction(UIAlertAction(title: "Enter", style: .default) { (action) in
                strongSelf.servingSizeUnitButton.setTitle(customAC.textFields?.first?.text, for: .normal)
                strongSelf.workingCopy.servingSizeUnit = customAC.textFields?.first?.text ?? "g"
                })
            strongSelf.present(customAC, animated: true)
            strongSelf.servingSizeUnitButton.setTitle("", for: .normal)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    
    @objc func servingButtonTapped(_ sender: UIButton) {

        let alertController = UIAlertController(title: "Choose Serving Size", message: nil, preferredStyle: .actionSheet)
        
        if let food = food {
            let servingSizeNumber = Double(food.servingSize.filter("01234567890.".contains)) ?? 100 // Serving size as Double
            let calories1g = Double(food.calories) / (servingSizeNumber * (food.serving))
            let protein1g = food.protein / (servingSizeNumber * (food.serving))
            let carbs1g = food.carbs / (servingSizeNumber * (food.serving))
            let fat1g = food.fat / (servingSizeNumber * (food.serving))
            let sugar1g = food.sugar / (servingSizeNumber * (food.serving))
            let saturatedFat1g = food.saturatedFat / (servingSizeNumber * (food.serving))
            let fibre1g = food.fibre / (servingSizeNumber * (food.serving))
            
            if servingSizeNumber != 100 {
                
                addAction(for: alertController, title: "1",
                          calories: calories1g,
                          protein: protein1g,
                          carbs: carbs1g,
                          fat: fat1g,
                          sugar: sugar1g,
                          saturatedFat: saturatedFat1g,
                          fibre: fibre1g)
                
                addAction(for: alertController, title: food.servingSize,
                          calories: (calories1g * servingSizeNumber),
                          protein: protein1g * servingSizeNumber,
                          carbs: carbs1g * servingSizeNumber,
                          fat: fat1g * servingSizeNumber,
                          sugar: sugar1g * servingSizeNumber,
                          saturatedFat: saturatedFat1g * servingSizeNumber,
                          fibre: fibre1g * servingSizeNumber)

                addAction(for: alertController, title: "100",
                          calories: calories1g * 100,
                          protein: protein1g * 100,
                          carbs: carbs1g * 100,
                          fat: fat1g * 100,
                          sugar: sugar1g * 100,
                          saturatedFat: saturatedFat1g * 100,
                          fibre: fibre1g * 100)

            } else {
                addAction(for: alertController, title: "1",
                          calories: calories1g,
                          protein: protein1g,
                          carbs: carbs1g,
                          fat: fat1g,
                          sugar: sugar1g,
                          saturatedFat: saturatedFat1g,
                          fibre: fibre1g)

                addAction(for: alertController, title: "100",
                          calories: calories1g * 100,
                          protein: protein1g * 100,
                          carbs: carbs1g * 100,
                          fat: fat1g * 100,
                          sugar: sugar1g * 100,
                          saturatedFat: saturatedFat1g * 100,
                          fibre: fibre1g * 100)

            }
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    
    func addAction(for alertController: UIAlertController, title: String, calories: Double, protein: Double, carbs: Double, fat: Double, sugar: Double, saturatedFat: Double, fibre: Double) {
        var calories = calories
        var protein = protein
        var carbs = carbs
        var fat = fat
        var sugar = sugar
        var saturatedFat = saturatedFat
        var fibre = fibre
        
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
            self.workingCopy.sugar = sugar.roundToXDecimalPoints(decimalPoints: 1)
            self.workingCopy.saturatedFat = saturatedFat.roundToXDecimalPoints(decimalPoints: 1)
            self.workingCopy.fibre = fibre.roundToXDecimalPoints(decimalPoints: 1)
        }))
        
    }
    
    //MARK:- Tableview Method
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            if UIScreen.main.bounds.height < 600 {
                return 55
            }
            else {
                return 60
            }
        }
        else {
            if UIScreen.main.bounds.height < 600 {
                return 40
            }
            else {
                return 46
            }
        }
    }

}


