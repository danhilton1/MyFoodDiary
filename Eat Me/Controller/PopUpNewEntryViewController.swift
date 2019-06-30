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
    
    var delegate: NewEntryDelegate?
    
    @IBOutlet weak var enterManuallyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 12
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        self.dismiss(animated: true, completion: nil)
//    }
//    
//    override func addChild(_ childController: UIViewController) {
//        self.addChild(NewEntryViewController())
//    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToManualEntry" {
//            let destNC = segue.destination as! UINavigationController
            let destVC = segue.destination as! NewEntryViewController
            destVC.delegate = delegate
            
        }
    }
}
