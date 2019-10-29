//
//  NutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 11/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class NutritionViewController: UIViewController {
    
    //MARK: - Properties and Objects
    
    let realm = try! Realm()
    let calendar = Calendar.current
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var weekVC: WeekNutritionViewController?
    var monthVC: MonthNutritionViewController?
    
    private let formatter = DateFormatter()
    var foodList: Results<Food>?
    var foodListCopy: Results<Food>?
    var dateAsString: String?
    var date: Date? {
        didSet {
            formatter.dateFormat = "E, d MMM"
            guard let date = date else { return }
            dateAsString = formatter.string(from: date)

            // Check if date is the same as current date and if so, display "Today" in label
            if dateAsString == formatter.string(from: Date()) {
                dateAsString = "Today"
            }
        }
    }
    var startOfWeekDate: Date?
    var dateCopy: Date?
    var monthChartLabels = [String]()
    var calories = 0
    
    //MARK: - viewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        weekVC = children[1] as? WeekNutritionViewController
        monthVC = children.last as? MonthNutritionViewController
        dateLabel.text = dateAsString
        setFoodList(date: date)
        setDataForInitalChildVC()
        setUpWeekView(direction: .backward, date: date, considerToday: true)
        setUpMonthView(direction: .backward, date: date, considerToday: true)
        setUpWeekView(direction: .backward, date: date, considerToday: true)
        
    }
    
    //MARK: - Set Data Methods
    
    func setFoodList(date: Date?) {
        foodList = realm.objects(Food.self)
        let predicate = NSPredicate(format: "date contains[c] %@", formatter.string(from: date ?? Date()))
        foodList = foodList?.filter(predicate)
        let deletedPredicate = NSPredicate(format: "isDeleted == FALSE")
        foodList = foodList?.filter(deletedPredicate)
    }
    
    func setFoodListCopy(date: Date?) {
        foodListCopy = realm.objects(Food.self)
        let predicate = NSPredicate(format: "date contains[c] %@", formatter.string(from: date ?? Date()))
        foodListCopy = foodListCopy?.filter(predicate)
        let deletedPredicate = NSPredicate(format: "isDeleted == FALSE")
        foodListCopy = foodListCopy?.filter(deletedPredicate)
    }
    
    func setDataForInitalChildVC() {
        dayView.alpha = 1
        weekView.alpha = 0
        monthView.alpha = 0
        let dayVC = children.first as? DayNutritionViewController
        dayVC?.foodList = foodList
        dayVC?.calories = calories
    }
    
    //MARK: - Set Subview Methods
    
    func setUpWeekView(direction: Calendar.SearchDirection, date: Date?, considerToday: Bool) {
        
        guard let today = date else { return }
        let monday = today.next(.monday, direction: direction, considerToday: considerToday)
        startOfWeekDate = monday
        
        setFoodListCopy(date: startOfWeekDate)
        weekVC?.foodList = foodListCopy
        // Set chart data set to food list of last monday.
        weekVC?.proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.protein ?? 0)],
        label: "Protein")
        weekVC?.carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.carbs ?? 0)],
        label: "Carbs")
        weekVC?.fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.fat ?? 0)],
        label: "Fat")
        weekVC?.lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: weekVC?.calories ?? 0)], label: "Calories")
        
        var dateCopy = startOfWeekDate
        // Append new entries to data sets from each day of the week
        for i in 1...6 {
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())
            setFoodListCopy(date: dateCopy)
            weekVC?.foodList = foodListCopy
            weekVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.protein ?? 0))
            weekVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.carbs ?? 0))
            weekVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.fat ?? 0))
            weekVC?.lineChartDataSet.append(ChartDataEntry(x: Double(i), y: weekVC?.calories ?? 0))
        }
    }
    
    
    func setUpMonthView(direction: Calendar.SearchDirection, date: Date?, considerToday: Bool) {

        guard let today = date else { return }
        let monday = today.next(.monday, direction: direction, considerToday: considerToday) //Get date of last/next monday
        startOfWeekDate = monday
        monthChartLabels = [formatter.string(from: startOfWeekDate ?? Date())]
        //set chart data set to food list of each day.
        setFoodListCopy(date: startOfWeekDate)
        monthVC?.foodList = foodListCopy
        
        monthVC?.monthAverageProtein = weekVC?.averageProtein.roundToXDecimalPoints(decimalPoints: 1) ?? 0
        monthVC?.monthAverageCarbs = weekVC?.averageCarbs.roundToXDecimalPoints(decimalPoints: 1) ?? 0
        monthVC?.monthAverageFat = weekVC?.averageFat.roundToXDecimalPoints(decimalPoints: 1) ?? 0
        monthVC?.monthAverageCalories = weekVC?.getAverageOfValue(dataSet: weekVC!.lineChartDataSet)
        // Set first entry in chart data set to the average values of the week starting from last Monday
        monthVC?.proteinChartDataSet = BarChartDataSet(entries:
            [BarChartDataEntry(x: 0, y: monthVC?.monthAverageProtein?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Average Protein (Day)")
        monthVC?.carbsChartDataSet = BarChartDataSet(entries:
            [BarChartDataEntry(x: 0, y: monthVC?.monthAverageCarbs?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Average Carbs (Day)")
        monthVC?.fatChartDataSet = BarChartDataSet(entries:
            [BarChartDataEntry(x: 0, y: monthVC?.monthAverageFat?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Average Fat (Day)")
        monthVC?.lineChartDataSet = LineChartDataSet(entries:
            [ChartDataEntry(x: 0, y: monthVC?.monthAverageCalories?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Average Calories (Day)")
        
        dateCopy = startOfWeekDate
        
        var value = 0
        if direction == .backward {
            value = -7
        }
        else {
            value = 7
        }
        
        for i in 1...4 {   // Loop through the next weeks of the month and retrive the average values and append to chart data
            
            dateCopy = calendar.date(byAdding: .day, value: value, to: dateCopy ?? Date())
            monthChartLabels.append(formatter.string(from: dateCopy ?? Date()))
            
            getAverageValuesForWeek(date: dateCopy)
            
            monthVC?.monthAverageProtein = weekVC?.averageProtein.roundToXDecimalPoints(decimalPoints: 1)
            monthVC?.monthAverageCarbs = weekVC?.averageCarbs.roundToXDecimalPoints(decimalPoints: 1)
            monthVC?.monthAverageFat = weekVC?.averageFat.roundToXDecimalPoints(decimalPoints: 1)
            monthVC?.monthAverageCalories = weekVC?.getAverageOfValue(dataSet: weekVC!.lineChartDataSetCopy)
            
            setFoodListCopy(date: dateCopy)
            monthVC?.foodListCopy = foodListCopy
            monthVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: monthVC?.monthAverageProtein?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
            monthVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: monthVC?.monthAverageCarbs?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
            monthVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: monthVC?.monthAverageFat?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
            monthVC?.lineChartDataSet.append(ChartDataEntry(x: Double(i), y: monthVC?.monthAverageCalories?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
        }
        
        //print(dateCopy)
    }
    
    func getAverageValuesForWeek(date: Date?) {
        // Retrieves the values for the week that is set in the method call and sets the chart data set to averages values for selected week
        
        _=weekVC?.proteinChartDataSetCopy.remove(at: 0)  // Remove the previous first entry in data set to make way for new values
        _=weekVC?.carbsChartDataSetCopy.remove(at: 0)
        _=weekVC?.fatChartDataSetCopy.remove(at: 0)
        _=weekVC?.lineChartDataSetCopy.remove(at: 0)
        var dateCopy = date
        setFoodListCopy(date: dateCopy)
        weekVC?.foodListCopy = foodListCopy
        weekVC?.proteinChartDataSetCopy.append(BarChartDataEntry(x: 0, y: weekVC?.getTotalValueOfNutrient(.protein, foodList: weekVC?.foodListCopy) ?? 0))
        weekVC?.carbsChartDataSetCopy.append(BarChartDataEntry(x: 0, y: weekVC?.getTotalValueOfNutrient(.carbs, foodList: weekVC?.foodListCopy) ?? 0))
        weekVC?.fatChartDataSetCopy.append(BarChartDataEntry(x: 0, y: weekVC?.getTotalValueOfNutrient(.fat, foodList: weekVC?.foodListCopy) ?? 0))
        weekVC?.lineChartDataSetCopy.append(ChartDataEntry(x: 0, y: weekVC?.getTotalValueOfNutrient(.calories, foodList: weekVC?.foodListCopy) ?? 0))
        
        for i in 1...6 {
            _=weekVC?.proteinChartDataSetCopy.remove(at: 0)
            _=weekVC?.carbsChartDataSetCopy.remove(at: 0)
            _=weekVC?.fatChartDataSetCopy.remove(at: 0)
            _=weekVC?.lineChartDataSetCopy.remove(at: 0)
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())!
            setFoodListCopy(date: dateCopy)
            weekVC?.foodListCopy = foodListCopy
            weekVC?.proteinChartDataSetCopy.append(BarChartDataEntry(x: Double(i), y: weekVC?.getTotalValueOfNutrient(.protein, foodList: weekVC?.foodListCopy) ?? 0))
            weekVC?.carbsChartDataSetCopy.append(BarChartDataEntry(x: Double(i), y: weekVC?.getTotalValueOfNutrient(.carbs, foodList: weekVC?.foodListCopy) ?? 0))
            weekVC?.fatChartDataSetCopy.append(BarChartDataEntry(x: Double(i), y: weekVC?.getTotalValueOfNutrient(.fat, foodList: weekVC?.foodListCopy) ?? 0))
            weekVC?.lineChartDataSetCopy.append(ChartDataEntry(x: Double(i), y: weekVC?.getTotalValueOfNutrient(.calories, foodList: weekVC?.foodListCopy) ?? 0))
//            VC?.foodList = foodListCopy
//            VC?.proteinChartDataSetCopy.append(BarChartDataEntry(x: Double(i), y: VC?.protein ?? 0))
//            VC?.carbsChartDataSetCopy.append(BarChartDataEntry(x: Double(i), y: VC?.carbs ?? 0))
//            VC?.fatChartDataSetCopy.append(BarChartDataEntry(x: Double(i), y: VC?.fat ?? 0))
//            VC?.lineChartDataSetCopy.append(ChartDataEntry(x: Double(i), y: VC?.calories ?? 0))
            
        }
    }
    
    //MARK: - Button Methods
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)  
    }
    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.25) {
                self.dayView.alpha = 1
                self.dateLabel.alpha = 0
                self.dateLabel.text = self.dateAsString
                self.dateLabel.alpha = 1
                self.weekView.alpha = 0
                self.monthView.alpha = 0
            }
            // Set views not displayed to 'hidden' to avoid receiving incorrect touch events
            dayView.isHidden = false
            weekView.isHidden = true
            monthView.isHidden = true
        case 1:
            UIView.animate(withDuration: 0.25) {
                self.dayView.alpha = 0
                self.dateLabel.alpha = 0
                //self.dateLabel.text = "This Week"
                self.dateLabel.alpha = 1
                self.weekView.alpha = 1
                self.monthView.alpha = 0
            }
            dayView.isHidden = true
            weekView.isHidden = false
            monthView.isHidden = true
            dateLabel.text = "Week Starting: \(formatter.string(from: startOfWeekDate ?? Date()))"
        default:
            UIView.animate(withDuration: 0.25) {
                self.dayView.alpha = 0
                self.weekView.alpha = 0
                self.dateLabel.alpha = 0
                //self.dateLabel.text = "This Month"
                self.dateLabel.alpha = 1
                self.monthView.alpha = 1
            }
            dayView.isHidden = true
            weekView.isHidden = true
            monthView.isHidden = false
            formatter.dateFormat = "LLLL"
            dateLabel.text = formatter.string(from: startOfWeekDate ?? Date())
            formatter.dateFormat = "E, d MMM"
        }
    }
    
    @IBAction func leftArrowTapped(_ sender: UIButton) {
        if segmentedControl.selectedSegmentIndex == 0 {
            
            guard let today = date else { return }
            
            // Yesterday's date at time: 00:00
            guard var yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
            yesterday = calendar.startOfDay(for: yesterday)
            setFoodList(date: yesterday)
            date = yesterday
            
            let totalCalsArray = (foodList?.value(forKey: "calories")) as! [Int]
            calories = totalCalsArray.reduce(0, +)
            
            let dayVC = children.first as? DayNutritionViewController
            dayVC?.foodList = foodList
            dayVC?.calories = calories
            
            UIView.animate(withDuration: 0.35) {
                self.dateLabel.alpha = 0
                self.dateLabel.text = self.dateAsString
                self.dateLabel.alpha = 1
            }
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                var viewRightFrame = self.dayView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.dayView.frame = viewRightFrame
            }, completion: nil)
            
            dayVC?.reloadFood()
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            
            setUpWeekView(direction: .backward, date: startOfWeekDate, considerToday: false)
            dateLabel.text = "Week Starting: \(formatter.string(from: startOfWeekDate ?? Date()))"

            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                var viewRightFrame = self.weekView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.weekView.frame = viewRightFrame
                
            }, completion: nil)
            
            weekVC?.reloadFood()
        }
        else {
            print(dateCopy)
            
            formatter.dateFormat = "LLLL"
            dateLabel.text = formatter.string(from: dateCopy ?? Date())
            formatter.dateFormat = "E, d MMM"
            setUpMonthView(direction: .backward, date: dateCopy, considerToday: false)
            
            print(dateCopy)
            //print(startOfWeekDate)
            print(".")
            print(monthView.frame)
            self.monthView.frame = self.monthView.frame.offsetBy(dx: -self.monthView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                print(self.monthView.frame)
                var viewRightFrame = self.monthView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.monthView.frame = viewRightFrame
                
            }, completion: { completed in
                print(self.monthView.frame)
                self.monthView.superview?.setNeedsLayout()
            })
            
            monthVC?.reloadFood()
        }
        
    }
    
    
    
    @IBAction func rightArrowTapped(_ sender: UIButton) {
        if segmentedControl.selectedSegmentIndex == 0 {
            
            guard let today = date else { return }
            
            // Tomorrow's date at time: 00:00
            guard var tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return }
            tomorrow = calendar.startOfDay(for: tomorrow)
            setFoodList(date: tomorrow)
            date = tomorrow
            
            let totalCalsArray = (foodList?.value(forKey: "calories")) as! [Int]
            calories = totalCalsArray.reduce(0, +)
            
            let dayVC = children.first as? DayNutritionViewController
            dayVC?.foodList = foodList
            dayVC?.calories = calories
            
            UIView.animate(withDuration: 0.25) {
                self.dateLabel.alpha = 0
                self.dateLabel.text = self.dateAsString
                self.dateLabel.alpha = 1
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                var viewLeftFrame = self.dayView.frame
                viewLeftFrame.origin.x -= viewLeftFrame.size.width
                self.dayView.frame = viewLeftFrame
            }, completion: nil)
            
            dayVC?.reloadFood()
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            
            setUpWeekView(direction: .forward, date: startOfWeekDate, considerToday: false)
            dateLabel.text = "Week Starting: \(formatter.string(from: startOfWeekDate ?? Date()))"
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                var viewLeftFrame = self.weekView.frame
                viewLeftFrame.origin.x -= viewLeftFrame.size.width
                self.weekView.frame = viewLeftFrame
            }, completion: nil)
            
            weekVC?.reloadFood()
        }
        else { // NEEDS FIXING
            //dateCopy = startOfWeekDate
            print(dateCopy)
            setUpMonthView(direction: .forward, date: dateCopy, considerToday: false)
            print(dateCopy)
            formatter.dateFormat = "LLLL"
            dateLabel.text = formatter.string(from: dateCopy ?? Date())
            formatter.dateFormat = "E, d MMM"
            
            self.monthView.frame = self.monthView.frame.offsetBy(dx: self.monthView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                var viewLeftFrame = self.monthView.frame
                viewLeftFrame.origin.x -= viewLeftFrame.size.width
                self.monthView.frame = viewLeftFrame
                
            }, completion: { completed in
                self.monthView.superview?.setNeedsLayout()
            })
            
            monthVC?.reloadFood()
        }
    }
    
}


//MARK: - Date Extension

extension Date {
    public func next(_ weekday: Weekday,
                     direction: Calendar.SearchDirection = .forward,
                     considerToday: Bool = false) -> Date
    {
        let calendar = Calendar.current
        let components = DateComponents(weekday: weekday.rawValue)

        if considerToday &&
            calendar.component(.weekday, from: self) == weekday.rawValue
        {
            return self
        }
        guard let date = calendar.nextDate(after: self, matching: components, matchingPolicy: .nextTime, direction: direction)
            else {
                return Date()
        }
        
        return date
    }

    public enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}



