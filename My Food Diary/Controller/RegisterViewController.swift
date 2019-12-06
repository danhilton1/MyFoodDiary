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

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.skyBlue
        registerButton.setTitleColor(Color.skyBlue, for: .normal)
        registerButton.layer.cornerRadius = registerButton.frame.size.height / 2
//        passwordTextField.layer.cornerRadius = 20
        emailTextField.placeholder = "Enter your email address"
        passwordTextField.placeholder = "Enter a password"
        
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
    

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            else {
                print("Registration Successful")
                self.db.collection("users").document((authResult?.user.email)!).setData([
                    "email": (authResult?.user.email)!,
                    "uid": authResult!.user.uid
                ]) { error in
                    if let error = error {
                        print("Error adding user: \(error)")
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    } else {
                        print("User added with ID: \(authResult!.user.email!)")
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "GoToOverview", sender: self)
                    }
                }
            }
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func viewTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // Methods to move up/down the messageTableView with the keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.5) {
                    self.view.frame.origin.y -= (keyboardSize.height / 3)
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
    
}
