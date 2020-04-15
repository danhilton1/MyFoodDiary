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
        let FC = FoodConstants.self
        let foodDictionary = snapshot.data()
        self.uuid = foodDictionary[FC.uuid] as! String
        self.name = foodDictionary[FC.name] as? String
        self.meal = foodDictionary[FC.meal] as? String
        self.date = foodDictionary[FC.date] as? String
        let dateCreated = foodDictionary[FC.dateCreated] as? Timestamp
        self.dateCreated = dateCreated?.dateValue()
        let dateLastEdited = foodDictionary[FC.dateLastEdited] as? Timestamp
        self.dateLastEdited = dateLastEdited?.dateValue()
        self.servingSize = "\(foodDictionary[FC.servingSize] ?? "100")"
        self.servingSizeUnit = foodDictionary[FC.servingSizeUnit] as? String ?? "g"
        self.serving = (foodDictionary[FC.serving] as? Double) ?? 1
        self.calories = foodDictionary[FC.calories] as! Int
        self.protein = foodDictionary[FC.protein] as! Double
        self.carbs = foodDictionary[FC.carbs] as! Double
        self.fat = foodDictionary[FC.fat] as! Double
        self.sugar = foodDictionary[FC.sugar] as? Double ?? 0
        self.saturatedFat = foodDictionary[FC.saturatedFat] as? Double ?? 0
        self.fibre = foodDictionary[FC.fibre] as? Double ?? 0
        self.isDeleted = foodDictionary[FC.isDeleted] as! Bool
    }
    
    func saveFood(user: String) {
        let fc = FoodConstants.self
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
            fc.sugar: self.sugar,
            fc.saturatedFat: self.saturatedFat,
            fc.fibre: self.fibre,
            fc.isDeleted: false
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(self.name!)")
            }
        }
    }
    
    
    static func downloadAllFood(user: String, anonymous: Bool, completion: @escaping (Result<[Food],DatabaseError>) -> ()) {
        
        let calendar = Calendar.current
        let defaultDateComponents = DateComponents(calendar: calendar, timeZone: .current, year: 2019, month: 1, day: 1)
        var allFood = [Food]()
        var dateOfMostRecentEntry: Date?
        let dispatchGroup = DispatchGroup()
        
        
        db.collection("users").document(user).collection("foods").order(by: "dateLastEdited").getDocuments(source: .cache) { (foods, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(.unableToDownloadItems))
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
                    
                    dateOfMostRecentEntry = allFood.last?.dateLastEdited
                    
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
                                                    food.meal = foodToAdd.meal
                                                    food.servingSize = foodToAdd.servingSize
                                                    food.servingSizeUnit = foodToAdd.servingSizeUnit
                                                    food.serving = foodToAdd.serving
                                                    food.calories = foodToAdd.calories
                                                    food.protein = foodToAdd.protein
                                                    food.carbs = foodToAdd.carbs
                                                    food.fat = foodToAdd.fat
                                                    food.sugar = foodToAdd.sugar
                                                    food.saturatedFat = foodToAdd.saturatedFat
                                                    food.fibre = foodToAdd.fibre
                                                    food.isDeleted = foodToAdd.isDeleted

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
                    completion(.success(allFood))
                }
            }
        }
    }
}
