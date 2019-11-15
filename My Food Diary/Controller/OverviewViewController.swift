//
//  ViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 19/05/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.

// TODO: - Show macros on graph for the day. Fix text/pie chart size on overview cell. Hide tab bar. Fix view size
//         issue with activity indicator, error lable etc.. Fix food history/detail issue. 


import UIKit
import RealmSwift
import Charts


class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewEntryDelegate {
    
    let realm = try! Realm()
    
    //MARK: - Properties and Objects
    private var foodList: Results<Food>?
    private let food = Food()
    private var totalCalories = 0
    private var totalCalsArray = [Int]()
    private var refreshControl = UIRefreshControl()
    private let formatter = DateFormatter()
    override var canBecomeFirstResponder: Bool {
        return true
    }
    private let datePicker = UIDatePicker()
    override var inputView: UIView? {
        return self.datePicker
    }
    override var inputAccessoryView: UIView? {
        return self.toolbar
    }
    private let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
       
    let dimView = UIView()
    
    //  Required to be set before VC presented
    var date: Date?
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var eatMeTableView: UITableView!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    
    //MARK: - view Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        eatMeTableView.addSubview(refreshControl)
        
        configureDateView()
        loadAllFood()
        
        self.toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(dismissResponder)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dateEntered))
        ]
        
        self.toolbar.sizeToFit()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "en_GB")
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadAllFood()
        presentingViewController?.tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    

    
    private func setUpTableView() {
        eatMeTableView.delegate = self
        eatMeTableView.dataSource = self
        eatMeTableView.separatorStyle = .none
        eatMeTableView.register(UINib(nibName: "MealOverviewCell", bundle: nil), forCellReuseIdentifier: "mealOverviewCell")
    }
    
    private func configureDateView() {
        formatter.dateFormat = "E, d MMM"
        guard let date = date else { return }
        let dateAsString = formatter.string(from: date)
        
        // Check if date is the same as current date and if so, display "Today" in label
        if dateAsString == formatter.string(from: Date()) {
            dayLabel.text = "Today"
        } else {
            dayLabel.text = dateAsString
        }
        
    }
    
    
    @IBAction func datePickerArrowTapped(_ sender: UIButton) {
        
        dimView.frame = self.view.frame
        dimView.backgroundColor = .black
        dimView.alpha = 0
        self.view.addSubview(dimView)
        UIView.animate(withDuration: 0.25) {
            self.dimView.alpha = 0.35
            
        }
        self.becomeFirstResponder()
        
    }
    @objc func dateEntered() {
        self.resignFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.dimView.alpha = 0
        }
        date = datePicker.date
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
            self.dimView.removeFromSuperview()
            self.loadAllFood()
            self.configureDateView()
        }
        
        print(date)
    }
    
    @objc func dismissResponder() {
        self.resignFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.dimView.alpha = 0
        }
    }
    
    //MARK:- Data methods
    
    func loadAllFood() {
        
        formatter.dateFormat = "E, d MMM"
        
        foodList = realm.objects(Food.self)
        let predicate = NSPredicate(format: "date contains[c] %@", formatter.string(from: date ?? Date()))
        foodList = foodList?.filter(predicate)
        let deletedPredicate = NSPredicate(format: "isDeleted == FALSE")
        foodList = foodList?.filter(deletedPredicate)
        
        totalCalsArray = (foodList?.value(forKey: "calories")) as! [Int]
        totalCalories = totalCalsArray.reduce(0, +)
        
        totalCaloriesLabel.text = "Total Calories: \(totalCalories)"
        
        eatMeTableView.reloadData()
        
    }
    
    @objc func refresh() {
        loadAllFood()
        refreshControl.endRefreshing()
    }
    
    func deleteData() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        }
        catch {
            print("Error deleting data - \(error)")
        }
        
        loadAllFood()
        
    }
    
    
    //MARK: - Tableview Data Source Methods
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel()
        label.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        label.textColor = UIColor.black
        label.font = UIFont(name: "Montserrat-SemiBold", size: 17)
        
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
            getTotalValueOfMealData(food: foodList, meal: .breakfast, cell: cell)
        case 1:
            getTotalValueOfMealData(food: foodList, meal: .lunch, cell: cell)
        case 2:
            getTotalValueOfMealData(food: foodList, meal: .dinner, cell: cell)
        case 3:
            getTotalValueOfMealData(food: foodList, meal: .other, cell: cell)
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
    
    
    private func getTotalValueOfMealData(food: Results<Food>?, meal: Food.Meal, cell: MealOverviewCell) {
        // Updates the total amount of cals and macros for user entries
        
        var calorieArray = [Int]()
        var proteinArray = [Double]()
        var carbsArray = [Double]()
        var fatArray = [Double]()
        
        var calories = 0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0
        
        
        // Checks the meal type and then appends each food property (cals, carbs, ..) to corresponding array
        if let foodlist = food {
            
            if meal == .breakfast {
                for food in foodlist {
                    if food.meal == "Breakfast" {
                        calorieArray.append(food.calories)
                        proteinArray.append(food.protein)
                        carbsArray.append(food.carbs)
                        fatArray.append(food.fat)
                    }
                }
                // Add each value of array to the corresponding property to give total amount
                for i in 0..<calorieArray.count {
                    calories += calorieArray[i]
                    protein += proteinArray[i]
                    carbs += carbsArray[i]
                    fat += fatArray[i]
                }
            }
            else if meal == .lunch {
                for food in foodlist {
                    if food.meal == "Lunch" {
                        calorieArray.append(food.calories)
                        proteinArray.append(food.protein)
                        carbsArray.append(food.carbs)
                        fatArray.append(food.fat)
                    }
                }
                for i in 0..<calorieArray.count {
                    calories += calorieArray[i]
                    protein += proteinArray[i]
                    carbs += carbsArray[i]
                    fat += fatArray[i]
                }
            }
            else if meal == .dinner {
                for food in foodlist {
                    if food.meal == "Dinner" {
                        calorieArray.append(food.calories)
                        proteinArray.append(food.protein)
                        carbsArray.append(food.carbs)
                        fatArray.append(food.fat)
                    }
                }
                for i in 0..<calorieArray.count {
                    calories += calorieArray[i]
                    protein += proteinArray[i]
                    carbs += carbsArray[i]
                    fat += fatArray[i]
                }
            }
            else if meal == .other {
                for food in foodlist {
                    if food.meal == "Other" {
                        calorieArray.append(food.calories)
                        proteinArray.append(food.protein)
                        carbsArray.append(food.carbs)
                        fatArray.append(food.fat)
                    }
                }
                for i in 0..<calorieArray.count {
                    calories += calorieArray[i]
                    protein += proteinArray[i]
                    carbs += carbsArray[i]
                    fat += fatArray[i]
                }
            }
        }
        
        cell.calorieLabel.text = "\(calories) kcal"
        cell.proteinLabel.text = protein.removePointZeroEndingAndConvertToString() + " g"
        cell.carbsLabel.text = carbs.removePointZeroEndingAndConvertToString() + " g"
        cell.fatLabel.text = fat.removePointZeroEndingAndConvertToString() + " g"
        
        setUpPieChart(cell: cell, section1: protein, section2: carbs, section3: fat)
    }
    
    
    func setUpPieChart(cell: MealOverviewCell, section1 protein: Double, section2 carbs: Double, section3 fat: Double) {
        
        cell.pieChart.legend.enabled = false
        cell.pieChart.holeRadiusPercent = 0.5
        cell.pieChart.highlightPerTapEnabled = false
        cell.pieChart.rotationEnabled = false
        
        // If no user entries/data then set default equal values of pie chart to display equal sections
        if protein == 0 && carbs == 0 && fat == 0 {
            
            let chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1.0),
                                                         PieChartDataEntry(value: 1.0),
                                                         PieChartDataEntry(value: 1.0)], label: nil)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
            chartDataSet.selectionShift = 0
            let chartData = PieChartData(dataSet: chartDataSet)
            
            cell.pieChart.data = chartData
            
        } else {
            // Set pie chart data to the total values of protein, carbs and fat from user's entries
            let pieChartEntries = [PieChartDataEntry(value: protein),
                                   PieChartDataEntry(value: carbs),
                                   PieChartDataEntry(value: fat)]
            let chartDataSet = PieChartDataSet(entries: pieChartEntries, label: nil)
            chartDataSet.drawValuesEnabled = false
            chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
            chartDataSet.selectionShift = 0
            let chartData = PieChartData(dataSet: chartDataSet)
            
            cell.pieChart.data = chartData
        }
        
        
    }
    
    
    //MARK:- NewEntryDelegate protocol method
    
    
    func reloadFood() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
            self.loadAllFood()
        }
    }
    
    //MARK:- Configure date method
    
    func configureWith(date: Date) {
        self.date = date
    }
    
    
    //MARK:- Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        

        if segue.identifier ==  "goToMealDetail" {
            
            let destVC = segue.destination as! MealDetailViewController
            destVC.date = date
            
            if let indexPath = eatMeTableView.indexPathForSelectedRow {
                
                if indexPath.section == 0 {
                    filterFoodForMealDetail(meal: Food.Meal.breakfast, destVC: destVC)
                }
                else if indexPath.section == 1 {
                    filterFoodForMealDetail(meal: Food.Meal.lunch, destVC: destVC)
                }
                else if indexPath.section == 2 {
                    filterFoodForMealDetail(meal: Food.Meal.dinner, destVC: destVC)
                }
                else if indexPath.section == 3 {
                    filterFoodForMealDetail(meal: Food.Meal.other, destVC: destVC)
                }
            }
        }
        else if segue.identifier == "GoToNutrition" {
            let navController = segue.destination as! UINavigationController
            let destVC = navController.viewControllers.first as! NutritionViewController
            destVC.date = date
            destVC.calories = totalCalories
        }
    }
    
    func filterFoodForMealDetail(meal: Food.Meal, destVC: MealDetailViewController) {
        
        let resultPredicate = NSPredicate(format: "meal contains[c] %@", meal.stringValue)
        destVC.selectedMeal = foodList?.filter(resultPredicate)
        destVC.navigationItem.title = meal.stringValue
        destVC.meal = meal
        
    }
    



}


