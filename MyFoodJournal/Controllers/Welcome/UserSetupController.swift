//
//  UserSetupController.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 02/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//
import Foundation
import UIKit
import SVProgressHUD


class UserSetupController: UITableViewController, UITextFieldDelegate {
    
    //MARK:- Properties
    
    var user = Person(gender: "Male", age: 0, height: 0, heightUnit: .ft, weight: 0, goalWeight: 0, weightUnit: .kg, activityLevel: 1, activityMultiplier: 0.0)
    var TDEE = 0.0
    var userHeight = 0.0
    var userHeightFeet: Int?
    var userHeightInches: Int?
    var userWeight = 0.0
    var isEditingExistingInfo: Bool = false
    
    private let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    var activeTextField: UITextField!
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderSegments: UISegmentedControl!
    @IBOutlet weak var tickButton: UIButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var agetextField: UITextField!
    @IBOutlet weak var yearsOldLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var heighUnitSegments: UISegmentedControl!
    @IBOutlet weak var ftAndInchesStackView: UIStackView!
    @IBOutlet weak var ftTextField: UITextField!
    @IBOutlet weak var inchesTextField: UITextField!
    @IBOutlet weak var cmStackView: UIStackView!
    @IBOutlet weak var cmTextField: UITextField!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightUnitSegments: UISegmentedControl!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityInfoButton: UIButton!
    @IBOutlet weak var activitySegment: UISegmentedControl!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var genderLabelTopConstraint: NSLayoutConstraint!
    
