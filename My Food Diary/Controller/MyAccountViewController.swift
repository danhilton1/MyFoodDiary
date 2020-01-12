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

    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailLabel.text = Auth.auth().currentUser?.email
        
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - Table view data source

    


}
