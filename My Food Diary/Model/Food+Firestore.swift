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
    static let dateLastEdited = "dateLastEdited"
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
        let dateLastEdited = foodDictionary["dateLastEdited"] as? Timestamp
        self.dateLastEdited = dateLastEdited?.dateValue()
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
            fc.dateLastEdited: self.dateLastEdited ?? Date(),
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
    
    
    static func downloadAllFood(user: String, anonymous: Bool, completion: @escaping ([Food]) -> ()) {
        
        let calendar = Calendar.current
        let defaultDateComponents = DateComponents(calendar: calendar, timeZone: .current, year: 2019, month: 1, day: 1)
        var allFood = [Food]()
        var dateOfMostRecentEntry: Date?
        let dispatchGroup = DispatchGroup()
        
        
        db.collection("users").document(user).collection("foods").order(by: "dateLastEdited").getDocuments(source: .cache) { (foods, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for foodDocument in foods!.documents {
                    allFood.append(Food(snapshot: foodDocument))
                }
                dispatchGroup.enter()
                if anonymous {
                    dispatchGroup.leave()
                }
                else {
                    //print(allFood.count)
                    dateOfMostRecentEntry = allFood.last?.dateLastEdited
                    //print(dateOfMostRecentEntry)
                    
                    db.collection("users").document(user).collection("foods")
                        .whereField("dateLastEdited", isGreaterThan: dateOfMostRecentEntry?.addingTimeInterval(1) ?? calendar.date(from: defaultDateComponents)!)
                        .order(by: "dateLastEdited")
                        .getDocuments() { (foods, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            }
                            else {
                                for foodDocument in foods!.documents {
                                    let foodToAdd = Food(snapshot: foodDocument)
                                    
                                    // Check if the food already exists and just needs updating rather than adding again.
                                    if foodToAdd.dateLastEdited! > foodToAdd.dateValue! {
                                        for food in allFood {
                                            if foodToAdd.name == food.name {
                                                food.dateLastEdited = foodToAdd.dateLastEdited
                                                food.meal = foodToAdd.meal
                                                food.servingSize = foodToAdd.servingSize
                                                food.servingSizeUnit = foodToAdd.servingSizeUnit
                                                food.serving = foodToAdd.serving
                                                food.calories = foodToAdd.calories
                                                food.protein = foodToAdd.protein
                                                food.carbs = foodToAdd.carbs
                                                food.fat = foodToAdd.fat
                                                food.isDeleted = foodToAdd.isDeleted
                                                print("\(foodToAdd) updated.")
                                            }
                                            // if new food has been added AND edited before synced to other it needs to be ADDED to allFood instead of updating existing entry
                                        }
                                    }
                                    else {
                                        allFood.append(foodToAdd)
                                        print(foodToAdd.name!)
                                    }
                                }
                                dispatchGroup.leave()
                            }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(allFood)
                }
            }
            
        }
        
    }
    
    
}
