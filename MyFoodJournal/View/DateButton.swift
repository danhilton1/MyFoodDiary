//
//  DateButton.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 18/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class DateButton: UIButton {

    var dateView = UIView()
    var toolBarView = UIView()

    override var inputView: UIView {

        get {
            return self.dateView
        }
        set {
            self.dateView = newValue
            self.becomeFirstResponder()
        }

    }

   override var inputAccessoryView: UIView {
         get {
            return self.toolBarView
        }
        set {
            self.toolBarView = newValue
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

}
