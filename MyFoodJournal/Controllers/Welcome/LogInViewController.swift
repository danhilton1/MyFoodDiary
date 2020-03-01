//
//  LogInViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 27/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftKeychainWrapper


class LogInViewController: UIViewController, UITextFieldDelegate {

    //MARK:- Properties
    
    typealias FinishedDownload = () -> ()
    
    private let db = Firestore.firestore()
    private let defaults = UserDefaults()
    
    let foodDispatchGroup = DispatchGroup()
    let weightDispatchGroup = DispatchGroup()
    let formatter = DateFormatter()
    var allFood = [Food]()
    var allWeight = [Weight]()
    
    // IBOutlet Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    // IBOutlet Constraints
    @IBOutlet weak var iconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logInButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logInButtonHeightConstraint: NSLayoutConstraint!
    
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        setUpTextFields()
        checkDeviceAndUpdateConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func setUpViews() {
        view.backgroundColor = Color.skyBlue
        logInButton.setTitleColor(Color.skyBlue, for: .normal)
        logInButton.layer.cornerRadius = logInButton.frame.size.height / 2
        emailTextField.layer.cornerRadius = 22
        passwordTextField.layer.cornerRadius = 22
        
        formatter.dateFormat = "E, d MMM"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func setUpTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.placeholder = "Password"
        addInputAccessoryForTextFields(textFields: [emailTextField, passwordTextField], dismissable: true, previousNextable: true)
    }
    
    func checkDeviceAndUpdateConstraints() {
        if UIScreen.main.bounds.height < 600 {
            iconImageView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            titleLabel.font = titleLabel.font.withSize(25)
            iconTopConstraint.constant = 20
            iconBottomConstraint.constant = 30
            emailTextField.layer.cornerRadius = 20
            emailTextField.font = emailTextField.font?.withSize(15)
            passwordTextField.font = passwordTextField.font?.withSize(15)
            passwordTextField.layer.cornerRadius = 20
            forgotPasswordButton.titleLabel?.font = forgotPasswordButton.titleLabel?.font.withSize(15)
            logInButton.titleLabel?.font = logInButton.titleLabel?.font.withSize(18)
            logInButton.layer.cornerRadius = 20
            emailTextFieldHeightConstraint.constant = 38
            passwordTextFieldHeightConstraint.constant = 38
            logInButtonHeightConstraint.constant = 40
            logInButtonBottomConstraint.constant = 40
        }
        else if UIScreen.main.bounds.height < 700 {
            iconImageView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            iconImageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
            emailTextField.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 40).isActive = true
            emailTextField.layer.cornerRadius = 23
            passwordTextField.layer.cornerRadius = 23
        }
    }
    
    //MARK:- Data Methods
    
    func loadAllFoodData(user: String?) {
        Food.downloadAllFood(user: user!, anonymous: false) { (allFood) in
            self.allFood = allFood
            self.foodDispatchGroup.leave()
        }
    }
    
    func loadAllWeightData(user: String?, completed: @escaping FinishedDownload) {
        Weight.downloadAllWeight(user: user!, anonymous: false) { (allWeight) in
            self.allWeight = allWeight
            self.weightDispatchGroup.leave()
            completed()
        }
    }
    
    //MARK:- Button Methods
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
        SVProgressHUD.show()
        passwordTextField.resignFirstResponder()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if error != nil {
                print(error!)
                SVProgressHUD.setMinimumDismissTimeInterval(3)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            else {
                print("Log In Successful")
                strongSelf.foodDispatchGroup.enter()  // enter dispatchGroup to allow data to finish downloading before segue
                strongSelf.loadAllFoodData(user: authResult?.user.uid)
                
                strongSelf.foodDispatchGroup.notify(queue: .main) {
                    strongSelf.weightDispatchGroup.enter()  // using two dispatch groups as Food and Weight data size will differ
                    strongSelf.loadAllWeightData(user: authResult?.user.uid, completed: { () in
                
                        strongSelf.weightDispatchGroup.notify(queue: .main) {
                            strongSelf.defaults.set(authResult!.user.email, forKey: "userEmail")
                            strongSelf.defaults.set(true, forKey: "userSignedIn")
                            KeychainWrapper.standard.set(strongSelf.passwordTextField.text!, forKey: "userPassword")
                            strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: self)
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Keyboard View Methods
    
    @objc func viewTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.5) {
                    if UIScreen.main.bounds.height < 600 {
                        self.view.frame.origin.y -= (keyboardSize.height - 50)
                    }
                    else if UIScreen.main.bounds.height < 700 {
                        self.view.frame.origin.y -= (keyboardSize.height - 60)
                    }
                    else {
                        self.view.frame.origin.y -= (keyboardSize.height - 150)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    //MARK:- Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToTabBar" {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            let tabController = segue.destination as! UITabBarController
            let navController = tabController.viewControllers?.first as! UINavigationController
            let pageController = navController.viewControllers.first as! OverviewPageViewController
            pageController.allFood = allFood
            
            let weightNavController = tabController.viewControllers?[1] as! UINavigationController
            let weightVC = weightNavController.viewControllers.first as! WeightViewController
            weightVC.allWeightEntries = allWeight
            
            let moreNavController = tabController.viewControllers?[2] as! UINavigationController
            let moreVC = moreNavController.viewControllers.first as! MoreViewController
            moreVC.allFood = allFood
            
        }
    }
    
}

