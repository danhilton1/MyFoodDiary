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
    
    weak var delegate: NewEntryDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MealPickerCell", bundle: nil), forCellReuseIdentifier: "MealPickerCell")
        tableView.register(UINib(nibName: "FoodNameCell", bundle: nil), forCellReuseIdentifier: "FoodNameCell")
        tableView.register(UINib(nibName: "ServingSizeCell", bundle: nil), forCellReuseIdentifier: "ServingSizeCell")
        tableView.register(UINib(nibName: "ServingCell", bundle: nil), forCellReuseIdentifier: "ServingCell")
        tableView.register(UINib(nibName: "NutritionCell", bundle: nil), forCellReuseIdentifier: "NutritionCell")
        
        navigationController?.navigationBar.tintColor = .white

    }

    // MARK: - Table view data source

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
//        let label = UILabel()
//        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
//        label.textColor = UIColor.black
//        label.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        
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
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        let newFoodEntry = Food()
        let servingCell = tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! ServingCell
        let mealPickerCell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! MealPickerCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        
        newFoodEntry.updateProperties(
            date: formatter.string(from: date ?? Date()),
            meal: .breakfast,
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
    
    
    
    func save(food: Object) {
        
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    func dismissViewWithAnimation() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }

}
