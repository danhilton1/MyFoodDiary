//
//  MyAccountViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 12/01/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftKeychainWrapper

class MyAccountViewController: UITableViewController {

    let popUpView = UIView()
    let dimmedView = UIView()
    var detailToChange = detailsToChange.password
    var newEmail: String?
    var newPassword: String?
    var isAnonymous: Bool {
        if defaults.value(forKey: "anonymousUserEmail") as? String != nil {
            return true
        }
        else {
            return false
        }
    }
    let defaults = UserDefaults()
    
    var centerYconstraint = NSLayoutConstraint()
    
    @IBOutlet weak var emailLabel: UILabel!
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let newItemTextField = UITextField()
    
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var changeEmailButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var passwordCell: UITableViewCell!
    
    enum detailsToChange {
        static let email = "email"
        static let password = "password"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailLabel.text = Auth.auth().currentUser?.email
        
        tableView.tableFooterView = UIView()
        
        checkIfUserIsAnonymous()
        
        if UIScreen.main.bounds.height < 700 {
            emailLabel.frame.size.height = 70
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
        
        SVProgressHUD.setMinimumDismissTimeInterval(2)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

    }
    
    func checkIfUserIsAnonymous() {
        if isAnonymous {
            emailLabel.text = "Account not created"
            changeEmailButton.setTitle("Create and link account", for: .normal)
            changePasswordButton.setTitleColor(.lightGray, for: .normal)
            passwordCell.isUserInteractionEnabled = false

        }
    }

    // MARK: - Button Methods

    
    @IBAction func changeEmailTapped(_ sender: UIButton) {
        if isAnonymous {
            displayPopUpView(itemToChange: detailsToChange.password)
            detailToChange = detailsToChange.password
        }
        else {
            displayPopUpView(itemToChange: detailsToChange.email)
            detailToChange = detailsToChange.email
        }
    }
    
