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
    @IBOutlet weak var servingSizeTextField: UITextField!
    @IBOutlet weak var servingTextField: UITextField!
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
        
        tableView.keyboardDismissMode = .interactive
        
    }

    // MARK: - Table view data source methods


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (tableView.frame.height) / 12
        
    }

    //MARK: - Nav Bar Button Methods
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        dismissViewWithAnimation()
        
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
        
        dismissViewWithAnimation()

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
            
            newFoodEntry.updateProperties(
                date: formatter.string(from: date ?? Date()),
                meal: meal,
                name: foodNameTextField.text,
                servingSize: servingSizeTextField.text ?? "100g",
                serving: Double(servingTextField.text!) ?? 1,
                calories: NSNumber(value: Int(caloriesTextField.text!) ?? 0),
                protein: NSNumber(value: Double(proteinTextField.text!) ?? 0),
                carbs: NSNumber(value: Double(carbsTextField.text!) ?? 0),
                fat: NSNumber(value: Double(fatTextField.text!) ?? 0)
                )
            
            save(food: newFoodEntry)
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
    
    
    //MARK:- TextFieldDelegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == foodNameTextField { // Switch focus to other text field
            servingSizeTextField.becomeFirstResponder()
        }
        else if textField == servingSizeTextField {
            servingTextField.becomeFirstResponder()
        }
        else if textField == servingTextField {
            caloriesTextField.becomeFirstResponder()
        }
        else if textField == caloriesTextField {
            proteinTextField.becomeFirstResponder()
        }
        else if textField == proteinTextField {
            carbsTextField.becomeFirstResponder()
        }
        else if textField == carbsTextField {
            fatTextField.becomeFirstResponder()
        }
        return true
    }
    
    @objc func tableViewTapped() {
        
        foodNameTextField.endEditing(true)
        servingSizeTextField.endEditing(true)
        servingTextField.endEditing(true)
        caloriesTextField.endEditing(true)
        proteinTextField.endEditing(true)
        carbsTextField.endEditing(true)
        fatTextField.endEditing(true)
        
    }
    
}
