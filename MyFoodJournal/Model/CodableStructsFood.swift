//
//  CodableStructsFood.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 29/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

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

struct Nutriments: Codable {
    
    let energy100g: Int
    var calories100g: Int {
        return Int(round(Double(energy100g) / 4.184))
    }
    let protein100g: Double
    let carbs100g: Double
    let fat100g: Double
    let sugars100g: Double?
    let saturatedFat100g: Double?
    let fibre100g: Double?
    
    
    enum CodingKeys: String, CodingKey {

        case energy100g = "energy_100g"
        case protein100g = "proteins_100g"
        case carbs100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case sugars100g = "sugars_100g"
        case saturatedFat100g = "saturated-fat_100g"
        case fibre100g = "fiber_100g"

    }
}
