//
//  LaunchScreenController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 15/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class LaunchScreenController: UIViewController {


    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var yValue = -(self.appIconImageView.frame.minY - self.titleLabel.frame.maxY)
        
        switch UIScreen.main.bounds.height {
        case ..<600:
           yValue += 64
        case ..<700:
            yValue += 50
        case ..<800:
            yValue += 56
        case ..<850:
            yValue += 42
        default:
            yValue += 0
        }
        
        let originalTransform = appIconImageView.transform
        let scaledTransform = originalTransform.scaledBy(x: 1.25, y: 1.25)
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0, y: yValue + 45)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseInOut, animations: {
            if UIScreen.main.bounds.height < 600 {
                self.appIconImageView.transform = scaledAndTranslatedTransform
            }
            else {
                self.appIconImageView.transform = CGAffineTransform(translationX: 0, y: yValue + 45)
            }
            
        }) { (success) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = vc
            
        }
        
    }
    

}
