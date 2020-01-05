//
//  NewWeightEntryViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 16/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class NewWeightEntryViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK:- Properties
    
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dateButton: DateButton!
    @IBOutlet weak var weightTextField: UITextField!
    
    let db = Firestore.firestore()
    let realm = try! Realm()
    
    weak var delegate: WeightDelegate?
    let formatter = DateFormatter()
    let buttonFormatter = DateFormatter()
    private var weightEntry = Weight()
    
    private let datePicker = UIDatePicker()
    private let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    private let textFieldToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
        setUpToolBar()
        tableView.tableFooterView = UIView()
        
        formatter.dateFormat = "E, dd MMM YYYY"
        buttonFormatter.dateFormat = "E, dd MMM"
        dateButton.setTitle(buttonFormatter.string(from: Date()), for: .normal)
        
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current

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
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateEntered))
        ]
        self.toolbar.sizeToFit()
        self.textFieldToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(dismissResponder)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        self.textFieldToolbar.sizeToFit()
        weightTextField.inputAccessoryView = textFieldToolbar
        
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
        dismissViewWithAnimation()
    }
    
    // Toolbar button
    @objc func dateEntered() {
        dateButton.resignFirstResponder()
        dateButton.setTitle(buttonFormatter.string(from: datePicker.date), for: .normal)
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
        
        if let weight = weightTextField.text {
            if !weight.isEmpty {
                weightEntry.weight = Double(weight)!
            }
            else {
                let AC = UIAlertController(title: "Error", message: "Please enter a weight.", preferredStyle: .alert)
                AC.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(AC, animated: false)
                return
            }
        }
        weightEntry.unit = unitSegmentedControl.titleForSegment(at: unitSegmentedControl.selectedSegmentIndex)!
        weightEntry.date = datePicker.date
        weightEntry.dateString = formatter.string(from: datePicker.date)
        
        let user = Auth.auth().currentUser?.email ?? Auth.auth().currentUser!.uid
        weightEntry.saveWeight(user: user)
        //save(weightEntry)
        dismissViewWithAnimation()
        delegate?.reloadData(weightEntry: weightEntry, date: datePicker.date)
        
    }
    
    
//    func save(_ weight: Object) {
//        
//        do {
//            try realm.write {
//                realm.add(weight)
//            }
//        } catch {
//            print(error)
//        }
//    }

    
    func dismissViewWithAnimation() {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
}



