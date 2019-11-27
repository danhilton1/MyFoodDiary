//
//  WelcomeViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 21/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //navigationController?.navigationBar.isHidden = false
    }
    
    func setUpViews() {
        view.backgroundColor = Color.skyBlue
        registerButton.layer.cornerRadius = registerButton.frame.size.height / 2
        logInButton.layer.cornerRadius = logInButton.frame.size.height / 2
        registerButton.setTitleColor(Color.skyBlue, for: .normal)
        logInButton.setTitleColor(Color.skyBlue, for: .normal)
    }

    

}
