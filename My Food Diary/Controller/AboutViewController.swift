//
//  AboutViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 05/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UITableViewController, MFMailComposeViewControllerDelegate {

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

    
    @IBAction func mailButtonTapped(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["contact.myfooddiary@gmail.com"])

            present(mail, animated: true)
        } else {
            let ac = UIAlertController(title: "Unable to send mail", message: "An error was encountered when trying to compose an email. Please check your mail settings.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    
    @IBAction func privacyPolicyButtonTapped(_ sender: UIButton) {
        
    }
    
}