    //MARK:- View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpTextFields()
        if !isEditingExistingInfo {
            presentAlert()
        }
        
    }

    func setUpViews() {
        
        let footerView = UIView()
        footerView.backgroundColor = Color.skyBlue
        tableView.tableFooterView = footerView
        tableView.separatorStyle = .none
        tableView.backgroundColor = Color.skyBlue
        tableView.allowsSelection = false
        
        cancelButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
        cancelButton.imageView?.clipsToBounds = false
        cancelButton.imageView?.contentMode = .center
        calculateButton.layer.cornerRadius = 22
        calculateButton.setTitleColor(Color.skyBlue, for: .normal)
        
        if isEditingExistingInfo {
            genderLabelTopConstraint.constant = 20
            tickButton.isHidden = true
        }
        
        self.toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(revealNextView))
        ]
        self.toolbar.sizeToFit()
        agetextField.inputAccessoryView = toolbar
        inchesTextField.inputAccessoryView = toolbar
        cmTextField.inputAccessoryView = toolbar
        weightTextField.inputAccessoryView = toolbar
        
        checkForExistingUserValuesAndSetViews()
        
    }
    
    func setUpTextFields() {
        agetextField.delegate = self
        ftTextField.delegate = self
        inchesTextField.delegate = self
        cmTextField.delegate = self
        weightTextField.delegate = self
        
        ftTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        inchesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    func checkForExistingUserValuesAndSetViews() {
        
        let defaults = UserDefaults() // Check if user information already exists and display the values if so
        if let gender = defaults.value(forKey: UserDefaultsKeys.gender) as? String,
            let age = defaults.value(forKey: UserDefaultsKeys.age) as? Int,
            let heightUnit = defaults.value(forKey: UserDefaultsKeys.heightUnit) as? String,
            let height = defaults.value(forKey: UserDefaultsKeys.height) as? Double,
            let weightUnit = defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String,
            let weight = defaults.value(forKey: UserDefaultsKeys.weight) as? Double,
            let activityLevel = defaults.value(forKey: UserDefaultsKeys.activityLevel) as? Int
            {
            
            if gender == "Male" {
                genderSegments.selectedSegmentIndex = 0
            }
            else {
                genderSegments.selectedSegmentIndex = 1
            }
            
            agetextField.text = "\(age)"
            
            if heightUnit == "ft" {
                heighUnitSegments.selectedSegmentIndex = 0
                cmStackView.alpha = 0
                ftTextField.text = "\(defaults.value(forKey: UserDefaultsKeys.heightFeet) as? Int ?? 0)"
                inchesTextField.text = "\(defaults.value(forKey: UserDefaultsKeys.heightInches) as? Int ?? 0)"
            }
            else {
               heighUnitSegments.selectedSegmentIndex = 1
                ftAndInchesStackView.alpha = 0
                var height = height
                cmTextField.text = height.removePointZeroEndingAndConvertToString()
            }
            
            if weightUnit == "kg" {
                weightUnitSegments.selectedSegmentIndex = 0
            }
            else if weightUnit == "lbs" {
                weightUnitSegments.selectedSegmentIndex = 1
            }
            else {
                weightUnitSegments.selectedSegmentIndex = 2
            }
            
            weightTextField.text = "\(weight)"
            
            activitySegment.selectedSegmentIndex = activityLevel - 1
        }
        else {
            genderLabel.alpha = 0
            genderSegments.alpha = 0
            tickButton.alpha = 0
            ageLabel.alpha = 0
            agetextField.alpha = 0
            yearsOldLabel.alpha = 0
            heightLabel.alpha = 0
            heighUnitSegments.alpha = 0
            ftAndInchesStackView.alpha = 0
            cmStackView.alpha = 0
            weightLabel.alpha = 0
            weightUnitSegments.alpha = 0
            weightTextField.alpha = 0
            activityLabel.alpha = 0
            activityInfoButton.alpha = 0
            activitySegment.alpha = 0
            calculateButton.alpha = 0
        }
    }
    
    func presentAlert() {
        let ac = UIAlertController(title: "User Setup", message: "To help you achieve your goals we can offer you our personalised recommended targets for nutrition. We just need a few pieces of basic information about you.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) in
            UIView.animate(withDuration: 0.5) {
                self.genderLabel.alpha = 1
                self.genderSegments.alpha = 1
                self.tickButton.alpha = 1
                self.cancelButton.alpha = 1
            }
        })
        ac.addAction(UIAlertAction(title: "No thanks", style: .destructive) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: nil)
        })
        present(ac, animated: true)
    }

    //MARK:- Button Methods
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        if isEditingExistingInfo {
            navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
            let ac = UIAlertController(title: "Exit", message: "You can set up your goals anytime on the 'Goals' page under the 'More' tab.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
                self.performSegue(withIdentifier: "GoToTabBar", sender: nil)
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(ac, animated: true)
        }
    }
    
    @IBAction func tickButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.ageLabel.alpha = 1
            self.agetextField.alpha = 0.5
            self.yearsOldLabel.alpha = 1
        }
        agetextField.becomeFirstResponder()
    }
    
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        setUserProperties()
        calculateTDEE()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performSegue(withIdentifier: "GoToCalculatedGoals", sender: nil)
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func heightSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            cmStackView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.cmStackView.alpha = 1
                self.ftAndInchesStackView.alpha = 0
                self.ftAndInchesStackView.isHidden = true
            }
        }
        else {
            ftAndInchesStackView.isHidden = false
            UIView.animate(withDuration: 0.5) {
                self.ftAndInchesStackView.alpha = 1
                self.cmStackView.alpha = 0
                self.cmStackView.isHidden = true
            }
        }
    }
    
    @IBAction func activityInfoButtonTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Activity Levels", message: "", preferredStyle: .alert)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let messageFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let messageAttrString = NSMutableAttributedString(string: "\n1: Sedentary - little to no exercise + spend most of day sitting.\n\n2: Lightly Active - light exercise 1-3 days / week.\n\n3: Moderately Active - moderate exercise 3-5 days / week. \n\n4: Very Active - heavy exercise 6-7 days / week.\n\n5: Extremely Active - very heavy exercise + hard labor job", attributes: messageFont)

        ac.setValue(messageAttrString, forKey: "attributedMessage")
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        present(ac, animated: true)
    }
    
    // TextField toolbar button method to reveal and move on to the next view
    @objc func revealNextView() {
        
        switch activeTextField {
            
        case agetextField:
            
            if agetextField.text == "" {
                agetextField.attributedPlaceholder = NSAttributedString(string: "Req.", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            }
            else {
                
                agetextField.resignFirstResponder()
                UIView.animate(withDuration: 0.5) {
                    self.heightLabel.alpha = 1
                    self.heighUnitSegments.alpha = 1
                    self.ftAndInchesStackView.alpha = 1
                }
                ftTextField.becomeFirstResponder()
            }
        case inchesTextField:
            
            if ftTextField.text == "" {
                ftTextField.attributedPlaceholder = NSAttributedString(string: "Req.", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            }
            else {
                inchesTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.5) {
                    self.weightLabel.alpha = 1
                    self.weightUnitSegments.alpha = 1
                    self.weightTextField.alpha = 0.5
                }
                weightTextField.becomeFirstResponder()
            }
        case cmTextField:
            
            if cmTextField.text == "" {
                cmTextField.attributedPlaceholder = NSAttributedString(string: "Req.", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            }
            else {
                cmTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.5) {
                    self.weightLabel.alpha = 1
                    self.weightUnitSegments.alpha = 1
                    self.weightTextField.alpha = 0.5
                }
            }
        default:
            
            if weightTextField.text == "" {
                weightTextField.attributedPlaceholder = NSAttributedString(string: "Req.", attributes: [NSAttributedString.Key.foregroundColor: Color.salmon])
            }
            else {
                weightTextField.resignFirstResponder()
                UIView.animate(withDuration: 0.5) {
                    self.activityLabel.alpha = 1
                    self.activityInfoButton.alpha = 1
                    self.activitySegment.alpha = 1
                    self.calculateButton.alpha = 1
                }
            }
        }
        
    }
    
    //MARK:- Calculate and set values
    
    // Sets the user-entered values from textfields to keys in user defaults
    func setUserProperties() {
        guard let gender = genderSegments.titleForSegment(at: genderSegments.selectedSegmentIndex) else { return }
        user.gender = gender
        guard let age = Int(agetextField.text!) else { return }
        user.age = age
        if heighUnitSegments.selectedSegmentIndex == 0 {
            guard let feet = Double(ftTextField.text!) else { return }
            let inches = Double(inchesTextField.text ?? "0") ?? 0.0
            user.heightUnit = .ft
            user.heightFeet = Int(feet)
            user.heightInches = Int(inches)
            let heightInInches = (feet * 12) + inches
            let height = heightInInches * 2.54
            user.height = height
        }
        else {
            guard let height = Double(cmTextField.text!) else { return }
            user.heightUnit = .cm
            user.height = height
        }
        
        guard let weight = Double(weightTextField.text!) else { return }
        if weightUnitSegments.selectedSegmentIndex == 0 {
            user.weight = weight
            user.weightUnit = .kg
        }
        else if weightUnitSegments.selectedSegmentIndex == 1 {
            user.weight = weight / 2.205
            user.weightUnit = .lbs
        }
        else {
            user.weight = weight * 6.35
            user.weightUnit = .st
        }
        
        switch activitySegment.selectedSegmentIndex {
        case 0:
            user.activityLevel = 1
            user.activityMultiplier = 1.2
        case 1:
            user.activityLevel = 2
            user.activityMultiplier = 1.375
        case 2:
            user.activityLevel = 3
            user.activityMultiplier = 1.55
        case 3:
            user.activityLevel = 4
            user.activityMultiplier = 1.725
        default:
            user.activityLevel = 5
            user.activityMultiplier = 1.9
        }
    }
    
    // Calculates the user's TDEE calories based on the information they provided
    func calculateTDEE() {
        if user.gender == "Male" {
            let a = 66 + (13.7 * user.weight)
            let b = 5 * user.height
            let c = 6.8 * Double(user.age)
            TDEE = ((a + b) - c) * user.activityMultiplier
        }
        else {
            let a = 655 + (9.6 * user.weight)
            let b = 1.8 * user.height
            let c = 4.7 * Double(user.age)
            TDEE = ((a + b) - c) * user.activityMultiplier
        }
    }
    
    //MARK:- Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToCalculatedGoals" {
            let destVC = segue.destination as! CalculatedGoalsViewController
            destVC.user = user
            destVC.TDEE = TDEE
            destVC.isEditingExistingInfo = isEditingExistingInfo
        }
    }


}

//MARK:- Extension for tableView and textField methods

extension UserSetupController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.skyBlue
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if isEditingExistingInfo {
                return 115
            }
            return 140
        }
        else if indexPath.row == 1 {
            return 100
        }
        else if indexPath.row == 5 {
            return 120
        }
        else {
            return 150
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == ftTextField {
            if let text = textField.text {
                if text.count > 0 {
                    inchesTextField.becomeFirstResponder()
                }
            }
        }
        else if textField == inchesTextField {
            if let text = textField.text {
                if text.count > 1 {
                    revealNextView()
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.contains("."))! && string.contains(".") {
            return false
        }
        else {
            return true
        }
    }
    
    
    
    
    
}
