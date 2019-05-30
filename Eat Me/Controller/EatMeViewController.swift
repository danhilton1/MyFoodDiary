//
//  ViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit

class EatMeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var eatMeTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eatMeTableView.delegate = self
        eatMeTableView.dataSource = self
        
        eatMeTableView.separatorStyle = .none
        
        eatMeTableView.register(UINib(nibName: "MealOverviewCell", bundle: nil), forCellReuseIdentifier: "mealOverviewCell")
        
    }
    
    
    //MARK: - Tableview Data Source Methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.black
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 21)
        
        switch section {
        case 0:
            label.text = "   Breakfast"
        case 1:
            label.text = "   Lunch"
        case 2:
            label.text = "   Dinner"
        case 3:
            label.text = "   Other"
        default:
            label.text = ""
        }
        
       return label
            
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealOverviewCell", for: indexPath) as! MealOverviewCell
        
        
        
        
        
        
        return cell
        
    }
    


}

