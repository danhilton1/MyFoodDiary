//
//  MoreViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 17/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MoreViewController: UITableViewController {
    
    private let defaults = UserDefaults()
    
    var allFood: [Food]?

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Log Out?", message: "Are you sure you wish to sign out of your account?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] (action) in
            guard let strongSelf = self else { return }
            
            do {
                try Auth.auth().signOut()
                
                if Auth.auth().currentUser == nil {
                    strongSelf.defaults.removeObject(forKey: "userEmail")
                    strongSelf.defaults.removeObject(forKey: "userPassword")
                    strongSelf.defaults.set(false, forKey: "userSignedIn")
                    
                    let welcomeVC = strongSelf.storyboard?.instantiateViewController(withIdentifier: "WelcomeNav") as! UINavigationController
                    strongSelf.present(welcomeVC, animated: true)
                }
            }
            catch {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
            
        })
        
        present(ac, animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToNutrition" {
            let VC = segue.destination as! NutritionViewController
            VC.navigationController?.navigationBar.tintColor = .white
            VC.navigationItem.leftBarButtonItem = nil
            
        }
        else if segue.identifier == "GoToStats" {
            let VC = segue.destination as! StatsViewController
            VC.allFood = allFood
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            return 20
        }
    }

}
