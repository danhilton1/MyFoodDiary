//
//  FoodHistoryViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/08/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class FoodHistoryViewController: UITableViewController {

    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var date: Date?
    var selectedSegmentIndex = 0
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    private var foodList: Results<Food>?
    private var sortedFood = [Food]()
    private var sortedFoodCopy = [Food]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        searchBar.delegate = self

        foodList = realm.objects(Food.self)
        //setUpSortedFoodList()
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
    
//    func setUpSortedFoodList() {
//        var foodDictionary = [String: Food]()
//        for food in foodList! {
//            foodDictionary[food.name!] = food
//        }
//        sortedFood = foodDictionary.values.sorted { (food1, food2) -> Bool in
//            return food1.dateValue > food2.dateValue
//        }
//    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        defaultCell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 16)
        
        if sortedFoodCopy.count == 0 {
            tableView.separatorStyle = .none
            defaultCell.textLabel?.text = "No food ever logged."
            return defaultCell
        }
        else {
            tableView.separatorStyle = .singleLine
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "foodHistoryCell", for: indexPath) as! FoodHistoryCell
        cell.foodNameLabel.text = sortedFoodCopy[indexPath.row].name
        cell.caloriesLabel.text = "\(sortedFoodCopy[indexPath.row].calories) kcal"
 
        var totalServing = sortedFoodCopy[indexPath.row].totalServing
        cell.totalServingLabel.text = totalServing.removePointZeroEndingAndConvertToString() + " g"

        return cell
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedFoodCopy.count == 0 {  // If foodList is empty, return 1 cell in order to display message
            return 1
        }
        return sortedFoodCopy.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToFoodDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try realm.write {
                    let foodToDelete = sortedFoodCopy[indexPath.row]
                    foodToDelete.isDeleted = true
                }
            }
            catch {
                print("Error deleting data - \(error)")
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoToFoodDetail" {
            let destVC = segue.destination as! FoodDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.food = sortedFood[indexPath.row]
                destVC.delegate = delegate
                destVC.mealDelegate = mealDelegate
                destVC.date = date
                destVC.selectedSegmentIndex = selectedSegmentIndex
            }
        }
    }



}


//MARK: - Search Bar Extension

extension FoodHistoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            sortedFoodCopy = []
            for food in sortedFood {
                if (food.name?.contains(searchBar.text!))! {
                    sortedFoodCopy.append(food)
                }
            }
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        sortedFoodCopy = sortedFood
        tableView.reloadData()
    }
    
}
