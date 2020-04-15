//
//  Weight+Firestore.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 26/12/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import Foundation
import Firebase


private let db = Firestore.firestore()

extension Weight {
    
    convenience init(snapshot: QueryDocumentSnapshot) {
        self.init()
        let WC = WeightConstants.self
        let weightDictionary = snapshot.data()
        self.weight = weightDictionary[WC.weight] as? Double ?? 0
        self.unit = weightDictionary[WC.unit] as? String ?? "kg"
        guard let date = weightDictionary[WC.date] as? Timestamp else { return }
        self.date = date.dateValue()
        self.dateString = weightDictionary[WC.dateString] as? String
        let dateLastEdited = weightDictionary[WC.dateLastEdited] as? Timestamp
        self.dateLastEdited = dateLastEdited?.dateValue()
    }
    
    
    func saveWeight(user: String) {
        
        let wc = WeightConstants.self
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
    
    
    static func downloadAllWeight(user: String, anonymous: Bool, completion: @escaping (Result<[Weight],DatabaseError>) -> ()) {
        
        let calendar = Calendar.current
        let defaultDateComponents = DateComponents(calendar: calendar, timeZone: .current, year: 2019, month: 1, day: 1)
        var allWeight = [Weight]()
        var dateOfMostRecentEntry: Date?
        let dispatchGroup = DispatchGroup()
        let WC = WeightConstants.self
        
        db.collection("users").document(user).collection(WC.weight).order(by: WC.dateLastEdited).getDocuments(source: .cache) {
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
 
                    db.collection("users").document(user).collection(WC.weight)
                        .whereField(WC.dateLastEdited, isGreaterThan: dateOfMostRecentEntry?.addingTimeInterval(1) ?? calendar.date(from: defaultDateComponents)!)
                        .order(by: WC.dateLastEdited)
                        .getDocuments() { (weight, error) in
                            
                            if let error = error {
                                print("Error getting documents: \(error)")
                                completion(.failure(.unableToDownloadItems))
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
                    completion(.success(allWeight))
                }
            }
        }
    }
}
