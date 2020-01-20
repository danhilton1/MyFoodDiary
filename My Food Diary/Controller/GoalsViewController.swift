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
        let weightUnit = defaults.value(forKey: UserDefaultsKeys.goalWeightUnit) as? String
        weightUnitButton.setTitle(weightUnit ?? "kg", for: .normal)
        updateGoalsButton.setTitleColor(.white, for: .normal)
        updateGoalsButton.backgroundColor = Color.skyBlue
        updateGoalsButton.layer.cornerRadius = 25
        let footerView = UIView()
        footerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 800)
        footerView.backgroundColor = tableView.separatorColor
        tableView.tableFooterView = footerView
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
        defaults.set(Int(caloriesGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalCalories)
        defaults.set(proteinGoalTextField.text, forKey: UserDefaultsKeys.goalProtein)
        defaults.set(carbsGoalTextField.text, forKey: UserDefaultsKeys.goalCarbs)
        defaults.set(fatGoalTextField.text, forKey: UserDefaultsKeys.goalFat)
        defaults.set(Double(weightGoalTextField.text ?? "0"), forKey: UserDefaultsKeys.goalWeight)
        defaults.set(weightUnitButton.title(for: .normal), forKey: UserDefaultsKeys.goalWeightUnit)
        
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.navigationController?.popViewController(animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
}

//MARK:- Extension for table view methods

extension GoalsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return 120
        }
        else {
            return 45
        }
    }
    
    
    
}
