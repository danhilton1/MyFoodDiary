//
//  MealDetailViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 13/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class MealDetailViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var selectedMeal: Results<Food>?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = .white
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        return selectedMeal?.count ?? 0
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.black
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 18)
        
        if let foodList = selectedMeal {
            for i in 0..<foodList.count {
                if section == i {
                    label.text = "    \(foodList[i].name!)"
                }
            }
        }
        
       
        
        return label
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        return cell
        
    }

    

}
