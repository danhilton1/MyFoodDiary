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
    static let uuid = "uuid"
    static let name = "name"
    static let meal = "meal"
    static let date = "date"
    static let dateCreated = "dateCreated"
    static let dateLastEdited = "dateLastEdited"
    static let servingSize = "servingSize"
    static let servingSizeUnit = "servingSizeUnit"
    static let serving = "serving"
    static let calories = "calories"
    static let protein = "protein"
    static let carbs = "carbs"
    static let fat = "fat"
    static let isDeleted = "isDeleted"
//    static let numberOfTimesAdded = "numberOfTimesAdded"
}

private let db = Firestore.firestore()


extension Food {

    convenience init(snapshot: QueryDocumentSnapshot) {
        self.init()
        let foodDictionary = snapshot.data()
        self.uuid = foodDictionary["uuid"] as! String
        self.name = foodDictionary["name"] as? String
        self.meal = foodDictionary["meal"] as? String
        self.date = foodDictionary["date"] as? String
        let dateCreated = foodDictionary["dateCreated"] as? Timestamp
        self.dateCreated = dateCreated?.dateValue()
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
//        self.numberOfTimesAdded = foodDictionary["numberOfTimesAdded"] as! Int
    }
    
    func saveFood(user: String) {
        let fc = FoodsCollection.self
        let name = self.name?.replacingOccurrences(of: "/", with: "")
        db.collection("users").document(user).collection(fc.collection).document("\(name!) \(self.uuid)").setData([
            fc.uuid: self.uuid,
            fc.name: self.name!,
            fc.meal: self.meal ?? Food.Meal.other,
            fc.date: self.date!,
            fc.dateCreated: self.dateCreated ?? Date(),
            fc.dateLastEdited: self.dateLastEdited ?? Date(),
            fc.servingSize: self.servingSize,
            fc.servingSizeUnit: self.servingSizeUnit,
            fc.serving: self.serving,
            fc.calories: self.calories,
            fc.protein: self.protein,
            fc.carbs: self.carbs,
            fc.fat: self.fat,
            fc.isDeleted: false,
//            fc.numberOfTimesAdded: self.numberOfTimesAdded
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
//                    print(Food(snapshot: foodDocument).name)
                }
                dispatchGroup.enter()
                
                if anonymous {
                    dispatchGroup.leave()
                }
                else {
                    //print(allFood.count)
                    dateOfMostRecentEntry = allFood.last?.dateLastEdited
//                    print(dateOfMostRecentEntry)
                    
                    db.collection("users").document(user).collection("foods")
                        .whereField("dateLastEdited", isGreaterThan: dateOfMostRecentEntry?.addingTimeInterval(1) ?? calendar.date(from: defaultDateComponents)!)
                        .order(by: "dateLastEdited")
                        .getDocuments() { (foods, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            }
                            else {
                                // if allFood is empty then this means user is either using a new device, has deleted and reinstalled the app, or has not made any entries. If so, add all entries from database.
                                if allFood.isEmpty {
                                    print("New device or reinstalled app - loading all data.")
                                    for foodDocument in foods!.documents {
                                        let foodToAdd = Food(snapshot: foodDocument)
                                        allFood.append(foodToAdd)
                                    }
                                }
                                else {
                                    for foodDocument in foods!.documents {
                                        let foodToAdd = Food(snapshot: foodDocument)
                                        
                                        // Check if the food already exists and just needs updating rather than adding again.
                                        if foodToAdd.dateLastEdited! > foodToAdd.dateCreated! {
                                            var uuidArray = [String]()
                                            for food in allFood {
                                                uuidArray.append(food.uuid)
                                                
                                                if foodToAdd.uuid == food.uuid {
                                                    food.dateLastEdited = foodToAdd.dateLastEdited
//                                                    food.date = foodToAdd.date
                                                    food.meal = foodToAdd.meal
                                                    food.servingSize = foodToAdd.servingSize
                                                    food.servingSizeUnit = foodToAdd.servingSizeUnit
                                                    food.serving = foodToAdd.serving
                                                    food.calories = foodToAdd.calories
                                                    food.protein = foodToAdd.protein
                                                    food.carbs = foodToAdd.carbs
                                                    food.fat = foodToAdd.fat
                                                    food.isDeleted = foodToAdd.isDeleted
//                                                    food.numberOfTimesAdded = foodToAdd.numberOfTimesAdded
                                                    print("\(foodToAdd.name!) updated.")
                                                    
                                                }
                                                // doesn't work if an entry has been permanently deleted.
                                            }
                                            if !uuidArray.contains(foodToAdd.uuid) {
                                                allFood.append(foodToAdd)
                                                print("\(foodToAdd.name!) edited and added.")
                                            }
                                        }
                                        else {
                                            allFood.append(foodToAdd)
                                            print("\(foodToAdd.name!) added")
                                        }
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
