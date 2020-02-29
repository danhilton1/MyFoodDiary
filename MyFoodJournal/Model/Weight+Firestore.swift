//
//  Weight+Firestore.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 26/12/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import Firebase

enum WeightCollection {
    static let weight = "weight"
    static let unit = "unit"
    static let date = "date"
    static let dateString = "dateString"
    static let dateLastEdited = "dateLastEdited"
}

private let db = Firestore.firestore()

extension Weight {
    
    convenience init(snapshot: QueryDocumentSnapshot) {
        self.init()
        let weightDictionary = snapshot.data()
        self.weight = weightDictionary["weight"] as? Double ?? 0
        self.unit = weightDictionary["unit"] as? String ?? "kg"
        guard let date = weightDictionary["date"] as? Timestamp else { return }
        self.date = date.dateValue()
        self.dateString = weightDictionary["dateString"] as? String
        let dateLastEdited = weightDictionary["dateLastEdited"] as? Timestamp
        self.dateLastEdited = dateLastEdited?.dateValue()
    }
    
    func saveWeight(user: String) {
        
        let wc = WeightCollection.self
        db.collection("users").document(user).collection(wc.weight).document("\(self.dateString!)").setData([
            wc.weight: self.weight,
            wc.unit: self.unit,
            wc.date: self.date,
            wc.dateString: self.dateString!,
            wc.dateLastEdited: self.dateLastEdited!
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document \(self.weight) added with ID: \(self.dateString!)")
            }
        }
    }
    
    static func downloadAllWeight(user: String, anonymous: Bool, completion: @escaping ([Weight]) -> ()) {
        
        let calendar = Calendar.current
        let defaultDateComponents = DateComponents(calendar: calendar, timeZone: .current, year: 2019, month: 1, day: 1)
        var allWeight = [Weight]()
        var dateOfMostRecentEntry: Date?
        let dispatchGroup = DispatchGroup()
        
        db.collection("users").document(user).collection("weight").order(by: "dateLastEdited").getDocuments(source: .cache) {
            (weight, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for weightDocument in weight!.documents {
                    allWeight.append(Weight(snapshot: weightDocument))
                }
                dispatchGroup.enter()
                
                if anonymous {
                    dispatchGroup.leave()
                }
                else {
                    
                    dateOfMostRecentEntry = allWeight.last?.dateLastEdited
 
                    db.collection("users").document(user).collection("weight")
                        .whereField("dateLastEdited", isGreaterThan: dateOfMostRecentEntry?.addingTimeInterval(1) ?? calendar.date(from: defaultDateComponents)!)
                        .order(by: "dateLastEdited")
                        .getDocuments() { (weight, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            }
                            else {
                                
                                if allWeight.isEmpty {
                                    print("New device or reinstalled app - loading all data.")
                                    for weightDocument in weight!.documents {
                                        let weightToAdd = Weight(snapshot: weightDocument)
                                        allWeight.append(weightToAdd)
                                    }
                                }
                                else {
                                    for weightDocument in weight!.documents {
                                        let weightToAdd = Weight(snapshot: weightDocument)
                                        
                                        if weightToAdd.dateLastEdited! > weightToAdd.date {
                                            for weightEntry in allWeight {
                                                if weightToAdd.date == weightEntry.date {
                                                    weightEntry.weight = weightToAdd.weight
                                                    weightEntry.unit = weightToAdd.unit
                                                    weightEntry.dateLastEdited = weightToAdd.dateLastEdited
                                                    print("Entry updated.")
                                                }
                                            }
                                        }
                                        else {
                                            allWeight.append(weightToAdd)
                                            print("\(weightToAdd.weight) added" )
                                        }
                                    }
                                }
                                dispatchGroup.leave()
                            }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(allWeight)
                }
            }
        }
    }
}
