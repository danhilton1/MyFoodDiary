//
//  GoalsViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 19/01/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//
import Foundation
import UIKit
import SVProgressHUD

class GoalsViewController: UITableViewController, UITextFieldDelegate {

    //MARK:- Outlets
    
    @IBOutlet weak var caloriesTextLabel: UILabel!
    @IBOutlet weak var proteinTextLabel: UILabel!
    @IBOutlet weak var carbsTextLabel: UILabel!
    @IBOutlet weak var fatTextLabel: UILabel!
    @IBOutlet weak var weightTextLabel: UILabel!
    
    
    @IBOutlet weak var caloriesGoalTextField: UITextField!
    @IBOutlet weak var proteinGoalTextField: UITextField!
    @IBOutlet weak var carbsGoalTextField: UITextField!
    @IBOutlet weak var fatGoalTextField: UITextField!
    @IBOutlet weak var weightGoalTextField: UITextField!
    @IBOutlet weak var weightUnitButton: UIButton!
    @IBOutlet weak var updateGoalsButton: UIButton!
    
    @IBOutlet weak var updateGoalsButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var updateButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var updateButtonBottomConstraint: NSLayoutConstraint!
    
    
    //MARK:- Properties
    let defaults = UserDefaults()
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        checkDeviceAndUpdateLayoutIfNeeded()
        
        tableView.allowsSelection = false
        
        caloriesGoalTextField.delegate = self
        proteinGoalTextField.delegate = self
        carbsGoalTextField.delegate = self
        fatGoalTextField.delegate = self
        weightGoalTextField.delegate = self
        
        addInputAccessoryForTextFields(textFields: [caloriesGoalTextField, proteinGoalTextField, carbsGoalTextField, fatGoalTextField, weightGoalTextField], dismissable: true, previousNextable: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
        setUpViews()
    }
    
    func setUpViews() {
        
        caloriesGoalTextField.text = "\(defaults.value(forKey: UserDefaultsKeys.goalCalories) as? Int ?? 0)"
        proteinGoalTextField.text = defaults.value(forKey: UserDefaultsKeys.goalProtein) as? String
        carbsGoalTextField.text = defaults.value(forKey: UserDefaultsKeys.goalCarbs) as? String
        fatGoalTextField.text = defaults.value(forKey: UserDefaultsKeys.goalFat) as? String
        var goalWeight = defaults.value(forKey: UserDefaultsKeys.goalWeight) as? Double ?? 0
        weightGoalTextField.text = goalWeight.removePointZeroEndingAndConvertToString()
        let weightUnit = defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String
        weightUnitButton.setTitle(weightUnit ?? "kg", for: .normal)
        updateGoalsButton.setTitleColor(.white, for: .normal)
        updateGoalsButton.backgroundColor = Color.skyBlue
        updateGoalsButton.layer.cornerRadius = 25
        if UIScreen.main.bounds.height < 600 {
            updateGoalsButton.layer.cornerRadius = 20
        }
        tableView.tableFooterView = UIView()
    }
    
    func checkDeviceAndUpdateLayoutIfNeeded() {
        if UIScreen.main.bounds.height < 600 {
            caloriesTextLabel.font = caloriesTextLabel.font.withSize(15)
            proteinTextLabel.font = proteinTextLabel.font.withSize(15)
            carbsTextLabel.font = carbsTextLabel.font.withSize(15)
            fatTextLabel.font = fatTextLabel.font.withSize(15)
            weightTextLabel.font = weightTextLabel.font.withSize(15)
            
            caloriesGoalTextField.font = caloriesGoalTextField.font?.withSize(15)
            proteinGoalTextField.font = proteinGoalTextField.font?.withSize(15)
            carbsGoalTextField.font = carbsGoalTextField.font?.withSize(15)
            fatGoalTextField.font = fatGoalTextField.font?.withSize(15)
            weightGoalTextField.font = weightGoalTextField.font?.withSize(15)
            
            updateGoalsButton.titleLabel?.font = updateGoalsButton.titleLabel?.font.withSize(19)
            updateGoalsButtonWidthConstraint.constant = 150
            updateButtonTopConstraint.constant = 20
            updateButtonBottomConstraint.constant = 20
            
        }
    }

    //MARK:- Button Methods
    
    @IBAction func weightUnitButtonTapped(_ sender: UIButton) {
        let ac = UIAlertController(title: "Please select your unit of weight.", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "kg", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.weightUnitButton.setTitle("kg", for: .normal)
        })
        ac.addAction(UIAlertAction(title: "lbs", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.weightUnitButton.setTitle("lbs", for: .normal)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func updateGoalsTapped(_ sender: UIButton) {
        SVProgressHUD.show()
        
        defaults.set(Int(caloriesGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalCalories)
        defaults.set(Double(proteinGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalProtein)
        defaults.set(Double(carbsGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalCarbs)
        defaults.set(Double(fatGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalFat)
        defaults.set(Double(weightGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalWeight)
        defaults.set(weightUnitButton.title(for: .normal), forKey: UserDefaultsKeys.weightUnit)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SVProgressHUD.setMinimumDismissTimeInterval(0.9)
            SVProgressHUD.showSuccess(withStatus: "Goals Updated")
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

//MARK:- Extension for table view methods

extension GoalsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            if UIScreen.main.bounds.height < 600 {
                return 80
            }
            else {
                return 120
            }
        }
        else {
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UIScreen.main.bounds.height < 600 {
            return 25
        }
        else {
            return 28
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        if UIScreen.main.bounds.height < 600 {
            header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 15)!
        }
        else {
            header.textLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 17)!
        }
    }
    
    
    
    
}
