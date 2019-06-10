//
//  NewEntryViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewEntryDelegate: class {
    func getCalorieDataFromNewEntry(data: Int)
}

class NewEntryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    weak var delegate: NewEntryDelegate?
    

    //MARK: - Properties and Objects
    
    @IBOutlet weak var mealPicker: UISegmentedControl!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var carbsTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        switch mealPicker.selectedSegmentIndex {
        case 0:
            
            let newBreakfastFood = BreakfastFood()
            addAndSaveNewEntry(meal1: newBreakfastFood, meal2: nil, meal3: nil, meal4: nil)
            
        case 1:
            
            let newLunchFood = LunchFood()
            addAndSaveNewEntry(meal1: nil, meal2: newLunchFood, meal3: nil, meal4: nil)
            
        case 2:
            
            let newDinnerFood = DinnerFood()
            addAndSaveNewEntry(meal1: nil, meal2: nil, meal3: newDinnerFood, meal4: nil)
            
        case 3:
            
            let newOtherFood = OtherFood()
            addAndSaveNewEntry(meal1: nil, meal2: nil, meal3: nil, meal4: newOtherFood)
            
        default:
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    func addAndSaveNewEntry(meal1: BreakfastFood?, meal2: LunchFood?, meal3: DinnerFood?, meal4: OtherFood?) {
        
        if let breakfastEntry = meal1 {
            
            breakfastEntry.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!) ?? 0), protein: NSNumber(value: Double(proteinTextField.text!) ?? 0), carbs: NSNumber(value: Double(carbsTextField.text!) ?? 0), fat: NSNumber(value: Double(fatTextField.text!) ?? 0))
            
            
            if let newEntryCalories = caloriesTextField.text {
                delegate?.getCalorieDataFromNewEntry(data: Int(newEntryCalories) ?? 0)
            }
            
            
            save(food: breakfastEntry)
            
        }
        
        if let lunchEntry = meal2 {
    
            lunchEntry.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!) ?? 0), protein: NSNumber(value: Double(proteinTextField.text!) ?? 0), carbs: NSNumber(value: Double(carbsTextField.text!) ?? 0), fat: NSNumber(value: Double(fatTextField.text!) ?? 0))
            
            if let newEntryCalories = caloriesTextField.text {
                delegate?.getCalorieDataFromNewEntry(data: Int(newEntryCalories) ?? 0)
            }
            
            save(food: lunchEntry)
            
        }
        
        if let dinnerEntry = meal3 {
            
            dinnerEntry.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!) ?? 0), protein: NSNumber(value: Double(proteinTextField.text!) ?? 0), carbs: NSNumber(value: Double(carbsTextField.text!) ?? 0), fat: NSNumber(value: Double(fatTextField.text!) ?? 0))
            
            if let newEntryCalories = caloriesTextField.text {
                delegate?.getCalorieDataFromNewEntry(data: Int(newEntryCalories) ?? 0)
            }
            
            save(food: dinnerEntry)
            
        }
        
        if let otherFoodEntry = meal4 {
        
            otherFoodEntry.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!) ?? 0), protein: NSNumber(value: Double(proteinTextField.text!) ?? 0), carbs: NSNumber(value: Double(carbsTextField.text!) ?? 0), fat: NSNumber(value: Double(fatTextField.text!) ?? 0))
            
            if let newEntryCalories = caloriesTextField.text {
                delegate?.getCalorieDataFromNewEntry(data: Int(newEntryCalories) ?? 0)
            }
            
            save(food: otherFoodEntry)
        }
    }
    
}
