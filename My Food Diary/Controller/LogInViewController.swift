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
        
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if error != nil {
                print(error!)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            else {
                print("Log In Successful")
                SVProgressHUD.dismiss()
                strongSelf.performSegue(withIdentifier: "GoToOverview", sender: self)
            }
          
        }
        
        
    }
    

}
