//
//  LaunchScreenController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 15/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import UIKit

class LaunchScreenController: UIViewController {

    
    @IBOutlet weak var AppIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let yValue = -((self.AppIconImageView.frame.minY - self.titleLabel.frame.maxY) - 45)
        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseInOut, animations: {
            self.AppIconImageView.transform = CGAffineTransform(translationX: 0, y: yValue)
        }) { (success) in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
    }
    

}
