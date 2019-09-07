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
    
    private var foodList: Results<Food>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.flatSkyBlue()

        foodList = realm.objects(Food.self)
        
        tableView.tableFooterView = UIView()

    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodHistoryCell", for: indexPath) as! FoodHistoryCell
        
        let reversedIndex = ((foodList?.count ?? 0) - 1) - indexPath.row
        
        cell.foodNameLabel.text = foodList?[reversedIndex].name
        cell.totalServingLabel.text = "\(foodList?[reversedIndex].totalServing ?? 100) g"
        cell.caloriesLabel.text = "\(foodList?[reversedIndex].calories ?? 0) kcal"
        
        return cell
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return foodList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToFoodDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try realm.write {
                    guard let foodToDelete = foodList?[indexPath.row] else { return }
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
        
        if segue.identifier == "goToFoodDetail" {
            let destVC = segue.destination as! FoodDetailViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.food = foodList?[((foodList?.count ?? 0) - 1) - indexPath.row]
            }
        }
    }



}
