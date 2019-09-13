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

    private var workingCopy: Food = Food()

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
        
        addInputAccessoryForTextFields(textFields: [foodNameTextField,servingSizeTextField,servingTextField,caloriesTextField,proteinTextField,carbsTextField,fatTextField], dismissable: true, previousNextable: true)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        presentingViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }


    //MARK: - Nav Bar Button Methods
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismissViewWithAnimation()
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        switch mealPicker.selectedSegmentIndex {
            
        case 0:
            addAndSaveNewEntry(meal: .breakfast)
        case 1:
            addAndSaveNewEntry(meal: .lunch)
        case 2:
            addAndSaveNewEntry(meal: .dinner)
        case 3:
            addAndSaveNewEntry(meal: .other)
        default:
            dismissViewWithAnimation()
        }
        
        dismissViewWithAnimation()
        delegate?.reloadFood()
    }
    
    
    //MARK: - New Entry Add and Save methods
    
    func save(_ food: Object) {
        
        do {
            try realm.write {
                realm.add(food)
            }
        } catch {
            print(error)
        }
    }
    
    private func addAndSaveNewEntry(meal: Food.Meal) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
    
        workingCopy.name = foodNameTextField.text
        workingCopy.meal = meal.stringValue
        workingCopy.date = formatter.string(from: date ?? Date())
        workingCopy.servingSize = servingSizeTextField.text ?? "100g"
        workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
        workingCopy.calories = Int(caloriesTextField.text ?? "0") ?? 0
        workingCopy.protein = Double(proteinTextField.text ?? "0") ?? 0
        workingCopy.carbs = Double(carbsTextField.text ?? "0") ?? 0
        workingCopy.fat = Double(fatTextField.text ?? "0") ?? 0
        
        save(workingCopy)
        
        
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


//Extension to add a toolbar to the top of each textfield
extension UIViewController {
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                let previousButton = UIBarButtonItem(image: UIImage(named: "UpArrow"), style: .plain, target: nil, action: nil)
                previousButton.width = 20
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(named: "DownArrow"), style: .plain, target: nil, action: nil)
                nextButton.width = 20
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
}
