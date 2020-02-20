//
//  NewEntryPopUpViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 28/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NewEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var enterManuallyButton: UIButton!
    @IBOutlet weak var historyLabel: UILabel!
    

    
    
    var date: Date?
    var meal = Food.Meal.breakfast
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    var allFood: [Food]?
    //private var foodList: Results<Food>?
    private var sortedFood = [Food]()
    private var sortedFoodCopy = [Food]()
    
    
    enum Segues {
        static let goToManualEntry = "GoToManualEntry"
        static let goToBarcodeScanner = "GoToBarcodeScanner"
        static let goToFoodDetail = "GoToFoodDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        setUpNavBar()
        
        //foodList = realm.objects(Food.self)
        setUpSortedFoodList()
        sortedFoodCopy = sortedFood
        
        tableView.tableFooterView = UIView()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presentingViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }
    
    func setUpNavBar() {
        let dismissButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        dismissButton.setImage(UIImage(named: "plus-icon"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
        dismissButton.imageView?.clipsToBounds = false
        dismissButton.imageView?.contentMode = .center
        let barButton = UIBarButtonItem(customView: dismissButton)
        navigationItem.leftBarButtonItem = barButton
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
    }

    @objc func dismissButtonTapped(_ sender: UIBarButtonItem) {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }


    func setUpSortedFoodList() {
        var foodDictionary = [String: Food]()
        for food in allFood! {
            foodDictionary[food.name!] = food
        }
        sortedFood = foodDictionary.values.sorted { (food1, food2) -> Bool in
            guard
                let food1Date = food1.dateCreated,
                let food2Date = food2.dateCreated
            else {
                return false
            }
            return food1Date > food2Date
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.goToManualEntry {
            let destVC = segue.destination as! ManualEntryViewController
            destVC.delegate = delegate
            destVC.mealDelegate = mealDelegate
            destVC.date = date
            destVC.selectedSegmentIndex = meal.intValue
        }
        else if segue.identifier == Segues.goToBarcodeScanner {
            let destVC = segue.destination as! BarcodeScannerViewController
            destVC.date = date
            destVC.delegate = delegate
            destVC.mealDelegate = mealDelegate
            destVC.selectedSegmentIndex = meal.intValue
        }
        else if segue.identifier == Segues.goToFoodDetail {
            let destVC = segue.destination as! FoodDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            destVC.food = sortedFoodCopy[indexPath.row]
//            destVC.isAddingFromExistingEntry = true
            destVC.delegate = delegate
            destVC.mealDelegate = mealDelegate
            destVC.date = date
            destVC.selectedSegmentIndex = meal.intValue
        }
    }
}

//MARK:- Extension for table view and search bar methods

extension NewEntryViewController: UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedFoodCopy.count == 0 {  // If foodList is empty, return 1 cell in order to display message
            return 1
        }
        return sortedFoodCopy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        defaultCell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 16)
       
        if sortedFoodCopy.count == 0 {
            tableView.separatorStyle = .none
            if historyLabel.text == "History" {
                defaultCell.textLabel?.text = "No food logged."
            }
            else {
                defaultCell.textLabel?.text = "No matching foods found."
            }
            return defaultCell
        }
        else {
            tableView.separatorStyle = .singleLine
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "foodHistoryCell", for: indexPath) as! FoodHistoryCell
        cell.foodNameLabel.text = sortedFoodCopy[indexPath.row].name
        cell.caloriesLabel.text = "\(sortedFoodCopy[indexPath.row].calories) kcal"
        if UIScreen.main.bounds.height < 600 {
            cell.caloriesLabel.font = cell.caloriesLabel.font.withSize(14)
            cell.calorieNameEqualWidthConstraint.constant = -135
        }

        var totalServing = sortedFoodCopy[indexPath.row].totalServing
        let unit = sortedFoodCopy[indexPath.row].servingSizeUnit
        cell.totalServingLabel.text = totalServing.removePointZeroEndingAndConvertToString() + " \(unit)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.goToFoodDetail, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let ac = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this item from your database?", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
                guard let strongSelf = self else { return }
                
                guard let user = Auth.auth().currentUser?.email else { return }
                let foodName = strongSelf.sortedFoodCopy[indexPath.row].name!
                let foodUUID = strongSelf.sortedFoodCopy[indexPath.row].uuid
                
                strongSelf.db.collection("users").document(user).collection("foods").document("\(foodName) \(foodUUID)").delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document: \(foodName) successfully removed!")
                    }
                }
                
                let currentNav = strongSelf.parent as! UINavigationController
                let overviewNav = currentNav.presentingViewController as! UINavigationController
                let overviewPVC = overviewNav.viewControllers[0] as! OverviewPageViewController
                let overviewVC = overviewPVC.viewControllers?.first as! OverviewViewController
                
                var index = 0
                for entry in strongSelf.allFood! {
                    if entry.name == strongSelf.sortedFoodCopy[indexPath.row].name {
                        strongSelf.allFood?.remove(at: index)
                        overviewVC.allFood?.remove(at: index)
                        overviewVC.loadFirebaseData()
                        break
                    }
                    index += 1
                }
                strongSelf.sortedFoodCopy.remove(at: indexPath.row)
                strongSelf.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            }))
            present(ac, animated: true)
        }
    }
    
    //MARK:- Search Bar Delegate methods
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText != "" {
            sortedFoodCopy = []
            for food in sortedFood {
                if (food.name?.contains(searchBar.text!))! {
                    sortedFoodCopy.append(food)
                }
            }
            tableView.reloadData()
        }
        else {
            historyLabel.text = "History"
            sortedFoodCopy = sortedFood
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            let searchWords = searchText.replacingOccurrences(of: " ", with: "+")
            
            var countryIdentifier = Locale.current.identifier
            if countryIdentifier == "en_GB" {
                countryIdentifier = "uk"
            }
            else if countryIdentifier == "en_US" {
                countryIdentifier = "us"
            }
            
            let urlString = "https://\(countryIdentifier).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(searchWords)&sort_by=product_name&page_size=50&action=display&json=1"
            
            guard let url = URL(string: urlString) else { return }
            
            SVProgressHUD.show()
            
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let strongSelf = self else { return }
                guard let data = data else { return }
//                let food = Food()
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let products = json["products"] as? [[String: Any]] {
                            
                            var searchFoodList = [Food]()
                            for product in products {
 
                                if let nutrients = product["nutriments"] as? [String: Any],
                                   let productName = product["product_name"] as? String,
                                   let energy = nutrients["energy_100g"],  //Unable to cast nutrients to type as JSON data can vary
                                   let protein = nutrients["proteins_100g"],
                                   let carbs = nutrients["carbohydrates_100g"],
                                   let fat = nutrients["fat_100g"] {
                                    
                                    // Make sure item has name, calories, protein, carbs and fat values
                                    if !productName.isEmpty && !"\(energy)".isEmpty && !"\(protein)".isEmpty && !"\(carbs)".isEmpty && !"\(fat)".isEmpty {
                                        
                                        // Store JSON values in a string in order to access and convert to Int or Double
                                        let energyString = "\(energy)"
                                        let calories = Int(round(Double(energyString)! / 4.184))
                                        let proteinString = "\(protein)"
                                        let carbsString = "\(carbs)"
                                        let fatString = "\(fat)"
                                        var trimmedServingSize = ""
                                        
                                        let food = Food()
                                        
                                        if let servingSize = product["serving_size"] as? String {
                                            print(servingSize)
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
                                            food.protein = (Double(proteinString)! / 100.0) * servingSizeNumber
                                            food.carbs = (Double(carbsString)! / 100.0) * servingSizeNumber
                                            food.fat = (Double(fatString)! / 100.0) * servingSizeNumber
                                            
                                            searchFoodList.append(food)
                                        }
                                        else {
  
                                            food.name = productName
                                            food.calories = calories
                                            food.protein = Double(proteinString)!
                                            food.carbs = Double(carbsString)!
                                            food.fat = Double(fatString)!
                                            
                                            searchFoodList.append(food)
                                        }
                                    }
                                }
                            }
                            strongSelf.sortedFoodCopy = searchFoodList
                            DispatchQueue.main.async {
                                strongSelf.tableView.reloadData()
                                strongSelf.historyLabel.text = "Results"
                                searchBar.resignFirstResponder()
                            }
                            
                            SVProgressHUD.dismiss()
                            
                        }     
                    }
                }
                catch {
                   print(error)
                    SVProgressHUD.dismiss()
                }
            }.resume()
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        sortedFoodCopy = sortedFood
        if historyLabel.text == "Results" {
            historyLabel.text = "History"
        }
        tableView.reloadData()
    }
    
}
