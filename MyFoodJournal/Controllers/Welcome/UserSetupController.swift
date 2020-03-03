//
//  UserSetupController.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 02/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//
import Foundation
import UIKit


class UserSetupController: UITableViewController, UITextFieldDelegate {
    
    private let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    var activeTextField: UITextField!
    
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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        setUpTextFields()
        presentAlert()
        
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
        
        self.toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(revealNextView))
        ]
        self.toolbar.sizeToFit()
        agetextField.inputAccessoryView = toolbar
        inchesTextField.inputAccessoryView = toolbar
        cmTextField.inputAccessoryView = toolbar
        weightTextField.inputAccessoryView = toolbar
        
        for segment in activitySegment.subviews{
            for label in segment.subviews{
                if let labels = label as? UILabel{
                    labels.numberOfLines = 5
                    labels.font = UIFont(name: "Montserrat-Regular", size: 14)!
                }
            }
        }
        
        cancelButton.alpha = 0
        genderLabel.alpha = 0
        genderSegments.alpha = 0
        tickButton.alpha = 0
        ageLabel.alpha = 0
        agetextField.alpha = 0
        yearsOldLabel.alpha = 0
        heightLabel.alpha = 0
        heighUnitSegments.alpha = 0
        ftAndInchesStackView.alpha = 0
//        ftTextField.alpha = 0
//        inchesTextField.alpha = 0
        cmStackView.alpha = 0
//        cmTextField.alpha = 0
        weightLabel.alpha = 0
        weightUnitSegments.alpha = 0
        weightTextField.alpha = 0
        activityLabel.alpha = 0
        activityInfoButton.alpha = 0
        activitySegment.alpha = 0
        calculateButton.alpha = 0
        
        
    }
    
    func setUpTextFields() {
        agetextField.delegate = self
        ftTextField.delegate = self
        inchesTextField.delegate = self
        cmTextField.delegate = self
        weightTextField.delegate = self
        
        ftTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    func presentAlert() {
        let ac = UIAlertController(title: "Account Setup", message: "To help you achieve your goals we can offer you our recommended targets for nutrition. We just need a few pieces of basic information about you.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) in
            UIView.animate(withDuration: 0.5) {
                self.genderLabel.alpha = 1
                self.genderSegments.alpha = 1
                self.tickButton.alpha = 1
                self.cancelButton.alpha = 1
            }
        })
        ac.addAction(UIAlertAction(title: "No thanks", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: nil)
        })
        present(ac, animated: true)
    }

    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Exit", message: "You can set up your goals anytime on the 'Goals' page under the 'More' tab.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "GoToTabBar", sender: nil)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(ac, animated: true)
    }
    
    @IBAction func tickButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.ageLabel.alpha = 1
            self.agetextField.alpha = 0.5
            self.yearsOldLabel.alpha = 1
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
    
    
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        
//        let user = Person(gender: <#T##String#>, age: <#T##Int#>, weight: <#T##Double#>, goalWeight: <#T##Double#>, activityLevel: <#T##String#>)
    }
    
    @objc func revealNextView() {
        switch activeTextField {
        case agetextField:
            agetextField.resignFirstResponder()
            UIView.animate(withDuration: 0.5) {
                self.heightLabel.alpha = 1
                self.heighUnitSegments.alpha = 1
                self.ftAndInchesStackView.alpha = 1
            }
        case inchesTextField:
            inchesTextField.resignFirstResponder()
            UIView.animate(withDuration: 0.5) {
                self.weightLabel.alpha = 1
                self.weightUnitSegments.alpha = 1
                self.weightTextField.alpha = 0.5
            }
        default:
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

extension UserSetupController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Color.skyBlue
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text {
            if text.count > 0 {
                inchesTextField.becomeFirstResponder()
            }
        }
    }
    
    
    
    
    
}