    @IBAction func changePasswordTapped(_ sender: UIButton) {
        displayPopUpView(itemToChange: detailsToChange.password)
        detailToChange = detailsToChange.password
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
        
        if let newDetailText = newItemTextField.text {
            
            SVProgressHUD.setBackgroundColor(.darkGray)
            SVProgressHUD.setForegroundColor(.white)
            
            if isAnonymous {
                emailTextField.resignFirstResponder()
                passwordTextField.resignFirstResponder()
                newItemTextField.resignFirstResponder()
                
                
                SVProgressHUD.show()
                
                guard let email = emailTextField.text else {
                    SVProgressHUD.showError(withStatus: "Invalid email address entered")
                    return
                }
                guard let password = self.passwordTextField.text else {
                    SVProgressHUD.showError(withStatus: "Invalid password entered")
                    return
                }
                if password != self.newItemTextField.text {
                    SVProgressHUD.showError(withStatus: "Entered passwords do not match. Please make sure they are identical.")
                }
                else {
                                    
                    Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                        if let error = error {
                            print("Error creating account - \(error)")
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                        }
                        else {
                            
                            Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                                if let error = error {
                                    print("Error creating account - \(error)")
                                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                                    
                                    guard let anonymousEmail = self.defaults.value(forKey: UserDefaultsKeys.anonymousUserEmail) as? String else { return }
                                    Auth.auth().currentUser?.updateEmail(to: anonymousEmail)
                                }
                                else {
                                    
                                    self.defaults.removeObject(forKey: UserDefaultsKeys.anonymousUserEmail)
                                    KeychainWrapper.standard.removeObject(forKey: "anonymousUserPassword")
                                    self.defaults.set(email, forKey: UserDefaultsKeys.userEmail)
                                    KeychainWrapper.standard.set(password, forKey: "userPassword")
                                    self.defaults.set(true, forKey: UserDefaultsKeys.isUserSignedIn)
                                    
                                    SVProgressHUD.showSuccess(withStatus: "Account successfully created!")
                                    
                                    self.dismissPopUp()
                                    self.emailLabel.text = email
                                    self.changeEmailButton.setTitle("Change Email", for: .normal)
                                    self.changePasswordButton.setTitleColor(Color.skyBlue, for: .normal)
                                    self.passwordCell.isUserInteractionEnabled = true
      
                                }
                            }
                        }
                    }
                }
            }
            else {
                if emailTextField.text == (defaults.value(forKey: UserDefaultsKeys.userEmail) as? String) && passwordTextField.text == KeychainWrapper.standard.string(forKey: "userPassword") {
                    if detailToChange == detailsToChange.email {
                        Auth.auth().currentUser?.updateEmail(to: newDetailText) { (error) in
                            if let error = error {
                                print("Error updating email - \(error)")
                                SVProgressHUD.showError(withStatus: error.localizedDescription)
                            }
                            else {
                                self.defaults.set(newDetailText, forKey: UserDefaultsKeys.userEmail)
                                self.emailLabel.text = newDetailText
                                SVProgressHUD.showSuccess(withStatus: "Email successfully updated!")
                            }
                        }
                    }
                    else {
                        Auth.auth().currentUser?.updatePassword(to: newDetailText) { (error) in
                            if let error = error {
                                print("Error updating password - \(error)")
                                SVProgressHUD.showError(withStatus: error.localizedDescription)
                            }
                            else {
                                KeychainWrapper.standard.set(newDetailText, forKey: "userPassword")
                                SVProgressHUD.showSuccess(withStatus: "Password successfully updated!")
                            }
                        }
                    }
                    dismissPopUp()
                }
                else {
                    SVProgressHUD.showError(withStatus: "Entered user details do not match account details. Please enter correct information.")
                }
            }
        }
    }
    
    func dismissPopUp() {
        UIView.animate(withDuration: 0.3) {
            self.popUpView.alpha = 0
            self.dimmedView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.popUpView.removeFromSuperview()
            self.dimmedView.removeFromSuperview()
            self.popUpView.subviews[self.popUpView.subviews.count - 2].removeFromSuperview()
            self.popUpView.subviews[self.popUpView.subviews.count - 2].removeFromSuperview()
        }
        emailTextField.text = nil
        passwordTextField.text = nil
        newItemTextField.text = nil
    }
    
    @objc func viewTapped() {
        
            UIView.animate(withDuration: 0.2) {
                self.popUpView.alpha = 0
                self.dimmedView.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.popUpView.removeFromSuperview()
                self.dimmedView.removeFromSuperview()
                for subview in self.popUpView.subviews {
                    subview.removeFromSuperview()
                }
            }
    }
    
    
    
    func displayPopUpView(itemToChange: String) {
        
        view.addSubview(popUpView)
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.layer.cornerRadius = 25
        popUpView.backgroundColor = .white
        popUpView.alpha = 0
        
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(named: "Cancel-Icon"), for: .normal)
        cancelButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        
        let popUpEmailLabel = UILabel()
        popUpEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        popUpEmailLabel.font = UIFont(name: "Montserrat-Medium", size: 18)!
        popUpEmailLabel.text = "Email Address"
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.font = UIFont(name: "Montserrat-Regular", size: 15)!
        emailTextField.textColor = .darkGray
        emailTextField.placeholder = "Enter your email here"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        let passwordLabel = UILabel()
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.font = UIFont(name: "Montserrat-Medium", size: 18)!
        passwordLabel.text = "Password"
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.font = UIFont(name: "Montserrat-Regular", size: 15)!
        passwordTextField.placeholder = "Enter your password here"
        passwordTextField.isSecureTextEntry = true
        
        let newItemLabel = UILabel()
        newItemLabel.translatesAutoresizingMaskIntoConstraints = false
        newItemLabel.font = UIFont(name: "Montserrat-Medium", size: 18)!
        if isAnonymous {
           newItemLabel.text = "Confirm \(itemToChange.capitalized)"
        }
        else {
            newItemLabel.text = "New \(itemToChange.capitalized)"
        }
        
        newItemTextField.translatesAutoresizingMaskIntoConstraints = false
        newItemTextField.font = UIFont(name: "Montserrat-Regular", size: 15)!
        if defaults.value(forKey: "anonymousUserEmail") as? String != nil {
            newItemTextField.placeholder = "Re-enter your \(itemToChange)"
        }
        else {
            newItemTextField.placeholder = "Enter your new \(itemToChange) here"
        }
        newItemTextField.autocapitalizationType = .none
        newItemTextField.keyboardType = .emailAddress
        newItemTextField.autocorrectionType = .no
        if itemToChange == detailsToChange.password {
            newItemTextField.isSecureTextEntry = true
            newItemTextField.keyboardType = .default
        }
        
        let confirmButton = UIButton(type: .system)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.layer.cornerRadius = 20
        confirmButton.backgroundColor = Color.skyBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 18)!
        if isAnonymous {
            confirmButton.setTitle("Create", for: .normal)
        }
        else {
            confirmButton.setTitle("Confirm", for: .normal)
        }
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        popUpView.addSubview(cancelButton)
        popUpView.addSubview(popUpEmailLabel)
        popUpView.addSubview(emailTextField)
        popUpView.addSubview(passwordLabel)
        popUpView.addSubview(passwordTextField)
        popUpView.addSubview(newItemLabel)
        popUpView.addSubview(newItemTextField)
        popUpView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            popUpView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),
            popUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            popUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popUpView.widthAnchor.constraint(equalToConstant: 300),
            popUpView.heightAnchor.constraint(equalToConstant: 300),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: -10),
            
            popUpEmailLabel.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 30),
            popUpEmailLabel.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            popUpEmailLabel.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            popUpEmailLabel.heightAnchor.constraint(equalToConstant: 20),
            
            emailTextField.topAnchor.constraint(equalTo: popUpEmailLabel.bottomAnchor, constant: 10),
            emailTextField.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            emailTextField.heightAnchor.constraint(equalToConstant: 20),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordLabel.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            passwordLabel.heightAnchor.constraint(equalToConstant: 20),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            passwordTextField.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 20),
            
            newItemLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 35),
            newItemLabel.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            newItemLabel.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            newItemLabel.heightAnchor.constraint(equalToConstant: 20),
            
            newItemTextField.topAnchor.constraint(equalTo: newItemLabel.bottomAnchor, constant: 10),
            newItemTextField.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            newItemTextField.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            newItemTextField.heightAnchor.constraint(equalToConstant: 20),
            
