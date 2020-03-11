//
//  AboutViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 05/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

class AboutViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    //MARK:- IBOutlets
    
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    func setUpViews() {
        navigationController?.navigationBar.tintColor = .white
        
        appLogoImageView.layer.cornerRadius = 25
        titleLabel.textColor = Color.skyBlue
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "Version: \(appVersion ?? "1.0.0")"
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }

    //MARK:- Button Method
    
    @IBAction func mailButtonTapped(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["contact.myfoodjournal@gmail.com"])

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
    
    @IBAction func termsButtonTapped(_ sender: UIButton) {
        showSafariVC(for: "https://50521ae6-b75c-4fbf-bb4b-853d879bccbc.filesusr.com/ugd/be5978_7ca00fed38ec4b3abc3c308d3f3f1ca7.pdf")
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: UIButton) {
        showSafariVC(for: "https://50521ae6-b75c-4fbf-bb4b-853d879bccbc.filesusr.com/ugd/be5978_cdf67c6dc0c84f788b98706f4fa2ab1d.pdf")
    }
    
    func showSafariVC(for url: String) {
        if let url = URL(string: url) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .currentContext
            present(safariVC, animated: true)
        }
        else {
            print("Error - invalid URL")
        }
    }
    
}
