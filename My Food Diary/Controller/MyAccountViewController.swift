//
//  MyAccountViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 12/01/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase

class MyAccountViewController: UITableViewController {

    let popUpView = UIView()
    let dimmedView = UIView()
    
    var centerYconstraint = NSLayoutConstraint()
    
    @IBOutlet weak var emailLabel: UILabel!
    
    enum detailsToChange {
        static let email = "email"
        static let password = "password"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailLabel.text = Auth.auth().currentUser?.email
        
        tableView.tableFooterView = UIView()
        
        view.isUserInteractionEnabled = true
        dimmedView.isUserInteractionEnabled = true
        tableView.isUserInteractionEnabled = true
        //popUpView.isUserInteractionEnabled = true
        
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
//        emailLabel.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }

    // MARK: - Button Methods

    
    @IBAction func changeEmailTapped(_ sender: UIButton) {
        displayPopUpView(itemToChange: detailsToChange.email)
    }
    
    @IBAction func changePasswordTapped(_ sender: UIButton) {
        displayPopUpView(itemToChange: detailsToChange.password)
    }
    
    @objc func confirmButtonTapped(_ sender: UIButton) {
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
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches)
//        if let touch = touches.first {
//            let position = touch.location(in: dimmedView)
//            print("tap")
//            if !popUpView.frame.contains(position) {
//                print("tapped working")
//                viewTapped()
//            }
//        }
//    }
    
    
    func displayPopUpView(itemToChange: String) {
        
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        popUpView.layer.cornerRadius = 25
        popUpView.backgroundColor = .white
        popUpView.alpha = 0
        
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(named: "Cancel-Icon"), for: .normal)
        cancelButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        
        let emailLabel = UILabel()
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont(name: "Montserrat-Medium", size: 18)!
        emailLabel.text = "Email Address"
        
        let emailTextField = UITextField()
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
        
        let passwordTextField = UITextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.font = UIFont(name: "Montserrat-Regular", size: 15)!
        passwordTextField.placeholder = "Enter your password here"
        passwordTextField.isSecureTextEntry = true
        
        let newItemLabel = UILabel()
        newItemLabel.translatesAutoresizingMaskIntoConstraints = false
        newItemLabel.font = UIFont(name: "Montserrat-Medium", size: 18)!
        newItemLabel.text = "New \(itemToChange.capitalized)"
        
        let newItemTextField = UITextField()
        newItemTextField.translatesAutoresizingMaskIntoConstraints = false
        newItemTextField.font = UIFont(name: "Montserrat-Regular", size: 15)!
        newItemTextField.placeholder = "Enter your new \(itemToChange) here"
        newItemTextField.autocapitalizationType = .none
        newItemTextField.keyboardType = .emailAddress
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
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        popUpView.addSubview(cancelButton)
        popUpView.addSubview(emailLabel)
        popUpView.addSubview(emailTextField)
        popUpView.addSubview(passwordLabel)
        popUpView.addSubview(passwordTextField)
        popUpView.addSubview(newItemLabel)
        popUpView.addSubview(newItemTextField)
        popUpView.addSubview(confirmButton)
        
        view.addSubview(popUpView)
//        centerYconstraint = NSLayoutConstraint(item: popUpView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
//        centerYconstraint = popUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        NSLayoutConstraint.activate([
            popUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popUpView.widthAnchor.constraint(equalToConstant: 300),
            popUpView.heightAnchor.constraint(equalToConstant: 300),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 10),
            cancelButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: -10),
            
            emailLabel.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 30),
            emailLabel.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor, constant: 20),
            emailLabel.heightAnchor.constraint(equalToConstant: 20),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
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
        
        dimmedView.backgroundColor = .black
        dimmedView.alpha = 0
        dimmedView.frame = view.frame
        view.addSubview(dimmedView)
        view.bringSubviewToFront(popUpView)
        
        UIView.animate(withDuration: 0.3) {
            self.popUpView.alpha = 1
            self.dimmedView.alpha = 0.35
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.popUpView.frame.origin.y == 254 {
                UIView.animate(withDuration: 0.5) {
                    if UIScreen.main.bounds.height < 700 {
                        self.popUpView.frame.origin.y -= (keyboardSize.height - 60)
                    }
                    else {
                        self.popUpView.frame.origin.y -= (keyboardSize.height - 220)

//                        self.popUpView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = false
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.popUpView.frame.origin.y != 254 {
            UIView.animate(withDuration: 0.5) {
                self.popUpView.frame.origin.y = 254
            }
        }
    }
    

}
