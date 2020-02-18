//
//  LaunchScreenController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 15/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class LaunchScreenController: UIViewController {

    @IBOutlet weak var iconToTitleLabelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var yValue = -(self.appIconImageView.frame.minY - self.titleLabel.frame.maxY)
        
        switch UIScreen.main.bounds.height {
        case ..<600:
           yValue += 90
        case ..<700:
            yValue += 76
        case ..<800:
            yValue += 56
        default:
            yValue += 42
        }
//        if UIScreen.main.bounds.height < 600 {
//            yValue += 90
//        }
//        else if UIScreen.main.bounds.height < 700 {
//            yValue += 76
//        }
//        else if UIScreen.main.bounds.height < 800 {
//            yValue += 56
//        }
//        else if UIScreen.main.bounds.height < 850 {
//            yValue += 42
//        }
//        iconCenterXConstraint.isActive = false
//        iconCenterYConstraint.isActive = false
//        iconToTitleLabelConstraint.constant = 45
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseInOut, animations: {
            self.appIconImageView.transform = CGAffineTransform(translationX: 0, y: yValue + 45)
//            self.appIconImageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 45).isActive = true
//            self.view.layoutIfNeeded()
        }) { (success) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    

}
