//
//  WelcomeViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 21/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class WelcomeViewController: UIViewController {
    
    typealias FinishedDownload = () -> ()
    
    let defaults = UserDefaults()
    var allFood = [Food]()
    var allWeight = [Weight]()
    let foodDispatchGroup = DispatchGroup()
    let weightDispatchGroup = DispatchGroup()
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        checkIfUserIsSignedIn()
        
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
        if UIScreen.main.bounds.height < 700 {
            iconImageView.heightAnchor.constraint(equalToConstant: 140).isActive = true
            iconImageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
            registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            registerButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
            logInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            logInButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }

    func checkIfUserIsSignedIn() {
        if defaults.bool(forKey: "userSignedIn") {
            SVProgressHUD.show()
            let email = defaults.value(forKey: "userEmail") as! String
            let password = defaults.value(forKey: "userPassword") as! String
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    print(error)
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                else {
                    print("Log In Successful")
                    strongSelf.foodDispatchGroup.enter()  // enter dispatchGroup to allow data to finish downloading before segue
                    strongSelf.loadAllFoodData(user: email, anonymous: false)
                    
                    strongSelf.foodDispatchGroup.notify(queue: .main) {
                        strongSelf.weightDispatchGroup.enter()  // using two dispatch groups as Food and Weight data size will differ
                        strongSelf.loadAllWeightData(user: email, anonymous: false, completed: { () in
                    
                            strongSelf.weightDispatchGroup.notify(queue: .main) {
                                strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: self)
                                SVProgressHUD.dismiss()
                            }
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Warning", message: "If you continue without an account you will not be able to sync data across devices.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Continue Anyway", style: .default) { [weak self] (action) in
            SVProgressHUD.show()
            guard let strongSelf = self else { return }
            let db = Firestore.firestore()
            
            // Check if user has already used the app and if so, sign into their anonymous account and load locally stored data
            if let userEmail = strongSelf.defaults.value(forKey: "anonymousUserEmail") as? String {
                
                let userPassword = strongSelf.defaults.value(forKey: "anonymousUserPassword") as! String
                
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (authResult, error) in
                    guard let user = authResult?.user else { return }
                    
                    if let error = error {
                        print(error)
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    }
                    else {
                        strongSelf.foodDispatchGroup.enter()  // enter dispatchGroup to allow data to finish downloading before segue
                        strongSelf.loadAllFoodData(user: user.email!, anonymous: true)
                        
                        strongSelf.foodDispatchGroup.notify(queue: .main) {
                            strongSelf.weightDispatchGroup.enter()
                            strongSelf.loadAllWeightData(user: user.email!, anonymous: true, completed: { () in
                        
                                strongSelf.weightDispatchGroup.notify(queue: .main) {
                                    print("Anonymous User: \(user.email!) Successfully Logged In.")
                                    strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: self)
                                    SVProgressHUD.dismiss()
                                }
                            })
                        }
                    }
                }
            }
            else {
            // if user has not used the app before, sign them in anonymously and assign the device a dummy account to use for future
                Auth.auth().signInAnonymously() { (authResult, error) in
                    
                    if let error = error {
                        print(error)
                    }
                    else {
                        guard let user = authResult?.user else { return }
                        
                        let email = "\(user.uid)@anonymous.com"
                        let password = "password"
                        strongSelf.defaults.set(email, forKey: "anonymousUserEmail")
                        strongSelf.defaults.set(password, forKey: "anonymousUserPassword")
                        
                        Auth.auth().createUser(withEmail: email, password: password) { (newUser, error) in
                            if let error = error {
                                print(error)
                            }
                            else {
                                db.collection("users").document(user.email!).setData([
                                    "email": email,
                                    "uid": user.uid
                                ]) { error in
                                    if let error = error {
                                        print("Error adding user: \(error)")
                                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                                    } else {
                                        print("User added with ID: \(user.uid)")
                                        strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: self)
                                        SVProgressHUD.dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        present(ac, animated: true)
    }
    
    func loadAllFoodData(user: String, anonymous: Bool) {
        Food.downloadAllFood(user: user, anonymous: anonymous) { (allFood) in
            self.allFood = allFood
            self.foodDispatchGroup.leave()
        }
    }
    
    func loadAllWeightData(user: String, anonymous: Bool, completed: @escaping FinishedDownload) {
        Weight.downloadAllWeight(user: user, anonymous: anonymous) { (allWeight) in
            self.allWeight = allWeight
            self.weightDispatchGroup.leave()
            completed()
        }
    }
    
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
            
        }
    }

    

}
