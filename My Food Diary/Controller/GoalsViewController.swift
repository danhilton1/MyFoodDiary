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

class GoalsViewController: UITableViewController {

    //MARK:- Outlets
    @IBOutlet weak var caloriesGoalTextField: UITextField!
    @IBOutlet weak var proteinGoalTextField: UITextField!
    @IBOutlet weak var carbsGoalTextField: UITextField!
    @IBOutlet weak var fatGoalTextField: UITextField!
    @IBOutlet weak var weightGoalTextField: UITextField!
    @IBOutlet weak var weightUnitButton: UIButton!
    @IBOutlet weak var updateGoalsButton: UIButton!
    
    //MARK:- Properties
    let defaults = UserDefaults()
    
    
    
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        
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
        updateGoalsButton.setTitleColor(.white, for: .normal)
        updateGoalsButton.backgroundColor = Color.skyBlue
        updateGoalsButton.layer.cornerRadius = 25
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 800)
        footerView.backgroundColor = tableView.separatorColor
        tableView.tableFooterView = footerView
    }

    @IBAction func weightUnitButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func updateGoalsTapped(_ sender: UIButton) {
        defaults.set(Int(caloriesGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalCalories)
        defaults.set(proteinGoalTextField.text, forKey: UserDefaultsKeys.goalProtein)
        defaults.set(carbsGoalTextField.text, forKey: UserDefaultsKeys.goalCarbs)
        defaults.set(fatGoalTextField.text, forKey: UserDefaultsKeys.goalFat)
        defaults.set(Double(weightGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalWeight)
        
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigationController?.popViewController(animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
}

extension GoalsViewController: UITextFieldDelegate {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return 120
        }
        else {
            return 45
        }
    }
    
    
    
}
