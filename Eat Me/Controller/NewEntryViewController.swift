//
//  NewEntryViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class NewEntryViewController: UITableViewController {
    
    let realm = try! Realm()
    

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

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
//     
        
      
//    }
 
    @IBAction func mealPickerPressed(_ sender: Any) {
//        print(mealPicker.titleForSegment(at: mealPicker.selectedSegmentIndex))
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        switch mealPicker.selectedSegmentIndex {
        case 0:
            
            let newBreakfastFood = BreakfastFood()
            
            newBreakfastFood.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!)!), protein: NSNumber(value: Double(proteinTextField.text!)!), carbs: NSNumber(value: Double(carbsTextField.text!)!), fat: NSNumber(value: Double(fatTextField.text!)!))
            
            save(food: newBreakfastFood)
            
        case 1:
            
            let newLunchFood = LunchFood()
            
            newLunchFood.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!)!), protein: NSNumber(value: Double(proteinTextField.text!)!), carbs: NSNumber(value: Double(carbsTextField.text!)!), fat: NSNumber(value: Double(fatTextField.text!)!))
            
            save(food: newLunchFood)
            
        case 2:
            
            let newDinnerFood = DinnerFood()
            
            newDinnerFood.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!)!), protein: NSNumber(value: Double(proteinTextField.text!)!), carbs: NSNumber(value: Double(carbsTextField.text!)!), fat: NSNumber(value: Double(fatTextField.text!)!))
            
            save(food: newDinnerFood)
            
        case 3:
            
            let newOtherFood = OtherFood()
            
            newOtherFood.updateProperties(name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!)!), protein: NSNumber(value: Double(proteinTextField.text!)!), carbs: NSNumber(value: Double(carbsTextField.text!)!), fat: NSNumber(value: Double(fatTextField.text!)!))
            
            save(food: newOtherFood)
            
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
    
}
