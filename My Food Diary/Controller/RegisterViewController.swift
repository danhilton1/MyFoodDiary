//
//  RegisterViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 27/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftKeychainWrapper

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    let defaults = UserDefaults()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var confirmPasswordTextField: LogInTextField!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var emailLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerButtonHeightConstraint: NSLayoutConstraint!
    
    
    //MARK:- View methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpTextFields()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
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
    }
    
    func setUpViews() {
        view.backgroundColor = Color.skyBlue
        registerButton.setTitleColor(Color.skyBlue, for: .normal)
        registerButton.layer.cornerRadius = registerButton.frame.size.height / 2
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        emailTextField.layer.cornerRadius = 20
        passwordTextField.layer.cornerRadius = 20
        confirmPasswordTextField.layer.cornerRadius = 20
        checkDeviceAndUpdateConstraints()
    }
    
    func setUpTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        addInputAccessoryForTextFields(textFields: [emailTextField, passwordTextField, confirmPasswordTextField], dismissable: true, previousNextable: true)
        
        emailTextField.setLeftPaddingPoints(6)
        passwordTextField.setLeftPaddingPoints(6)
        confirmPasswordTextField.setLeftPaddingPoints(6)
        emailTextField.placeholder = "Enter your email address"
        passwordTextField.placeholder = "Enter a password"
        confirmPasswordTextField.placeholder = "Re-enter your password"
    }
    
    func checkDeviceAndUpdateConstraints() {
        if UIScreen.main.bounds.height < 600 {
            backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
            backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            titleLabel.font = titleLabel.font.withSize(22)
            emailLabel.font = emailLabel.font.withSize(18)
            passwordLabel.font = passwordLabel.font.withSize(18)
            emailTextField.font = emailTextField.font?.withSize(14)
            passwordTextField.font = passwordTextField.font?.withSize(14)
            confirmPasswordTextField.font = confirmPasswordTextField.font?.withSize(14)
            emailLabelTopConstraint.constant = 105
            emailTextFieldHeightConstraint.constant = 35
            emailTextFieldTopConstraint.constant = 10
            passwordTextFieldHeightConstraint.constant = 35
            passwordTextFieldTopConstraint.constant = 10
            passwordTextFieldBottomConstraint.constant = 10
            confirmTextFieldHeightConstraint.constant = 35
            emailTextField.layer.cornerRadius = 19
            passwordTextField.layer.cornerRadius = 19
            confirmPasswordTextField.layer.cornerRadius = 19
            registerButtonHeightConstraint.constant = 38
            registerButtonTopConstraint.constant = 35
            registerButtonBottomConstraint.constant = 80
            registerButton.layer.cornerRadius = 20
        }
    }
    
    //MARK:- Button Methods
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        if passwordTextField.text == confirmPasswordTextField.text {
        
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] (authResult, error) in
                guard let strongSelf = self else { return }
                if let error = error {
                    print(error)
                    SVProgressHUD.setMinimumDismissTimeInterval(3)
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                else {
                    print("Registration Successful")
                    strongSelf.db.collection("users").document((authResult?.user.email)!).setData([
                        "email": (authResult?.user.email)!,
                        "uid": authResult!.user.uid
                    ]) { error in
                        if let error = error {
                            print("Error adding user: \(error)")
                            SVProgressHUD.setMinimumDismissTimeInterval(3)
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                        } else {
                            print("User added with ID: \(authResult!.user.email!)")
                            strongSelf.defaults.set(authResult!.user.email, forKey: "userEmail")
                            KeychainWrapper.standard.set(strongSelf.passwordTextField.text!, forKey: "userPassword")
                            strongSelf.defaults.set(true, forKey: "userSignedIn")
                            SVProgressHUD.dismiss()
                            strongSelf.performSegue(withIdentifier: "GoToOverview", sender: self)
                        }
                    }
                }
            }
        }
        else {
            passwordTextField.resignFirstResponder()
            confirmPasswordTextField.resignFirstResponder()
            
            let ac = UIAlertController(title: "Password Mismatch", message: "The passwords you entered do not match. Please make sure they are identical.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel) { [weak self] (action) in
                guard let strongSelf = self else { return }
                
                strongSelf.confirmPasswordTextField.text = ""
                strongSelf.passwordTextField.becomeFirstResponder()
            })
            
            present(ac, animated: true)
            
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Keyboard View Methods
    
    @objc func viewTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.5) {
                    if UIScreen.main.bounds.height < 600 {
                        self.view.frame.origin.y -= (keyboardSize.height / 2) - 20
                    }
                    else if UIScreen.main.bounds.height < 700 {
                        self.view.frame.origin.y -= (keyboardSize.height / 2)
                    }
                    else {
                        self.view.frame.origin.y -= (keyboardSize.height / 3)
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
        }
    }
    
}



//MARK:- UITextField Extension for padding

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
