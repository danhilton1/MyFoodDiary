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
    private var foodListCopy: Results<Food>?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        searchBar.delegate = self

        foodList = realm.objects(Food.self)
        foodListCopy = foodList
        
        tableView.tableFooterView = UIView()
        
        var foodNameList = [String]()
        for food in foodList! {
            foodNameList.append(food.name!)
        }
//        let uniqueFoodList = foodList?.reduce([], {
//            $0.contains($1.name) ? $0 : $0 + [$1]
//        })
        
//        print(uniqueFoodList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presentingViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        defaultCell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 16)
        
        if foodList?.count == 0 {
            tableView.separatorStyle = .none
            defaultCell.textLabel?.text = "No food ever logged."
            return defaultCell
        }
        else {
            tableView.separatorStyle = .singleLine
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "foodHistoryCell", for: indexPath) as! FoodHistoryCell
        let reversedIndex = ((foodListCopy?.count ?? 0) - 1) - indexPath.row  // Reverse index to display most recent first
        if reversedIndex >= 0 {  // Make sure index isn't negative
            cell.foodNameLabel.text = foodListCopy?[reversedIndex].name
            cell.caloriesLabel.text = "\(foodListCopy?[reversedIndex].calories ?? 0) kcal"
            if var totalServing = foodListCopy?[reversedIndex].totalServing {
                cell.totalServingLabel.text = totalServing.removePointZeroEndingAndConvertToString() + " g"
            }
            else {
                cell.totalServingLabel.text = ""
            }
        } else {
            defaultCell.textLabel?.text = "No matching food."
            return defaultCell
        }
        return cell
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if foodListCopy?.count == 0 {  // If foodList is empty, return 1 cell in order to display message
            return 1
        }
        return foodListCopy?.count ?? 0
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
                    guard let foodToDelete = foodListCopy?[indexPath.row] else { return }
                    realm.delete(foodToDelete)
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
                destVC.food = foodListCopy?[((foodListCopy?.count ?? 0) - 1) - indexPath.row]
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
        foodListCopy = foodListCopy?.filter("name CONTAINS[cd] %@", searchBar.text!)
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
            foodListCopy = realm.objects(Food.self).filter("name CONTAINS[cd] %@", searchBar.text!)
            tableView.reloadData()
        }
        else {
            foodListCopy = realm.objects(Food.self)
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        foodListCopy = realm.objects(Food.self)
        tableView.reloadData()
    }
    
}
