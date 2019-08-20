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
    var foodName: String = ""
    var servingSize: String = ""
    var serving: Double = 1
    var calories: Int = 0
    var protein: Double? = 0
    var carbs: Double? = 0
    var fat: Double? = 0
    var calories100g: Int = 0
    var protein100g: Double?
    var carbs100g: Double?
    var fat100g: Double?
    var calories1g: Double {
        return Double(calories100g) / 100
    }
    var protein1g: Double {
        return (protein100g ?? 0) / 100
    }
    var carbs1g: Double {
        return (carbs100g ?? 0) / 100
    }
    var fat1g: Double {
        return (fat100g ?? 0) / 100
    }
    
    var originalServingSize: String?
    var originalCalories: Int = 0
    var originalProtein: Double?
    var originalCarbs: Double?
    var originalFat: Double?
    
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
        
        originalServingSize = servingSize
        originalCalories = calories
        originalProtein = protein
        originalCarbs = carbs
        originalFat = fat
        
        let originalFood = food?.copy() as? Food
        originalFood?.calories = 9999
        print(calories)
        print(originalFood?.calories)
        
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
        foodNameLabel.text = foodName
        mealPicker.tintColor = UIColor.flatSkyBlue()
        servingSizeButton.setTitle(servingSize, for: .normal)
        servingTextField.text = String(serving)
        caloriesLabel.text = String(calories)
        proteinLabel.text = "\(protein ?? 0) g"
        carbsLabel.text = "\(carbs ?? 0) g"
        fatLabel.text = "\(fat ?? 0) g"
        
    }

    // MARK: - Add and save data methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        
        switch mealPicker.selectedSegmentIndex {  // NEEDS FIXING
        case 0:
            let newBreakfastEntry = Food()
            addAndSaveNewEntry(food: newBreakfastEntry, meal: .breakfast)
        case 1:
            let newFoodEntry = Food()
            addAndSaveNewEntry(food: newFoodEntry, meal: .lunch)
        case 2:
            let newFoodEntry = Food()
            addAndSaveNewEntry(food: newFoodEntry, meal: .dinner)
        case 3:
            let newOtherFoodEntry = Food()
            addAndSaveNewEntry(food: newOtherFoodEntry, meal: .other)
        default:
            print("Error determining meal type.")
        }
        
        
    }
    
    private func addAndSaveNewEntry(food: Food, meal: Food.Meal) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        
        food.updateProperties(
            date: formatter.string(from: date ?? Date()),
            meal: meal,
            name: foodName,
            servingSize: servingSize,
            serving: Double(servingTextField.text ?? "1")!,
            calories: calories as NSNumber,
            protein: protein as NSNumber?,
            carbs: carbs as NSNumber?,
            fat: fat as NSNumber?
        )
        
        save(food: food)
        
        dismissViewWithAnimation()
        delegate?.reloadFood()

    }
    
    
    private func save(food: Object) {
        
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        var totalServing: Double {
            let servingSizeNumber = servingSize.filter("01234567890.".contains)
            return (Double(textField.text ?? "0") ?? 1) * (Double(servingSizeNumber) ?? 1)
        }

        if textField.text == "" {
            caloriesLabel.text = "0"
            proteinLabel.text = "0 g"
            carbsLabel.text = "0 g"
            fatLabel.text = "0 g"

        }
        else if totalServing == 100 {
            caloriesLabel.text = String(calories100g)
            proteinLabel.text = "\(protein100g ?? 0) g"
            carbsLabel.text = "\(carbs100g ?? 0) g"
            fatLabel.text = "\(fat100g ?? 0) g"
        }
        else {
            calories = Int(round(calories1g * totalServing))
            protein = round(10 * (protein1g * totalServing)) / 10
            carbs = round(10 * (carbs1g * totalServing)) / 10
            fat = round(10 * (fat1g * totalServing)) / 10
            
            caloriesLabel.text = String(calories)
            proteinLabel.text = "\(protein ?? 0) g"
            carbsLabel.text = "\(carbs ?? 0) g"
            fatLabel.text = "\(fat ?? 0) g"

        }

    }
    
    @objc func servingButtonTapped(_ sender: UIButton) {   // NEEDS CLEANING UP


        let alertController = UIAlertController(title: "Choose Serving Size", message: nil, preferredStyle: .actionSheet)

        if originalServingSize != "100g" {
            addAction(for: alertController, title: "1g", calories: String(Int(round(calories1g))),
                      protein: "\(round(100 * protein1g) / 100) g",
                      carbs: "\(round(100 * carbs1g) / 100) g",
                      fat: "\(round(100 * fat1g) / 100) g")

            addAction(for: alertController, title: originalServingSize ?? "100g",
                      calories: String(originalCalories),
                      protein: "\(self.originalProtein ?? 0) g",
                      carbs: "\(self.originalCarbs ?? 0) g",
                      fat: "\(self.originalFat ?? 0) g")

            addAction(for: alertController, title: "100g", calories: String(calories100g),
                      protein: "\(protein100g ?? 0) g",
                      carbs: "\(carbs100g ?? 0) g",
                      fat: "\(fat100g ?? 0) g")

        } else {
            addAction(for: alertController, title: "1g", calories: String(Int(round(calories1g))),
                      protein: "\(round(100 * protein1g) / 100) g",
                      carbs: "\(round(100 * carbs1g) / 100) g",
                      fat: "\(round(100 * fat1g) / 100) g")

            addAction(for: alertController, title: "100g", calories: String(calories100g),
                      protein: "\(protein100g ?? 0) g",
                      carbs: "\(carbs100g ?? 0) g",
                      fat: "\(fat100g ?? 0) g")

        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)

    }
    
    
    func addAction(for alertController: UIAlertController, title: String, calories: String, protein: String, carbs: String, fat: String) {
        
        alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (UIAlertAction) in
            self.servingSizeButton.setTitle(title, for: .normal)
            self.servingSize = title
            self.caloriesLabel.text = calories
            self.proteinLabel.text = protein
            self.carbsLabel.text = carbs
            self.fatLabel.text = fat
            self.servingTextField.text = "1"
        }))
        
    }
    
    
    
    

}

