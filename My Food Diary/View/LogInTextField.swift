//
//  LogInTextField.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 27/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class LogInTextField: UITextField {

        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpField()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpField()
    }
    
    
    private func setUpField() {
        textColor             = .darkGray
        font                  = UIFont(name: "Montserrat-Regular", size: 17)
        backgroundColor       = .white
        layer.borderColor     = UIColor.white.cgColor
        layer.borderWidth     = 1.0
        autocorrectionType    = .no
        layer.cornerRadius    = 25.0
        clipsToBounds         = true
        
        let placeholder       = "Email"
        let placeholderFont   = UIFont(name: "Montserrat-Regular", size: 17)!
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes:
            [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
             NSAttributedString.Key.font: placeholderFont])
        
    }

}
