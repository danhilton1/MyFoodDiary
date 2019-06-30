//
//  NewEntryPopUpViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 28/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class PopUpNewEntryViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 12
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    
    


}
