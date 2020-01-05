//
//  NewEntryViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

protocol NewEntryDelegate: class {
    func reloadFood(entry: Food?, new: Bool)
}



class ManualEntryViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    let db = Firestore.firestore()
    
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    var date: Date?
    var selectedSegmentIndex = 0
    private var activeField: UITextField?
    private let formatter = DateFormatter()

    private var workingCopy: Food = Food()

    //MARK: - Properties and Objects
    
    @IBOutlet weak var mealPicker: UISegmentedControl!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var servingSizeTextField: UITextField!
    
    @IBOutlet weak var servingSizeUnitButton: UIButton!
    @IBOutlet weak var servingTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var carbsTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    


    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)

        mealPicker.tintColor = Color.skyBlue
        mealPicker.selectedSegmentIndex = selectedSegmentIndex
        
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
        super.viewWillAppear(true)
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
        delegate?.reloadFood(entry: workingCopy, new: true)
        mealDelegate?.reloadFood(entry: workingCopy, new: true)
    }
    
    @IBAction func unitButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Serving Size Unit", message: nil, preferredStyle: .actionSheet)
        
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
            customAC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            customAC.addAction(UIAlertAction(title: "Enter", style: .default) { (action) in
                strongSelf.servingSizeUnitButton.setTitle(customAC.textFields?.first?.text, for: .normal)
                strongSelf.workingCopy.servingSizeUnit = customAC.textFields?.first?.text ?? "g"
                })
            strongSelf.present(customAC, animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    
    
    //MARK: - New Entry Add and Save methods
    
    func save(_ food: Food) {
        
//        let user = Auth.auth().currentUser?.email
//
//        let fc = FoodsCollection.self
//
//        db.collection("users").document(user!).collection(fc.collection).document(food.name!).setData([
//            fc.name: food.name ?? "N/A",
//            fc.meal: food.meal ?? Food.Meal.other,
//            fc.date: food.date!,
//            fc.dateValue: food.dateValue ?? Date(),
//            fc.servingSize: food.servingSize,
//            fc.serving: food.serving,
//            fc.calories: food.calories,
//            fc.protein: food.protein,
//            fc.carbs: food.carbs,
//            fc.fat: food.fat,
//            fc.isDeleted: false
//        ]) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document added with ID: \(food.name!)")
//            }
//        }
        
//        do {
//            try realm.write {
//                realm.add(food)
//            }
//        } catch {
//            print(error)
//        }
    }
    
    private func addAndSaveNewEntry(meal: Food.Meal) {
        
        formatter.dateFormat = "E, d MMM"
    
        workingCopy.name = foodNameTextField.text
        workingCopy.meal = meal.stringValue
        workingCopy.date = formatter.string(from: date ?? Date())
        workingCopy.dateValue = date
        workingCopy.dateLastEdited = date
        workingCopy.servingSize = (servingSizeTextField.text ?? "100")
        workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
        workingCopy.calories = Int(caloriesTextField.text ?? "0") ?? 0
        workingCopy.protein = Double(proteinTextField.text ?? "0") ?? 0
        workingCopy.carbs = Double(carbsTextField.text ?? "0") ?? 0
        workingCopy.fat = Double(fatTextField.text ?? "0") ?? 0
        
        let user = Auth.auth().currentUser?.email ?? Auth.auth().currentUser!.uid
        workingCopy.saveFood(user: user)
        //save(workingCopy)
        
        
    }
    
    func dismissViewWithAnimation() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: {
            self.delegate?.reloadFood(entry: nil, new: true)
        })
        
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == foodNameTextField) {
                let oldString = textField.text!
                let newStart = oldString.index(oldString.startIndex, offsetBy: range.location)
                let newEnd = oldString.index(oldString.startIndex, offsetBy: range.location + range.length)
                let newString = oldString.replacingCharacters(in: newStart..<newEnd, with: string)
                textField.text = newString.replacingOccurrences(of: " ", with: "\u{00a0}")
                return false;
            } else {
                return true;
            }
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
