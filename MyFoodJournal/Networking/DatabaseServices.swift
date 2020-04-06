//
//  DatabaseServices.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 29/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation


struct DatabaseServices {
    
    
    static func retrieveDataFromBarcodeEntry(barcode: String, completion: @escaping (Result<Food, DatabaseError>) -> ()) {
        
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidBarcode))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidBarcode))
                return
            }
            
            do {
                let scannedFood = try JSONDecoder().decode(FoodDatabase.self, from: data)
                let workingCopy = Food()
                workingCopy.name = scannedFood.product.productName
                
                if scannedFood.product.servingSize == nil {
                    // If no serving size information is available, use a default value of 100g
                    workingCopy.servingSizeUnit = "g"
                    workingCopy.calories = scannedFood.product.nutriments.calories100g
                    workingCopy.protein = scannedFood.product.nutriments.protein100g
                    workingCopy.carbs = scannedFood.product.nutriments.carbs100g
                    workingCopy.fat = scannedFood.product.nutriments.fat100g
                    workingCopy.sugar = scannedFood.product.nutriments.sugars100g ?? 0
                    workingCopy.saturatedFat = scannedFood.product.nutriments.saturatedFat100g ?? 0
                    workingCopy.fibre = scannedFood.product.nutriments.fibre100g ?? 0
                }
                else {
                    let servingSize = scannedFood.product.servingSize ?? "100"
                    let servingSizeNumber = Double(servingSize.filter("01234567890.".contains)) ?? 100
                    let servingUnit = servingSize.filter("abcdefghijklmnopqrstuvwxyz".contains)
                    workingCopy.servingSize = servingSize.filter("01234567890.".contains)
                    workingCopy.servingSizeUnit = servingUnit
                    workingCopy.calories = Int((Double(scannedFood.product.nutriments.calories100g) / 100) * servingSizeNumber)
                    workingCopy.protein = ((scannedFood.product.nutriments.protein100g) / 100) * servingSizeNumber
                    workingCopy.carbs = ((scannedFood.product.nutriments.carbs100g) / 100) * servingSizeNumber
                    workingCopy.fat = ((scannedFood.product.nutriments.fat100g) / 100) * servingSizeNumber
                    workingCopy.sugar = ((scannedFood.product.nutriments.sugars100g ?? 0) / 100) * servingSizeNumber
                    workingCopy.saturatedFat = ((scannedFood.product.nutriments.saturatedFat100g ?? 0) / 100) * servingSizeNumber
                    workingCopy.fibre = ((scannedFood.product.nutriments.fibre100g ?? 0) / 100) * servingSizeNumber
                }
                
                completion(.success(workingCopy))
                
            }
            catch {
                print(error)
                completion(.failure(.invalidBarcode))
            }
        }.resume()
    }
    
    
    static func getItems(withKeywords searchWords: String, completion: @escaping (Result<[Food], DatabaseError>) -> ()) {
        
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
            
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unableToFindItem))
                return
            }
            
            do {
                // Using JSONSerialization instead of JSONDecoder as the data type retrieved from API is not always consistent
                // so type 'Any' is required
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let products = json["products"] as? [[String: Any]] {
                        
                        for product in products {

                            if let nutrients = product["nutriments"] as? [String: Any],
                               let productName = product["product_name"] as? String,
                                let energy = nutrients["energy_100g"],
                                let protein = nutrients["proteins_100g"],
                                let carbs = nutrients["carbohydrates_100g"],
                                let fat = nutrients["fat_100g"] {  // Unable to cast nutrients to type as JSON data can vary
                               
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
                        completion(.success(searchFoodList))
                    }
                }
            }
            catch {
                print(error)
                completion(.failure(.unableToFindItem))
            }
        }.resume()
        
    }
}
