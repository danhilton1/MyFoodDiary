//
//  NewEntryPopUpViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 28/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase

class NewEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var enterManuallyButton: UIButton!
    
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
            destVC.food = sortedFood[indexPath.row]
            destVC.isAddingFromExistingEntry = true
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
           defaultCell.textLabel?.text = "No food logged."
           return defaultCell
        }
        else {
           tableView.separatorStyle = .singleLine
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "foodHistoryCell", for: indexPath) as! FoodHistoryCell
        cell.foodNameLabel.text = sortedFoodCopy[indexPath.row].name
        cell.caloriesLabel.text = "\(sortedFoodCopy[indexPath.row].calories) kcal"

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
                let food = strongSelf.sortedFoodCopy[indexPath.row].name!
                
                strongSelf.db.collection("users").document(user).collection("foods").document(food).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document: \(food) successfully removed!")
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
            sortedFoodCopy = sortedFood
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text {
            let searchWords = searchText.replacingOccurrences(of: " ", with: "+")
            var countryIdentifier = Locale.current.identifier
            print(countryIdentifier)
            if countryIdentifier == "en_GB" {
                countryIdentifier = "uk"
            }
            else if countryIdentifier == "en_US" {
                countryIdentifier = "us"
            }
            
            let urlString = "https://\(countryIdentifier).openfoodfacts.org/cgi/search.pl?action=process&search_terms=\(searchWords)&sort_by=unique_scans_n&page_size=20&action=display&json=1"
            print(urlString)
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] (date, response, error) in
                guard let strongSelf = self else { return }
                guard let data = date else { return }
                let food = Food()
                print(data.count)
                do {
                    let scannedFood = try JSONDecoder().decode(FoodSearchDatabase.self, from: data)
                    for i in 0..<4 {
                        print(scannedFood.products[i].productName)
                    }
                    //print(scannedFood.products.productName)
//                    for product in scannedFood.products {
//                        food.name = product.productName
//                    }
                    
                    
                }
                catch {
                   print(error)
                }
            }.resume()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        sortedFoodCopy = sortedFood
        tableView.reloadData()
    }
    
}
