//
//  Person.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 02/03/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

struct Person {
    
    var gender: String
    var age: Int
    var height: Double
    var heightFeet: Int?
    var heightInches: Int?
    var heightUnit: HeightUnit
    var weight: Double
    var goalWeight: Double
    var weightUnit: WeightUnit
    var activityLevel: Int
    var activityMultiplier: Double
    
    
    enum WeightUnit {
        case kg
        case lbs
        case st
        
        var stringValue: String {
            switch self {
            case .kg:
                return "kg"
            case .lbs:
                return "lbs"
            case .st:
                return "st"
            }
        }
    }
    
    enum HeightUnit {
        case ft
        case cm
        
        var stringValue: String {
            switch self {
            case .ft:
                return "ft"
            case .cm:
                return "cm"
            }
        }
    }
    
}