extension Double {
    
    mutating func roundToXDecimalPoints(decimalPoints: Int?) -> Double {
        switch decimalPoints {
        case 1:
            return Darwin.round(10 * self) / 10
        case 2:
            return Darwin.round(100 * self) / 100
        case 3:
            return Darwin.round(1000 * self) / 1000
        case 4:
            return Darwin.round(10000 * self) / 10000
        case 5:
            return Darwin.round(100000 * self) / 100000
        case 6:
            return Darwin.round(1000000 * self) / 1000000
        case 7:
            return Darwin.round(10000000 * self) / 10000000
        case 8:
            return Darwin.round(100000000 * self) / 100000000
        case 9:
            return Darwin.round(1000000000 * self) / 1000000000
        case 10:
            return Darwin.round(10000000000 * self) / 10000000000
        default:
            return Darwin.round(self)
            
        }
    }
    
    mutating func removePointZeroEndingAndConvertToString() -> String {
        var numberString = String(self.roundToXDecimalPoints(decimalPoints: 1))

        if numberString.hasSuffix(".0") {
            numberString.removeLast(2)
        }
        return numberString
    }
    
    mutating func roundWholeAndRemovePointZero() -> String {
        let value = Darwin.round(self)
        var valueString = String(value)
        
        if valueString.hasSuffix(".0") {
            valueString.removeLast(2)
        }
        return valueString
    }
}




