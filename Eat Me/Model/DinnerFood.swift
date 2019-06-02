//
//  DinnerFood.swift
//  Eat Me
//
//  Created by Daniel Hilton on 29/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import RealmSwift

class DinnerFood {
    
    @objc dynamic var name: String?
    @objc dynamic var calories: String?
    @objc dynamic var protein: String?
    @objc dynamic var carbs: String?
    @objc dynamic var fat: String?
    
    func updateProperties(name: String?, calories: String?, protein: String?, carbs: String?, fat: String?) {
        
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        
        
    }
    
}
