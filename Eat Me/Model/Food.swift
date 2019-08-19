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
    @objc dynamic var servingSize: String = ""
    @objc dynamic var serving: Double = 0.0
    @objc dynamic var calories: NSNumber? = NSNumber(value: 0)
    @objc dynamic var protein: NSNumber? = NSNumber(value: 0.0)
    @objc dynamic var carbs: NSNumber? = NSNumber(value: 0.0)
    @objc dynamic var fat: NSNumber? = NSNumber(value: 0.0)
    
    
    func updateProperties(date: String?, meal: Meal, name: String?, servingSize: String, serving: Double, calories: NSNumber?, protein: NSNumber?, carbs: NSNumber?, fat: NSNumber?) {
        
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
    
//    func copy(with zone: NSZone? = nil) -> Any {
//        let copy = Food(value: self)
//        return copy
//    }
    
}


struct DatabaseFood: Codable {
    
    let product: Product
    
}

struct Product: Codable {
    
    let nutriments: Nutriments
    let productName: String
    let servingSize: String?
    
    enum CodingKeys: String, CodingKey {
        
        case nutriments = "nutriments"
        case productName = "product_name"
        case servingSize = "serving_size"
        
    }
    
}

struct Nutriments: Codable {
    
    let energyServing: Int
    var calories: Int {
        return Int(round(Double(energyServing) / 4.184))
    }
    let proteinServing: Double
    let carbServing: Double
    let fatServing: Double
    
    
    let energy100g: Int
    var calories100g: Int {
        return Int(round(Double(energy100g) / 4.184))
    }
    let protein100g: Double
    let carbs100g: Double
    let fat100g: Double
    
    enum CodingKeys: String, CodingKey {
        
        case energyServing = "energy"
        case proteinServing = "proteins"
        case carbServing = "carbohydrates"
        case fatServing = "fat"
        
        case energy100g = "energy_100g"
        case protein100g = "proteins_100g"
        case carbs100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        
    }
    
}
