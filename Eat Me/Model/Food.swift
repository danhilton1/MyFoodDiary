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
    // 100g values
    @objc dynamic var date: String?
    @objc dynamic var meal: String?
    @objc dynamic var name: String? = ""
    @objc dynamic var servingSize: String = "100g"
    @objc dynamic var serving: Double = 1
    @objc dynamic var totalServing: Double {
        return (Double(servingSize.filter("01234567890.".contains)) ?? 100) * serving
    }
    @objc dynamic var calories: Int = 0
    @objc dynamic var protein: Double = 0
    @objc dynamic var carbs: Double = 0
    @objc dynamic var fat: Double = 0
    
    
    func updateProperties(date: String?, meal: Meal, name: String?, servingSize: String, serving: Double, calories: Int, protein: Double, carbs: Double, fat: Double) {
        
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
    
    func copy(with zone: NSZone? = nil) -> Food {
        let copy = Food()
        copy.date = self.date
        copy.meal = self.meal
        copy.name = self.name
        copy.servingSize = self.servingSize
        copy.serving = self.serving
        copy.calories = self.calories
        copy.protein = self.protein
        copy.carbs = self.carbs
        copy.fat = self.fat
        return copy
    }
    
    
}



struct FoodDatabase: Codable {
    
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
// GET RID OF SERVING. JUST USE COMPUTED TO GET SERVING VALUES. JSON DECODER SNAKE INSTEAD OF CODING KEY ENUM.
struct Nutriments: Codable {
    
//    let energyServing: Int
//    var calories: Int {
//        return Int(round(Double(energyServing) / 4.184))
//    }
//    let proteinServing: Double
//    let carbServing: Double
//    let fatServing: Double
    
    
    let energy100g: Int
    var calories100g: Int {
        return Int(round(Double(energy100g) / 4.184))
    }
    let protein100g: Double
    let carbs100g: Double
    let fat100g: Double
    
    enum CodingKeys: String, CodingKey {

//        case energyServing = "energy_serving"
//        case proteinServing = "proteins_serving"
//        case carbServing = "carbohydrates_serving"
//        case fatServing = "fat_serving"

        case energy100g = "energy_100g"
        case protein100g = "proteins_100g"
        case carbs100g = "carbohydrates_100g"
        case fat100g = "fat_100g"

    }
    
}
