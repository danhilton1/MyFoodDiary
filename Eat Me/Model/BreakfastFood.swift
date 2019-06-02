//
//  BreakfastFood.swift
//  Eat Me
//
//  Created by Daniel Hilton on 29/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import RealmSwift


class BreakfastFood: Object {
    
    @objc dynamic var name: String? = ""
    @objc dynamic var calories: NSNumber? = NSNumber(value: 0)
    @objc dynamic var protein: NSNumber? = NSNumber(value: 0.0)
    @objc dynamic var carbs: NSNumber? = NSNumber(value: 0.0)
    @objc dynamic var fat: NSNumber? = NSNumber(value: 0.0)
    
    
    func updateProperties(name: String?, calories: NSNumber?, protein: NSNumber?, carbs: NSNumber?, fat: NSNumber?) {
        
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        
        
    }
    
    
    
}
