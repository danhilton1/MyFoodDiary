//
//  Food+Firestore.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 12/12/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import Firebase

private let db = Firestore.firestore()

extension Food {

    convenience init(snapshot: QueryDocumentSnapshot) {
        self.init()
        let foodDictionary = snapshot.data()
        self.name = foodDictionary["name"] as? String
        self.meal = foodDictionary["meal"] as? String
        self.date = foodDictionary["date"] as? String
        let dateValue = foodDictionary["dateValue"] as? Timestamp
        self.dateValue = dateValue?.dateValue()
        self.servingSize = "\(foodDictionary["servingSize"] ?? "100 g")"
        self.serving = (foodDictionary["serving"] as? Double) ?? 1
        self.calories = foodDictionary["calories"] as! Int
        self.protein = foodDictionary["protein"] as! Double
        self.carbs = foodDictionary["carbs"] as! Double
        self.fat = foodDictionary["fat"] as! Double
        self.isDeleted = foodDictionary["isDeleted"] as! Bool
    }
    
    static func downloadAllFood(user: String, completion: @escaping ([Food]) -> ()) {
        
        var allFood = [Food]()
        
        db.collection("users").document(user).collection("foods").order(by: "dateValue").getDocuments() { (foods, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for foodDocument in foods!.documents {
                    allFood.append(Food(snapshot: foodDocument))
                    
//                    let foodDictionary = foodDocument.data()
//                    let food = Food()
//                    food.name = "\(foodDictionary["name"] ?? "Food")"
//                    food.meal = "\(foodDictionary["meal"] ?? Food.Meal.breakfast.stringValue)"
//                    food.date = "\(foodDictionary["date"] ?? formatter.string(from: Date()))"
//                    let dateValue = foodDictionary["dateValue"] as? Timestamp
//                    food.dateValue = dateValue?.dateValue()
//                    food.servingSize = "\(foodDictionary["servingSize"] ?? "100 g")"
//                    food.serving = (foodDictionary["serving"] as? Double) ?? 1
//                    food.calories = foodDictionary["calories"] as! Int
//                    food.protein = foodDictionary["protein"] as! Double
//                    food.carbs = foodDictionary["carbs"] as! Double
//                    food.fat = foodDictionary["fat"] as! Double
//                    food.isDeleted = foodDictionary["isDeleted"] as! Bool
                    
//                    allFood.append(food)
                }
            }
            completion(allFood)
        }
    }
    
    
}
