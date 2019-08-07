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
    
    var date: Date?
    weak var delegate: NewEntryDelegate?
    
    @IBOutlet weak var enterManuallyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 13
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        if !popUpView.frame.contains(location) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        
//        performSegue(withIdentifier: "goToBarcodeScanner", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToManualEntry" {
            let destVC = segue.destination as! NewEntryViewController
            destVC.delegate = delegate
            destVC.date = date
            
        }
    }
}
