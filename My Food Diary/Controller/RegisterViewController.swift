//
//  RegisterViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 27/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.skyBlue
        registerButton.setTitleColor(Color.skyBlue, for: .normal)
        registerButton.layer.cornerRadius = registerButton.frame.size.height / 2
    }
    


}
