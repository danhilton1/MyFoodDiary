//
//  LogInViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 27/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.skyBlue
        logInButton.setTitleColor(Color.skyBlue, for: .normal)
        logInButton.layer.cornerRadius = logInButton.frame.size.height / 2
        passwordTextField.placeholder = "Password"
//        emailTextField.layer.cornerRadius = 25
//        passwordTextField.layer.cornerRadius = 25
    }
    


}
