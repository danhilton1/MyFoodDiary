//
//  NewEntryViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase


class ManualEntryViewController: UITableViewController, UITextFieldDelegate {
    

    //MARK: - Properties and Objects
    
    let db = Firestore.firestore()
    let defaults = UserDefaults()
    
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    var date: Date?
    var selectedSegmentIndex = 0
    private let formatter = DateFormatter()

    private var workingCopy: Food = Food()
    
    // IBOutlets
    @IBOutlet weak var mealPicker: UISegmentedControl!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var servingSizeTextField: UITextField!
    @IBOutlet weak var servingSizeUnitButton: UIButton!
    @IBOutlet weak var servingTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var carbsTextField: UITextField!
    @IBOutlet weak var sugarTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    @IBOutlet weak var saturatedFatTextField: UITextField!
    @IBOutlet weak var fibreTextField: UITextField!
    
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var fibreLabel: UILabel!
    
    var activeTextField = UITextField()

    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)

        setUpTextFields()
        
        mealPicker.tintColor = Color.skyBlue
        mealPicker.selectedSegmentIndex = selectedSegmentIndex
        checkDeviceAndUpdateConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tableView.addGestureRecognizer(tapGesture)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
         
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presentingViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }

    func checkDeviceAndUpdateConstraints() {
        if UIScreen.main.bounds.height < 600 {
            mealLabel.font = mealLabel.font.withSize(16)
            nameLabel.font = nameLabel.font.withSize(16)
            servingSizeLabel.font = servingSizeLabel.font.withSize(16)
            servingLabel.font = servingLabel.font.withSize(16)
            caloriesLabel.font = caloriesLabel.font.withSize(16)
            proteinLabel.font = proteinLabel.font.withSize(16)
            carbsLabel.font = carbsLabel.font.withSize(16)
            fatLabel.font = fatLabel.font.withSize(16)
            sugarLabel.font = sugarLabel.font.withSize(12)
            saturatedFatLabel.font = saturatedFatLabel.font.withSize(12)
            fibreLabel.font = fibreLabel.font.withSize(16)
            
            mealPicker.setTitle("Bfast", forSegmentAt: 0)
        }
    }

    func setUpTextFields() {
        foodNameTextField.delegate = self
        caloriesTextField.delegate = self
        proteinTextField.delegate = self
        carbsTextField.delegate = self
        fatTextField.delegate = self
        sugarTextField.delegate = self
        saturatedFatTextField.delegate = self
        fibreTextField.delegate = self
        
        addInputAccessoryForTextFields(textFields: [foodNameTextField, servingSizeTextField, servingTextField, caloriesTextField, proteinTextField, carbsTextField, sugarTextField, fatTextField, saturatedFatTextField, fibreTextField], dismissable: true, previousNextable: true)
    }
    

    //MARK: - Nav Bar Button Methods
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        activeTextField.resignFirstResponder()
        
        // Check if user has filled in all of the required textfields.
        if foodNameTextField.text == "" || servingSizeTextField.text == "" ||
            servingTextField.text == "" || caloriesTextField.text == "" {
            
            let ac = UIAlertController(title: "Missing Information", message: "You must fill out all of the required fields.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] (action) in
                guard let strongSelf = self else { return }
                if strongSelf.foodNameTextField.text == "" {
                    strongSelf.foodNameTextField.becomeFirstResponder()
                }
                else if strongSelf.servingSizeTextField.text == "" {
                    strongSelf.servingSizeTextField.becomeFirstResponder()
                }
                else if strongSelf.servingTextField.text == "" {
                    strongSelf.servingTextField.becomeFirstResponder()
                }
                else if strongSelf.caloriesTextField.text == "" {
                    strongSelf.caloriesTextField.becomeFirstResponder()
                }
                })
            
            present(ac, animated: true)
            
            foodNameTextField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            servingSizeTextField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            servingTextField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            caloriesTextField.attributedPlaceholder = NSAttributedString(string: "Required", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            
        }
        else {
        
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
    
    
    private func addAndSaveNewEntry(meal: Food.Meal) {
        
        formatter.dateFormat = "E, d MMM"
    
        workingCopy.name = foodNameTextField.text
        workingCopy.meal = meal.stringValue
        workingCopy.date = formatter.string(from: date ?? Date())
        workingCopy.dateCreated = Date()
        workingCopy.dateLastEdited = Date()
        workingCopy.servingSize = (servingSizeTextField.text ?? "100")
        workingCopy.serving = Double(servingTextField.text ?? "1") ?? 1
        workingCopy.calories = Int(caloriesTextField.text ?? "0") ?? 0
        workingCopy.protein = Double(proteinTextField.text ?? "0") ?? 0
        workingCopy.carbs = Double(carbsTextField.text ?? "0") ?? 0
        workingCopy.fat = Double(fatTextField.text ?? "0") ?? 0
        workingCopy.sugar = Double(sugarTextField.text ?? "0") ?? 0
        workingCopy.saturatedFat = Double(saturatedFatTextField.text ?? "0") ?? 0
        workingCopy.fibre = Double(fibreTextField.text ?? "0") ?? 0
        
        guard let user = Auth.auth().currentUser?.uid else { return }
        workingCopy.saveFood(user: user)
        
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)!
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
            sugarTextField.becomeFirstResponder()
        }
        else if textField == sugarTextField {
            fatTextField.becomeFirstResponder()
        }
        else if textField == fatTextField {
            saturatedFatTextField.becomeFirstResponder()
        }
        else if textField == saturatedFatTextField {
            fibreTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
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
        sugarTextField.endEditing(true)
        saturatedFatTextField.endEditing(true)
        fibreTextField.endEditing(true)
        
    }
    
}