//            confirmButton.heightAnchor.constraint(equalToConstant: 40),
            confirmButton.widthAnchor.constraint(equalToConstant: 150),
            confirmButton.centerXAnchor.constraint(equalTo: popUpView.centerXAnchor),
            confirmButton.topAnchor.constraint(equalTo: newItemTextField.bottomAnchor, constant: 15),
            //confirmButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            //confirmButton.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            confirmButton.bottomAnchor.constraint(greaterThanOrEqualTo: popUpView.bottomAnchor, constant: -15)
        ])
        if UIScreen.main.bounds.height < 700 {
            popUpView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20).isActive = true
            popUpView.widthAnchor.constraint(equalToConstant: 280).isActive = true
            popUpView.heightAnchor.constraint(equalToConstant: 280).isActive = true
            newItemLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 28).isActive = true
            confirmButton.bottomAnchor.constraint(equalTo: popUpView.bottomAnchor, constant: -12).isActive = true
            confirmButton.topAnchor.constraint(equalTo: newItemTextField.bottomAnchor, constant: 12).isActive = true
            confirmButton.layer.cornerRadius = 14
        }
//        popUpView.center = view.center
        dimmedView.backgroundColor = .black
        dimmedView.alpha = 0
        dimmedView.frame = view.frame
        view.addSubview(dimmedView)
        view.bringSubviewToFront(emailLabel)
        view.bringSubviewToFront(popUpView)
        
        UIView.animate(withDuration: 0.3) {
            self.popUpView.alpha = 1
            self.dimmedView.alpha = 0.35
        }
        
    }
    

}
