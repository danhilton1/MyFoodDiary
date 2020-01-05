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
    
//    private let db = Firestore.firestore()
    
    typealias FinishedDownload = () -> ()
    
    var allFood = [Food]()
    var allWeight = [Weight]()
    let foodDispatchGroup = DispatchGroup()
    let weightDispatchGroup = DispatchGroup()
    
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
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Confirm", message: "If you continue without an account you will not be able to sync data across devices.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Continue", style: .default) { (action) in
            SVProgressHUD.show()
            
            Auth.auth().signInAnonymously() { [weak self] (authResult, error) in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    print(error)
                }
                else {
                    guard let user = authResult?.user else { return }
                    print("\(user.uid) Log In Successful")
                    
                    strongSelf.foodDispatchGroup.enter()  // enter dispatchGroup to allow data to finish downloading before segue
                    strongSelf.loadAllFoodData(user: user.uid)
                    
                    strongSelf.foodDispatchGroup.notify(queue: .main) {
                        strongSelf.weightDispatchGroup.enter()
                        strongSelf.loadAllWeightData(user: user.uid, completed: { () in
                    
                            strongSelf.weightDispatchGroup.notify(queue: .main) {
                                strongSelf.performSegue(withIdentifier: "GoToTabBar", sender: self)
                                SVProgressHUD.dismiss()
                            }
                        })
                    }
                }
            }
        })
        present(ac, animated: true)
    }
    
    func loadAllFoodData(user: String) {
        Food.downloadAllFood(user: user, anonymous: true) { (allFood) in
            self.allFood = allFood
            self.foodDispatchGroup.leave()
        }
    }
    
    func loadAllWeightData(user: String, completed: @escaping FinishedDownload) {
        Weight.downloadAllWeight(user: user, anonymous: true) { (allWeight) in
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
