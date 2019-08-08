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
    func reloadFood()
}

class NewEntryViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    weak var delegate: NewEntryDelegate?
    var date: Date?

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
        
        navigationController?.setNavigationBarHidden(false, animated: true)

        mealPicker.tintColor = UIColor.flatSkyBlue()
        
        foodNameTextField.delegate = self
        caloriesTextField.delegate = self
        proteinTextField.delegate = self
        carbsTextField.delegate = self
        fatTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tableView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Table view data source methods


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }

    //MARK: - Nav Bar Button Methods
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        animateDismiss()
        
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        switch mealPicker.selectedSegmentIndex {
            
        case 0:
            
            let newBreakfastFood = Food()
            addAndSaveNewEntry(newFood: newBreakfastFood, meal: .breakfast)
            
        case 1:
            
            let newLunchFood = Food()
            addAndSaveNewEntry(newFood: newLunchFood, meal: .lunch)
            
        case 2:
            
            let newDinnerFood = Food()
            addAndSaveNewEntry(newFood: newDinnerFood, meal: .dinner)
            
        case 3:
            
            let newOtherFood = Food()
            addAndSaveNewEntry(newFood: newOtherFood, meal: .other)
            
        default:
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        animateDismiss()

        delegate?.reloadFood()
    }
        
    //MARK: - New Entry Add and Save methods
    
    func save(food: Object) {
        
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    private func addAndSaveNewEntry(newFood: Food?, meal: Food.Meal) {
        
        if let newFoodEntry = newFood
        {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM"
            
            newFoodEntry.updateProperties(date: formatter.string(from: date ?? Date()), meal: meal, name: foodNameTextField.text, calories: NSNumber(value: Int(caloriesTextField.text!) ?? 0), protein: NSNumber(value: Double(proteinTextField.text!) ?? 0), carbs: NSNumber(value: Double(carbsTextField.text!) ?? 0), fat: NSNumber(value: Double(fatTextField.text!) ?? 0))
            
            save(food: newFoodEntry)
        }
        
        
    }
    
    func animateDismiss() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == foodNameTextField { // Switch focus to other text field
            caloriesTextField.becomeFirstResponder()
        }
        else if textField == caloriesTextField {
            proteinTextField.becomeFirstResponder()
        }
        else if textField == proteinTextField {
            carbsTextField.becomeFirstResponder()
        }
        else {
            fatTextField.becomeFirstResponder()
        }
        return true
    }
    
    @objc func tableViewTapped() {
        
        foodNameTextField.endEditing(true)
        caloriesTextField.endEditing(true)
        proteinTextField.endEditing(true)
        carbsTextField.endEditing(true)
        fatTextField.endEditing(true)
        
    }
    
}
