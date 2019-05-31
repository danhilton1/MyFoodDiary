//
//  NewEntryViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 31/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class NewEntryViewController: UITableViewController {
    
    @IBOutlet weak var mealPicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealPickerCell
            return cell0
        case 1:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)
            return cell1
        case 2:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "CaloriesCell", for: indexPath)
            return cell2
        case 3:
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "ProteinCell", for: indexPath)
            return cell3
        case 4:
            let cell4 = tableView.dequeueReusableCell(withIdentifier: "CarbsCell", for: indexPath)
            return cell4
        case 5:
            let cell5 = tableView.dequeueReusableCell(withIdentifier: "FatCell", for: indexPath)
            return cell5
        default:
            let defaultCell = UITableViewCell()
            return defaultCell
        }
        
      
    }
 
    @IBAction func mealPickerPressed(_ sender: Any) {
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    }
    
}
