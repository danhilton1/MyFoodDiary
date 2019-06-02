//
//  ViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class EatMeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    
    var foodList: Results<BreakfastFood>?

    @IBOutlet weak var eatMeTableView: UITableView!
    
//    let breakfastFood = BreakfastFood()
//    let lunchFood = LunchFood()
//    let dinnerFood = DinnerFood()
//    let otherFood = OtherFood()
    
    var refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        eatMeTableView.delegate = self
        eatMeTableView.dataSource = self
        
        eatMeTableView.separatorStyle = .none
        
        eatMeTableView.register(UINib(nibName: "MealOverviewCell", bundle: nil), forCellReuseIdentifier: "mealOverviewCell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        eatMeTableView.addSubview(refreshControl)
        
        loadFood()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadFood()
    }
    
    @objc func refresh() {
        loadFood()
        refreshControl.endRefreshing()
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
        
//        let food = foodList?[indexPath.section] ?? BreakfastFood()
        var breakfastFood = BreakfastFood()
        if let lastFoodIndex = foodList?.endIndex {
            breakfastFood = foodList?[lastFoodIndex - 1] ?? BreakfastFood()
        } else {
            breakfastFood = foodList?[indexPath.section] ?? BreakfastFood()
        }
        
        switch indexPath.section {
        case 0:
            setCellData(cell: cell, calories: breakfastFood.calories, protein: breakfastFood.protein, carbs: breakfastFood.carbs, fat: breakfastFood.fat)
        case 1:
            setCellData(cell: cell, calories: lunchFood.calories, protein: lunchFood.protein, carbs: lunchFood.carbs, fat: lunchFood.fat)
        case 2:
            setCellData(cell: cell, calories: dinnerFood.calories, protein: dinnerFood.protein, carbs: dinnerFood.carbs, fat: dinnerFood.fat)
        case 3:
            setCellData(cell: cell, calories: otherFood.calories, protein: otherFood.protein, carbs: otherFood.carbs, fat: otherFood.fat)
        default:
            setCellData(cell: cell, calories: "0kcal", protein: "0g", carbs: "0g", fat: "0g")
        }
        
        
        
        
        return cell
        
    }
    
    func setCellData(cell: MealOverviewCell, calories: String?, protein: String?, carbs: String?, fat: String?) {
        cell.calorieLabel.text = (calories ?? "0") + "kcal"
        cell.proteinLabel.text = (protein ?? "0") + "g"
        cell.carbsLabel.text = (carbs ?? "0") + "g"
        cell.fatLabel.text = (fat ?? "0") + "g"
    }
    
    func loadFood() {
        
        foodList = realm.objects(BreakfastFood.self)
        
        eatMeTableView.reloadData()
        
    }


}

