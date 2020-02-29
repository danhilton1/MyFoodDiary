//
//  NewWeightEntryViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 16/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase

class NewWeightEntryViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK:- Properties
    
    @IBOutlet weak var weightTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!
    @IBOutlet weak var dateButton: DateButton!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var weightTextLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateTextLabelLeadingConstraint: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    let defaults = UserDefaults()
    
    weak var delegate: WeightDelegate?
    let formatter = DateFormatter()
    let buttonFormatter = DateFormatter()
    
    var weightEntry: Weight?
    var isEditingExistingEntry = false
    var selectedSegmentIndex = 0
    let datePicker = UIDatePicker()
    private let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    private let textFieldToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    //MARK:- view methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        setUpToolBar()
        setUpViews()
        checkDeviceAndUpdateLayoutIfNeeded()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
        isEditingExistingEntry = false
    }
    
    func checkDeviceAndUpdateLayoutIfNeeded() {
        if UIScreen.main.bounds.height < 600 {
            weightTextLabelLeadingConstraint.constant = 30
            dateTextLabelLeadingConstraint.constant = 30
            weightTextLabel.font = weightTextLabel.font.withSize(16)
            dateTextLabel.font = dateTextLabel.font.withSize(16)
            dateButton.titleLabel?.font = dateButton.titleLabel?.font.withSize(16)
            weightTextField.font = weightTextField.font?.withSize(16)
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
    
    //MARK:- Set Up Methods
    
    func setUpNavBar() {
         let dismissButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
         dismissButton.setImage(UIImage(named: "plus-icon"), for: .normal)
         dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
         dismissButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
         dismissButton.imageView?.clipsToBounds = false
         dismissButton.imageView?.contentMode = .center
         let barButton = UIBarButtonItem(customView: dismissButton)
         navigationItem.leftBarButtonItem = barButton
         
         navigationController?.navigationBar.barTintColor = Color.skyBlue
     }
     
     func setUpToolBar() {
        self.toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(dismissResponder)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(todayTapped)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateEntered))
        ]
        self.toolbar.sizeToFit()
        self.textFieldToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(dismissResponder)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismissResponder))
        ]
        self.textFieldToolbar.sizeToFit()
        weightTextField.inputAccessoryView = textFieldToolbar
        
    }
    
    func setUpViews() {
        
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        
        if let weight = weightEntry?.weight {
            weightTextField.text = "\(weight)"
        }
        unitLabel.text = defaults.value(forKey: UserDefaultsKeys.weightUnit) as? String ?? "kg"
        formatter.dateFormat = "E, dd MMM YYYY"
        buttonFormatter.dateFormat = "E, dd MMM"
        dateButton.setTitle(buttonFormatter.string(from: weightEntry?.date ?? Date()), for: .normal)
        datePicker.date = weightEntry?.date ?? Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
    }
    
    
    //MARK:- Button Methods

    @IBAction func dateButtonTapped(_ sender: DateButton) {
        self.becomeFirstResponder()
        sender.dateView = datePicker
        sender.toolBarView = toolbar
        sender.inputView = datePicker
        sender.inputAccessoryView = toolbar
    }
    
    // Nav bar button
    @objc func dismissButtonTapped(_ sender: UIBarButtonItem) {
        if isEditingExistingEntry {
            navigationController?.popViewController(animated: true)
        }
        else {
            dismissViewWithAnimation()
        }
    }
    
    // Toolbar button
    @objc func dateEntered() {
        dateButton.resignFirstResponder()
        dateButton.setTitle(buttonFormatter.string(from: datePicker.date), for: .normal)
    }
    
    @objc func todayTapped() {
        datePicker.date = Date()
    }
    
    // Toolbar button
    @objc func dismissResponder() {
        if weightTextField.isFirstResponder {
            weightTextField.resignFirstResponder()
        }
        else {
            dateButton.resignFirstResponder()
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        let entry: Weight
//        var originalWeight = 0.0
        if weightEntry != nil {
            entry = weightEntry!
//            originalWeight = weightEntry!.weight
        }
        else {
            entry = Weight()
        }
        
        if let weight = weightTextField.text {
            if !weight.isEmpty {
                entry.weight = Double(weight)!
            }
            else {
                let AC = UIAlertController(title: "Error", message: "Please enter a weight.", preferredStyle: .alert)
                AC.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(AC, animated: false)
                return
            }
        }
        entry.unit = unitLabel.text ?? "kg"
        entry.date = datePicker.date
        entry.dateLastEdited = datePicker.date
        entry.dateString = formatter.string(from: datePicker.date)
        
        guard let user = Auth.auth().currentUser?.uid else { return }
        
        if isEditingExistingEntry {
            print(entry.date)
            let weightDocumentToUpdate = db.collection("users").document(user).collection("weight").document("\(entry.dateString!)")
            
            weightDocumentToUpdate.updateData([
                "weight": entry.weight,
                "unit": entry.unit,
                "date": entry.date,
                "dateString": entry.dateString!,
                "dateLastEdited": Date()
            ]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated")
                }
            }
            isEditingExistingEntry = false
            navigationController?.popViewController(animated: true)
            delegate?.reloadData(weightEntry: entry, date: datePicker.date)
        }
        else {
            entry.saveWeight(user: user)
            dismissViewWithAnimation()
            delegate?.reloadData(weightEntry: entry, date: datePicker.date)
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIScreen.main.bounds.height < 600 {
            return 50
        }
        else {
            return 55
        }
    }
    
}



