//
//  MoreViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 17/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        
        tableView.tableFooterView = UIView()
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToNutrition" {
            let VC = segue.destination as! NutritionViewController
            VC.navigationController?.navigationBar.tintColor = .white
            VC.navigationItem.leftBarButtonItem = nil
            
        }
        
    }

}
