//
//  DatabaseServices.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 29/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

struct DatabaseServices {
    
    
    static func getItems(withKeywords searchWords: String, completion: @escaping (Bool, [Food]) -> ()) {
        
        var completed = false
        var countryIdentifier = Locale.current.identifier
        
        if countryIdentifier == "en_GB" {
            countryIdentifier = "uk"
        }
        else if countryIdentifier == "en_US" {
            countryIdentifier = "us"
        }
        
        let urlString = "https://\(countryIdentifier).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(searchWords)&sort_by=product_name&page_size=100&action=display&json=1"
        
        guard let url = URL(string: urlString) else { return }
        
        var searchFoodList = [Food]()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let products = json["products"] as? [[String: Any]] {
                        
                        for product in products {

                            if let nutrients = product["nutriments"] as? [String: Any],
                               let productName = product["product_name"] as? String,
                                let energy = nutrients["energy_100g"],
                                let protein = nutrients["proteins_100g"],
                                let carbs = nutrients["carbohydrates_100g"],
                                let fat = nutrients["fat_100g"] {  //Unable to cast nutrients to type as JSON data can vary
                               
                                let sugar = nutrients["sugars_100g"] ?? 0.0
                                let saturatedFat = nutrients["saturated-fat_100g"] ?? 0.0
                                let fibre = nutrients["fiber_100g"] ?? 0.0
                            
                                // Make sure item has name, calories, protein, carbs and fat values
                                if !productName.isEmpty && !"\(energy)".isEmpty && !"\(protein)".isEmpty && !"\(carbs)".isEmpty && !"\(fat)".isEmpty {
                                    
                                    // Store JSON values in a string in order to access and convert to Int or Double
                                    let energyString = "\(energy)"
                                    let calories = Int(round(Double(energyString)! / 4.184))
                                    let proteinString = "\(protein)"
                                    let carbsString = "\(carbs)"
                                    let fatString = "\(fat)"
                                    let sugarString = "\(sugar)"
                                    let saturatedFatString = "\(saturatedFat)"
                                    let fibreString = "\(fibre)"
                                    var trimmedServingSize = ""
                                    
                                    let food = Food()
                                    
                                    if let servingSize = product["serving_size"] as? String {

                                        // Only use the first set of numbers in servingSize
                                        for character in servingSize {
                                            if character == "g" || character == " " {
                                                break
                                            }
                                            else {
                                                trimmedServingSize.append(character)
                                            }
                                        }
                                        if trimmedServingSize.filter("01234567890.".contains) == "" {
                                            trimmedServingSize = servingSize
                                        }
                                        let servingSizeNumber = Double(trimmedServingSize.filter("01234567890.".contains)) ?? 100
                                        if servingSize.contains("ml") {
                                            food.servingSizeUnit = "ml"
                                        }
                                        food.servingSize = trimmedServingSize.filter("01234567890.".contains)
                                        food.name = productName
                                        food.calories = Int((Double(calories) / 100) * servingSizeNumber)
                                        food.protein = ((Double(proteinString) ?? 0) / 100.0) * servingSizeNumber
                                        food.carbs = ((Double(carbsString) ?? 0) / 100.0) * servingSizeNumber
                                        food.fat = ((Double(fatString) ?? 0) / 100.0) * servingSizeNumber
                                        food.sugar = ((Double(sugarString) ?? 0) / 100.0) * servingSizeNumber
                                        food.saturatedFat = ((Double(saturatedFatString) ?? 0) / 100.0) * servingSizeNumber
                                        food.fibre = ((Double(fibreString) ?? 0) / 100.0) * servingSizeNumber
                                        
                                        searchFoodList.append(food)
                                    }
                                    else {

                                        food.name = productName
                                        food.calories = calories
                                        food.protein = Double(proteinString) ?? 0
                                        food.carbs = Double(carbsString) ?? 0
                                        food.fat = Double(fatString) ?? 0
                                        food.sugar = Double(sugarString) ?? 0
                                        food.saturatedFat = Double(saturatedFatString) ?? 0
                                        food.fibre = Double(fibreString) ?? 0
                                        
                                        searchFoodList.append(food)
                                    }
                                }
                            }
                        }
                        completed = true
                        DispatchQueue.main.async {
                            completion(true, searchFoodList)
                        }
                    }
                }
            }
            catch {
                print(error)
                DispatchQueue.main.async {
                    completion(false, searchFoodList)
                }
            }
        }.resume()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            if !completed {
                completion(false, searchFoodList)
            }
        }
    }
}
