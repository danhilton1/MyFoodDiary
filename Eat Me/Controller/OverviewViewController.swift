//
//  ViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.

// TODO: - parse JSON from barcode scan, show food history, dates


import UIKit
import RealmSwift
import Charts
import ChameleonFramework

let dateNotificationKey = "co.danhiltonapps.date"

class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewEntryDelegate {
    
    let realm = try! Realm()
    
    //MARK: - Properties and Objects
    private var foodList: Results<Food>?
    private let food = Food()
    private var totalCals: Int!
    private let defaults = UserDefaults.standard
    private var refreshControl = UIRefreshControl()
    private let formatter = DateFormatter()
    
    //  Required to be set before VC presented
    var date: Date?
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eatMeTableView: UITableView!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    
    //MARK: - view Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 30)!]
        
        setUpTableView()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        eatMeTableView.addSubview(refreshControl)
        
        totalCals = defaults.integer(forKey: "totalCalories")
        
        loadAllFood()
        configureDateView()
        
        eatMeTableView.reloadData()
    }
    
    private func setUpTableView() {
        eatMeTableView.delegate = self
        eatMeTableView.dataSource = self
        eatMeTableView.separatorStyle = .none
        eatMeTableView.register(UINib(nibName: "MealOverviewCell", bundle: nil), forCellReuseIdentifier: "mealOverviewCell")
    }
    
    private func configureDateView() {
        formatter.dateFormat = "dd.MM.yyyy"
        guard let date = date else { return }
        let dateAsString = formatter.string(from: date)
        
        // Check if date is the same as current date and if so, display "Today" in label
        if dateAsString == formatter.string(from: Date()) {
            dayLabel.text = "Today"
        } else {
            dayLabel.text = dateAsString
        }
        
        // Filter all entries in Realm database by date
        foodList = realm.objects(Food.self)
        let predicate = NSPredicate(format: "date contains[c] %@", dateAsString)
        foodList = foodList?.filter(predicate)
    }
    
    //MARK:- Data methods
    
    func loadAllFood() {
        
        formatter.dateFormat = "dd.MM.yyyy"
        
        foodList = realm.objects(Food.self)
        let predicate = NSPredicate(format: "date contains[c] %@", formatter.string(from: date ?? Date()))
        foodList = foodList?.filter(predicate)
        
        totalCaloriesLabel.text = "Total Calories: \(totalCals!)"
        //        print(totalCals)
        
    }
    
    @objc func refresh() {
        loadAllFood()
        refreshControl.endRefreshing()
    }
    
    @IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        }
        catch {
            print("Error deleting data - \(error)")
        }
        
        totalCals = 0
        defaults.set(0, forKey: "totalCalories")
        loadAllFood()
        
    }
    
    
    //MARK: - Tableview Data Source Methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.black
        label.font = UIFont(name: "Montserrat-Light", size: 18)
        
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
        
        switch indexPath.section {
            
        case 0:
            getSumOfPropertiesForMeal(food: foodList, meal: .breakfast, cell: cell)
        case 1:
            getSumOfPropertiesForMeal(food: foodList, meal: .lunch, cell: cell)
        case 2:
            getSumOfPropertiesForMeal(food: foodList, meal: .dinner, cell: cell)
        case 3:
            getSumOfPropertiesForMeal(food: foodList, meal: .other, cell: cell)
        default:
            cell.calorieLabel.text = "0"
            cell.proteinLabel.text = "0"
            cell.carbsLabel.text = "0"
            cell.fatLabel.text = "0"
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToMealDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    //MARK: - Methods to Update UI with user's entry data
    
    
    private func getSumOfPropertiesForMeal(food: Results<Food>?, meal: Food.Meal, cell: MealOverviewCell) {
        // Updates the total amount of cals and macros for user entries
        
        var calorieArray = [NSNumber]()
        var proteinArray = [NSNumber]()
        var carbsArray = [NSNumber]()
        var fatArray = [NSNumber]()
        
        var calories = 0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0
        
        
        // Checks the meal type and then appends each food property (cals, carbs, ..) to corresponding array
        if let foodlist = food {
            if meal == .breakfast {
                for i in 0..<foodlist.count {
                    if foodlist[i].meal == "breakfast" {
                        calorieArray.append(foodlist[i].calories ?? 0)
                        proteinArray.append(foodlist[i].protein ?? 0)
                        carbsArray.append(foodlist[i].carbs ?? 0)
                        fatArray.append(foodlist[i].fat ?? 0)
                    }
                }
                // Add each value of array to the corresponding property to give total amount
                for i in 0..<calorieArray.count {
                    calories += Int(truncating: calorieArray[i])
                    protein += Double(truncating: proteinArray[i])
                    carbs += Double(truncating: carbsArray[i])
                    fat += Double(truncating: fatArray[i])
                }
            }
            else if meal == .lunch {
                for i in 0..<foodlist.count {
                    if foodlist[i].meal == "lunch" {
                        calorieArray.append(foodlist[i].calories ?? 0)
                        proteinArray.append(foodlist[i].protein ?? 0)
                        carbsArray.append(foodlist[i].carbs ?? 0)
                        fatArray.append(foodlist[i].fat ?? 0)
                    }
                }
                for i in 0..<calorieArray.count {
                    calories += Int(truncating: calorieArray[i])
                    protein += Double(truncating: proteinArray[i])
                    carbs += Double(truncating: carbsArray[i])
                    fat += Double(truncating: fatArray[i])
                }
            }
            else if meal == .dinner {
                for i in 0..<foodlist.count {
                    if foodlist[i].meal == "dinner" {
                        calorieArray.append(foodlist[i].calories ?? 0)
                        proteinArray.append(foodlist[i].protein ?? 0)
                        carbsArray.append(foodlist[i].carbs ?? 0)
                        fatArray.append(foodlist[i].fat ?? 0)
                    }
                }
                for i in 0..<calorieArray.count {
                    calories += Int(truncating: calorieArray[i])
                    protein += Double(truncating: proteinArray[i])
                    carbs += Double(truncating: carbsArray[i])
                    fat += Double(truncating: fatArray[i])
                }
            }
            else if meal == .other {
                for i in 0..<foodlist.count {
                    if foodlist[i].meal == "other" {
                        calorieArray.append(foodlist[i].calories ?? 0)
                        proteinArray.append(foodlist[i].protein ?? 0)
                        carbsArray.append(foodlist[i].carbs ?? 0)
                        fatArray.append(foodlist[i].fat ?? 0)
                    }
                }
                for i in 0..<calorieArray.count {
                    calories += Int(truncating: calorieArray[i])
                    protein += Double(truncating: proteinArray[i])
                    carbs += Double(truncating: carbsArray[i])
                    fat += Double(truncating: fatArray[i])
                }
            }
        }
        
        
        cell.calorieLabel.text = "\(calories) kcal"
        cell.proteinLabel.text = "\(round(10 * protein) / 10) g"   // Round to 1 d.p.
        cell.carbsLabel.text = "\(round(10 * carbs) / 10) g"
        cell.fatLabel.text = "\(round(10 * fat) / 10) g"
        
        setUpPieChart(cell: cell, section1: protein, section2: carbs, section3: fat)
    }
    
    func setUpPieChart(cell: MealOverviewCell, section1 protein: Double, section2 carbs: Double, section3 fat: Double) {
        
        cell.pieChart.legend.enabled = false
        cell.pieChart.holeRadiusPercent = 0.5
        cell.pieChart.highlightPerTapEnabled = false
        
        // If no user entries/data then set default equal values of pie chart to display equal sections
        if protein == 0 && carbs == 0 && fat == 0 {
            
            let chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1.0),
                                                         PieChartDataEntry(value: 1.0),
                                                         PieChartDataEntry(value: 1.0)], label: nil)
            let chartData = PieChartData(dataSet: chartDataSet)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [UIColor.flatSkyBlue(), UIColor.flatMint(), UIColor.flatWatermelon()]
            cell.pieChart.data = chartData
            
        } else {
            // Set pie chart data to the total values of protein, carbs and fat from user's entries
            let pieChartEntries = [PieChartDataEntry(value: protein),
                                   PieChartDataEntry(value: carbs),
                                   PieChartDataEntry(value: fat)]
            let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)
            let chartData = PieChartData(dataSet: chartDataSet)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [UIColor.flatSkyBlue(), UIColor.flatMint(), UIColor.flatWatermelon()]
            
            cell.pieChart.data = chartData
        }
        
        
    }
    
    
    //MARK:- NewEntryDelegate protocol methods
    
    func getCalorieDataFromNewEntry(data: Int, date: Date) {
        
        totalCals += data
        defaults.set(totalCals, forKey: "totalCalories")
//        let dateAsString = formatter.string(from: date)
//        defaults.set(dateAsString, forKey: "date")
        
    }
    
    func reloadFood() {
    
        let delayTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.loadAllFood()
        }
        
    }
    
    //MARK:- Observer method
    
    @objc func updateDateFromNotification(notification: Notification) {
        
        date = notification.object as? Date
        
    }
    
    func configureWith(date: Date) {
        self.date = date
    }
    
    
    
    //MARK:- Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPopUp" {

            let navController = segue.destination as! UINavigationController
            let viewController = navController.topViewController as! PopUpNewEntryViewController
            viewController.delegate = self
            viewController.date = date
            
        }
        else if segue.identifier == "goToMealDetail" {
            
            let destVC = segue.destination as! MealDetailViewController
            
            if let indexPath = eatMeTableView.indexPathForSelectedRow {
                
                if indexPath.section == 0 {
                    
                    filterFoodForMealDetail(meal: "Breakfast", destVC: destVC)
                    
                }
                else if indexPath.section == 1 {
                    
                    filterFoodForMealDetail(meal: "Lunch", destVC: destVC)
                    
                }
                else if indexPath.section == 2 {
                    
                    filterFoodForMealDetail(meal: "Dinner", destVC: destVC)
                    
                }
                else if indexPath.section == 3 {
                    
                    filterFoodForMealDetail(meal: "Other", destVC: destVC)
                    
                }
            }
        }
    }
    
    func filterFoodForMealDetail(meal: String, destVC: MealDetailViewController) {
        
        let resultPredicate = NSPredicate(format: "meal contains[c] %@", meal)
        destVC.selectedMeal = foodList?.filter(resultPredicate)
        destVC.navigationItem.title = meal
        
    }
    



}