//MARK:- Table view data source and delegate methods

//extension FoodDetailViewController {

    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let header = UITableViewHeaderFooterView()
//        header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
//
//        switch section {
//        case 0:
//            return nil
//        case 1:
//            header.textLabel?.text = " "
//            return header
//        default:
//            header.textLabel?.text = ""
//            return header
//        }
//
//    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//        let headerHeight: CGFloat
//        
//        if section == 0 {
//            headerHeight = CGFloat.leastNonzeroMagnitude
//        } else {
//            headerHeight = 23
//        }
//        
//        return headerHeight
//    }
    
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let mealPickerCell = tableView.dequeueReusableCell(withIdentifier: "MealPickerCell", for: indexPath) as! MealPickerCell
//        let foodNameCell = tableView.dequeueReusableCell(withIdentifier: "FoodNameCell", for: indexPath) as! FoodNameCell
//        let servingSizeCell = tableView.dequeueReusableCell(withIdentifier: "ServingSizeCell", for: indexPath) as! ServingSizeCell
//        let servingCell = tableView.dequeueReusableCell(withIdentifier: "ServingCell", for: indexPath) as! ServingCell
//        let nutritionCell = tableView.dequeueReusableCell(withIdentifier: "NutritionCell", for: indexPath) as! NutritionCell
//
//        mealPickerCell.mealPicker.tintColor = UIColor.flatSkyBlue()
//        foodNameCell.foodNameLabel.text = foodName
//        servingSizeCell.servingSizeButton.setTitle(servingSize, for: .normal)
//        servingCell.servingTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
//        servingSizeCell.servingSizeButton.addTarget(self, action: #selector(servingButtonTapped), for: .touchUpInside)
//        servingCell.servingTextField.text = String(serving)
//
//        switch indexPath.section {
//        case 0:
//            switch indexPath.row {
//            case 0:
//                return mealPickerCell
//            case 1:
//                return foodNameCell
//            case 2:
//                return servingSizeCell
//            case 3:
//                return servingCell
//            default:
//                return UITableViewCell()
//            }
//        case 1:
//            switch indexPath.row {
//            case 0:
//                nutritionCell.nutrientLabel.text = "Calories:"
//                nutritionCell.quantityLabel.text = String(calories)
//                return nutritionCell
//            case 1:
//                nutritionCell.nutrientLabel.text = "Protein:"
//                nutritionCell.quantityLabel.text = "\(protein ?? 0)"
//                return nutritionCell
//            case 2:
//                nutritionCell.nutrientLabel.text = "Carbs:"
//                nutritionCell.quantityLabel.text = "\(carbs ?? 0)"
//                return nutritionCell
//            case 3:
//                nutritionCell.nutrientLabel.text = "Fat:"
//                nutritionCell.quantityLabel.text = "\(fat ?? 0)"
//                return nutritionCell
//            default:
//                return UITableViewCell()
//            }
//        default:
//            return UITableViewCell()
//        }
//
//
//    }
    
    
    
//}
