//
//  Food.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
//import RealmSwift


class Food {
    
    // 100g values
    var date: String?
    var dateCreated: Date?
    var dateLastEdited: Date?
    var meal: String?
    var name: String? = ""
    var servingSize: String = "100"
    var servingSizeUnit: String = "g"
    var serving: Double = 1
    var totalServing: Double {
        return (Double(servingSize.filter("01234567890.".contains)) ?? 100) * serving
    }
    var calories: Int = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    var isDeleted = false
    var numberOfTimesAdded = 0
    
    
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
        
        var intValue: Int {
            switch self {
            case .breakfast:
                return 0
            case .lunch:
                return 1
            case .dinner:
                return 2
            case .other:
                return 3
            }
        }
    }
    
    
    func copy(with zone: NSZone? = nil) -> Food {
        let copy = Food()
        copy.date = self.date
        copy.dateCreated = self.dateCreated
        copy.dateLastEdited = self.dateLastEdited
        copy.meal = self.meal
        copy.name = self.name
        copy.servingSize = self.servingSize
        copy.servingSizeUnit = self.servingSizeUnit
        copy.serving = self.serving
        copy.calories = self.calories
        copy.protein = self.protein
        copy.carbs = self.carbs
        copy.fat = self.fat
        copy.isDeleted = self.isDeleted
        copy.numberOfTimesAdded = self.numberOfTimesAdded
        return copy
    }
    
    
    
    
}



struct FoodDatabase: Codable {
    
    let product: Product
    
}

struct FoodSearchDatabase: Codable {
    let products: [Products]
}

struct Products: Codable {
    let nutriments: NutrimentsEdit
    let productName: String
    let servingSize: String?
    
    enum CodingKeys: String, CodingKey {

        case nutriments = "nutriments"
        case productName = "product_name"
        case servingSize = "serving_size"

    }
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

struct NutrimentsEdit: Codable {
    
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
    let protein100g: String
    let carbs100g: String
    let fat100g: String
    
    
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
