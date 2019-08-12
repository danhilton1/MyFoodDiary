//
//  Food.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import RealmSwift

class Food: Object {
    
    enum Meal: Int {
        
        case breakfast
        case lunch
        case dinner
        case other
        
        var stringValue: String {
            switch self {
            case .breakfast:
                return "Breakfast"
            case .lunch:
                return "Lunch"
            case .dinner:
                return "Dinner"
            case .other:
                return "Other"
            }
        }
    }
    
    @objc dynamic var date: String?
    @objc dynamic var meal: String?
    @objc dynamic var name: String? = ""
    @objc dynamic var servingSize: Int = 0
    @objc dynamic var serving: Double = 0.0
    @objc dynamic var calories: NSNumber? = NSNumber(value: 0)
    @objc dynamic var protein: NSNumber? = NSNumber(value: 0.0)
    @objc dynamic var carbs: NSNumber? = NSNumber(value: 0.0)
    @objc dynamic var fat: NSNumber? = NSNumber(value: 0.0)
    
    
    func updateProperties(date: String?, meal: Meal, name: String?, servingSize: Int, serving: Double, calories: NSNumber?, protein: NSNumber?, carbs: NSNumber?, fat: NSNumber?) {
        
        self.date = date
        self.meal = meal.stringValue
        self.name = name
        self.servingSize = servingSize
        self.serving = serving
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat

        
    }
    
}

struct Product: Decodable {
    
    let nutriments: Nutriments
    let product_name: String
    let serving_size: String
    
}

struct DatabaseFood: Decodable {
    
    let product: Product
    let status: Int
    
}

struct Nutriments: Decodable {
    
    let energy_serving: Int
    var calories: Int {
        return Int(round(Double(energy_serving) / 4.184))
    }
    let proteins_serving: Double
    let carbohydrates_serving: Double
    let fat_serving: Double
    
    
    let energy_100g: Int
    var calories_100g: Int {
        return Int(round(Double(energy_100g) / 4.184))
    }
    let proteins_100g: Double
    let carbohydrates_100g: Double
    let fat_100g: Double
    
}
