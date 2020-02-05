//
//  AboutViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 05/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {

    @IBOutlet weak var appLogoImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .white
        
        appLogoImageView.layer.cornerRadius = 25
        titleLabel.textColor = Color.skyBlue
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "Version: \(appVersion ?? "1.0.0")"
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }



}
