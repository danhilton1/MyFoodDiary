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
    
    var date: Date?
    var foodName: String = ""
    var servingSize: String = ""
    var serving: Double = 1
    var calories: Int = 0
    var protein: Double? = 0
    var carbs: Double? = 0
    var fat: Double? = 0
    var calories100g: Int = 0
    var protein100g: Double? = 0
    var carbs100g: Double? = 0
    var fat100g: Double? = 0
    var calories1g: Int {
        return calories100g / 100
    }
    var protein1g: Double {
        return protein100g ?? 0 / 100
    }
    var carbs1g: Double {
        return carbs100g ?? 0 / 100
    }
    var fat1g: Double {
        return fat100g ?? 0 / 100
    }
    
    weak var delegate: NewEntryDelegate?
    
    var servingCell: ServingCell?
    var servingTextField: UITextField!
    
    //MARK:- View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MealPickerCell", bundle: nil), forCellReuseIdentifier: "MealPickerCell")
        tableView.register(UINib(nibName: "FoodNameCell", bundle: nil), forCellReuseIdentifier: "FoodNameCell")
        tableView.register(UINib(nibName: "ServingSizeCell", bundle: nil), forCellReuseIdentifier: "ServingSizeCell")
        tableView.register(UINib(nibName: "ServingCell", bundle: nil), forCellReuseIdentifier: "ServingCell")
        tableView.register(UINib(nibName: "NutritionCell", bundle: nil), forCellReuseIdentifier: "NutritionCell")
        
        navigationController?.navigationBar.tintColor = .white
        
        servingCell = tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as? ServingCell
        servingTextField = servingCell?.servingTextField
        print(servingTextField.text)
        servingTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelection = false

    }
    
    private func dismissViewWithAnimation() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }

    // MARK: - Add and save data methods

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        let mealPickerCell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! MealPickerCell
        
        switch mealPickerCell.mealPicker.selectedSegmentIndex {
        case 0:
            addAndSaveNewEntry(meal: .breakfast)
        case 1:
            addAndSaveNewEntry(meal: .lunch)
        case 2:
            addAndSaveNewEntry(meal: .dinner)
        case 3:
            addAndSaveNewEntry(meal: .other)
        default:
            print("Error determining meal type.")
        }
        
        
    }
    
    private func addAndSaveNewEntry(meal: Food.Meal) {
        
        let newFoodEntry = Food()
        let servingCell = tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! ServingCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        
        newFoodEntry.updateProperties(
            date: formatter.string(from: date ?? Date()),
            meal: meal,
            name: foodName,
            servingSize: servingSize,
            serving: Double(servingCell.servingTextField.text ?? "1")!,
            calories: calories as NSNumber,
            protein: protein as NSNumber?,
            carbs: carbs as NSNumber?,
            fat: fat as NSNumber?
        )
        
        save(food: newFoodEntry)
        
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
        print("Textfield Method Working")
        var totalServing: Double {
            let servingSizeNumber = servingSize.filter("01234567890.".contains)
            return Double(textField.text!)! * Double(servingSizeNumber)!
        }
        
        if textField.text == "" {
            calories = 0
            protein = 0
            carbs = 0
            fat = 0
            tableView.reloadData()
        } else {
            calories = Int(round(Double(calories1g) * totalServing))
            protein = protein1g * totalServing
            carbs = carbs1g * totalServing
            fat = fat1g * totalServing
            tableView.reloadData()
        }
        
    }
    
    

}

//MARK:- Table view data source and delegate methods

extension FoodDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 4
        case 1:
            return 4
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UITableViewHeaderFooterView()
        header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        
        switch section {
        case 0:
            return nil
        case 1:
            header.textLabel?.text = " "
            return header
        default:
            header.textLabel?.text = ""
            return header
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerHeight: CGFloat
        
        if section == 0 {
            headerHeight = CGFloat.leastNonzeroMagnitude
        } else {
            headerHeight = 23
        }
        
        return headerHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mealPickerCell = tableView.dequeueReusableCell(withIdentifier: "MealPickerCell", for: indexPath) as! MealPickerCell
        let foodNameCell = tableView.dequeueReusableCell(withIdentifier: "FoodNameCell", for: indexPath) as! FoodNameCell
        let servingSizeCell = tableView.dequeueReusableCell(withIdentifier: "ServingSizeCell", for: indexPath) as! ServingSizeCell
        let servingCell = tableView.dequeueReusableCell(withIdentifier: "ServingCell", for: indexPath) as! ServingCell
        let nutritionCell = tableView.dequeueReusableCell(withIdentifier: "NutritionCell", for: indexPath) as! NutritionCell
        
        mealPickerCell.mealPicker.tintColor = UIColor.flatSkyBlue()
        foodNameCell.foodNameLabel.text = foodName
        servingSizeCell.servingSizeButton.setTitle(servingSize, for: .normal)
        servingCell.servingTextField.text = String(serving)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return mealPickerCell
            case 1:
                return foodNameCell
            case 2:
                return servingSizeCell
            case 3:
                return servingCell
            default:
                return UITableViewCell()
            }
        case 1:
            switch indexPath.row {
            case 0:
                nutritionCell.nutrientLabel.text = "Calories:"
                nutritionCell.quantityLabel.text = String(calories)
                return nutritionCell
            case 1:
                nutritionCell.nutrientLabel.text = "Protein:"
                nutritionCell.quantityLabel.text = "\(protein ?? 0)"
                return nutritionCell
            case 2:
                nutritionCell.nutrientLabel.text = "Carbs:"
                nutritionCell.quantityLabel.text = "\(carbs ?? 0)"
                return nutritionCell
            case 3:
                nutritionCell.nutrientLabel.text = "Fat:"
                nutritionCell.quantityLabel.text = "\(fat ?? 0)"
                return nutritionCell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
        
        
    }
    
    
    
}
