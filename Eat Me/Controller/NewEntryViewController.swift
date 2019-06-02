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
    
    var breakfastFood = BreakfastFood()
    var lunchFood = LunchFood()
    var dinnerFood = DinnerFood()
    var otherFood = OtherFood()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

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
            
//            breakfastFood.name = foodNameTextField.text
//            breakfastFood.calories = caloriesTextField.text ?? "0"
//            breakfastFood.protein = proteinTextField.text ?? "0"
//            breakfastFood.carbs = carbsTextField.text ?? "0"
//            breakfastFood.fat = fatTextField.text ?? "0"
        case 1:
            lunchFood.name = foodNameTextField.text
            lunchFood.calories = caloriesTextField.text
            
            
            
            
        default:
            otherFood.name = foodNameTextField.text
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func save(food: BreakfastFood) {
        
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
        
        
    }
    
}
