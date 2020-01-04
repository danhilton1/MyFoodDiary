//
//  Food+Firestore.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 12/12/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import Firebase

enum FoodsCollection {
    static let collection = "foods"
    static let name = "name"
    static let meal = "meal"
    static let date = "date"
    static let dateValue = "dateValue"
    static let servingSize = "servingSize"
    static let servingSizeUnit = "servingSizeUnit"
    static let serving = "serving"
    static let calories = "calories"
    static let protein = "protein"
    static let carbs = "carbs"
    static let fat = "fat"
    static let isDeleted = "isDeleted"
}

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
        self.servingSize = "\(foodDictionary["servingSize"] ?? "100")"
        self.servingSizeUnit = foodDictionary["servingSizeUnit"] as? String ?? "g"
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
            fc.servingSizeUnit: self.servingSizeUnit,
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
        let dispatchGroup = DispatchGroup()
        
        
        db.collection("users").document(user).collection("foods").order(by: "dateValue").getDocuments(source: .cache) { (foods, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for foodDocument in foods!.documents {
                    allFood.append(Food(snapshot: foodDocument))
                }
                //print(allFood.count)
                dateOfMostRecentEntry = allFood.last?.dateValue
                    //print(dateOfMostRecentEntry)
                dispatchGroup.enter()
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
                            dispatchGroup.leave()
                        }
                }
                dispatchGroup.notify(queue: .main) {
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
