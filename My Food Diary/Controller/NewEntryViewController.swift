//
//  NewEntryPopUpViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 28/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import RealmSwift

class NewEntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterManuallyButton: UIButton!
    
    var date: Date?
    var meal = Food.Meal.breakfast
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    private var foodList: Results<Food>?
    private var sortedFood = [Food]()
    private var sortedFoodCopy = [Food]()
    
    
    enum Segues {
        static let goToManualEntry = "GoToManualEntry"
        static let goToBarcodeScanner = "GoToBarcodeScanner"
        static let goToFoodHistory = "GoToFoodHistory"
        static let goToFoodDetail = "GoToFoodDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setUpNavBar()
        
        foodList = realm.objects(Food.self)
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
        for food in foodList! {
            foodDictionary[food.name!] = food
        }
        sortedFood = foodDictionary.values.sorted { (food1, food2) -> Bool in
            return food1.dateValue > food2.dateValue
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
        else if segue.identifier == Segues.goToFoodHistory {
            let destVC = segue.destination as! FoodHistoryViewController
            destVC.delegate = delegate
            destVC.mealDelegate = mealDelegate
            destVC.date = date
            destVC.selectedSegmentIndex = meal.intValue
        }
        else if segue.identifier == Segues.goToFoodDetail {
            let destVC = segue.destination as! FoodDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            destVC.food = sortedFood[indexPath.row]
            destVC.delegate = delegate
            destVC.mealDelegate = mealDelegate
            destVC.date = date
            destVC.selectedSegmentIndex = meal.intValue
        }
    }
}

//MARK:- Extension for table view methods

extension NewEntryViewController {
    
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
        cell.totalServingLabel.text = totalServing.removePointZeroEndingAndConvertToString() + " g"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.goToFoodDetail, sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
