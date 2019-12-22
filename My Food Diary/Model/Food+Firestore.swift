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
    
    func saveFood(user: String) {
        let fc = FoodsCollection.self
        
        db.collection("users").document(user).collection(fc.collection).document(self.name!).setData([
            fc.name: self.name!,
            fc.meal: self.meal ?? Food.Meal.other,
            fc.date: self.date!,
            fc.dateValue: self.dateValue ?? Date(),
            fc.servingSize: self.servingSize,
            fc.serving: self.serving,
            fc.calories: self.calories,
            fc.protein: self.protein,
            fc.carbs: self.carbs,
            fc.fat: self.fat,
            fc.isDeleted: false
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(self.name!)")
            }
        }
    }
    
    
    static func downloadAllFood(user: String, completion: @escaping ([Food]) -> ()) {
        
        let calendar = Calendar.current
        let defaultDateComponents = DateComponents(calendar: calendar, timeZone: .current, year: 2019, month: 1, day: 1)
        var allFood = [Food]()
        var dateOfMostRecentEntry: Date?
        
        db.collection("users").document(user).collection("foods").order(by: "dateValue").getDocuments(source: .cache) { (foods, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for foodDocument in foods!.documents {
                    allFood.append(Food(snapshot: foodDocument))
                }
                dateOfMostRecentEntry = allFood.last?.dateValue
                
                db.collection("users").document(user).collection("foods")
                    .whereField("dateValue", isGreaterThan: dateOfMostRecentEntry?.addingTimeInterval(1) ?? calendar.date(from: defaultDateComponents)!)
                    .order(by: "dateValue")
                    .getDocuments() { (foods, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    }
                    else {
                        for foodDocument in foods!.documents {
                            allFood.append(Food(snapshot: foodDocument))
                            print(Food(snapshot: foodDocument).name!)
                        }
                    }
                    completion(allFood)
                }
                
            }
        }
        
        
        
    }
    
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
