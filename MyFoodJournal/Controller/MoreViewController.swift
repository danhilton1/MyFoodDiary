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
import SwiftKeychainWrapper

class MoreViewController: UITableViewController {
    
    //MARK:- Properties
    
    private let defaults = UserDefaults()
    
    var allFood: [Food]?

    @IBOutlet weak var logOutButton: UIButton!
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        logOutButton.layer.cornerRadius = 20
        logOutButton.backgroundColor = Color.skyBlue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = false
    }

    //MARK:- Button Method
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Log Out?", message: "Are you sure you wish to sign out of your account?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] (action) in
            guard let strongSelf = self else { return }
            
            do {
                try Auth.auth().signOut()
                
                if Auth.auth().currentUser == nil {
                    strongSelf.defaults.removeObject(forKey: "userEmail")
                    KeychainWrapper.standard.removeObject(forKey: "userPassword")
                    strongSelf.defaults.removeObject(forKey: "anonymousUserEmail")
                    strongSelf.defaults.set(false, forKey: "userSignedIn")
                    
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let welcomeVC = sb.instantiateViewController(withIdentifier: "WelcomeNav") as! UINavigationController
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
    
    //MARK:- Prepare for segue
    
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
    
    //MARK:- Tableview Methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            return 20
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
