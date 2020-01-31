//
//  NutritionViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 11/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class NutritionViewController: UIViewController {
    
    //MARK: - Properties and Objects
    
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
//    var foodList: Results<Food>?
//    var foodListCopy: Results<Food>?
    var allFood: [Food]?
    var foodList: [Food]?
    var foodListCopy: [Food]?
    
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
    var startOfWeekVCDate: Date?
    var endOfWeekDate: Date?
    var dateCopy: Date?
    var monthChartLabels = [String]()
    var calories = 0
    
    //MARK: - viewDidLoad Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        setUpNavBar()
        weekVC = children[1] as? WeekNutritionViewController
        monthVC = children.last as? MonthNutritionViewController
        dateLabel.text = dateAsString
        setFoodList(date: date)
        setDataForInitalChildVC()
        
        setUpWeekView(direction: .backward, date: date, considerToday: true)
        setUpMonthView(direction: .backward, date: date, considerToday: true)
        setUpWeekView(direction: .backward, date: date, considerToday: true)
        
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
    
    //MARK: - Set Data Methods
    
    func setFoodList(date: Date?) {

        foodList = [Food]()
        for food in allFood! {
            if food.date == formatter.string(from: date ?? Date()) && !food.isDeleted {
                foodList!.append(food)
            }
        }
    }
    
    func setFoodListCopy(date: Date?) {

        foodListCopy = [Food]()
        for food in allFood! {
            if food.date == formatter.string(from: date ?? Date()) && !food.isDeleted {
                foodListCopy!.append(food)
            }
        }
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
        startOfWeekVCDate = monday
        
        setFoodListCopy(date: startOfWeekVCDate)
        weekVC?.foodList = foodListCopy
        // Set chart data set to food list of last monday.
        guard let weekView = weekVC else { return }
        
        weekVC?.proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: round(weekView.protein))],
        label: "Protein")
        weekVC?.carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: round(weekView.carbs) )],
        label: "Carbs")
        weekVC?.fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: round(weekView.fat) )],
        label: "Fat")
        weekVC?.lineChartDataSet = LineChartDataSet(entries: [ChartDataEntry(x: 0, y: round(weekView.calories) )], label: "Calories")
        
        var dateCopy = startOfWeekVCDate
        // Append new entries to data sets from each day of the week
        for i in 1...6 {
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())!
            setFoodListCopy(date: dateCopy)
            weekVC?.foodList = foodListCopy
            weekVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: round(weekView.protein)))
            weekVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: round(weekView.carbs)))
            weekVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: round(weekView.fat)))
            weekVC?.lineChartDataSet.append(ChartDataEntry(x: Double(i), y: round(weekView.calories)))
        }
    }
    
    
    func setUpMonthView(direction: Calendar.SearchDirection, date: Date?, considerToday: Bool) {

        guard let today = date else { return }
        let monday = today.next(.monday, direction: direction, considerToday: considerToday).addingTimeInterval(3600) //Get date of last/next monday
        var sunday: Date
        // Get sunday/endOfWeekDate to display the date in chart labels and also for when right arrow is tapped
        // to make sure correct weeks are displayed and none are repeated
        if considerToday == false {
            sunday = today.next(.sunday, direction: .forward, considerToday: considerToday).addingTimeInterval(-601200)
        }
        else {
            sunday = today.next(.sunday, direction: .forward, considerToday: considerToday)
        }
        if direction == .forward {
            sunday = monday.next(.sunday, direction: .forward, considerToday: considerToday).addingTimeInterval(3600)
        }
        endOfWeekDate = sunday
        startOfWeekDate = monday

        formatter.dateFormat = "d MMM"
        monthChartLabels = [formatter.string(from: startOfWeekDate ?? Date()) + " - " + formatter.string(from: endOfWeekDate ?? Date())]
        //set chart data set to food list of each day.
        setFoodListCopy(date: startOfWeekDate)
        monthVC?.foodList = foodListCopy
        
        if considerToday {  // on inital load of VC, use the average values from weekVC otherwise calculate them from method
            monthVC?.monthAverageProtein = weekVC?.averageProtein.roundToXDecimalPoints(decimalPoints: 1) ?? 0
            monthVC?.monthAverageCarbs = weekVC?.averageCarbs.roundToXDecimalPoints(decimalPoints: 1) ?? 0
            monthVC?.monthAverageFat = weekVC?.averageFat.roundToXDecimalPoints(decimalPoints: 1) ?? 0
            monthVC?.monthAverageCalories = weekVC?.getAverageOfValue(dataSet: weekVC!.lineChartDataSet)
        }
        else {
            getAverageValuesForWeek(date: startOfWeekDate)
            monthVC?.monthAverageProtein = weekVC?.averageProteinCopy.roundToXDecimalPoints(decimalPoints: 1) ?? 0
            monthVC?.monthAverageCarbs = weekVC?.averageCarbsCopy.roundToXDecimalPoints(decimalPoints: 1) ?? 0
            monthVC?.monthAverageFat = weekVC?.averageFatCopy.roundToXDecimalPoints(decimalPoints: 1) ?? 0
            monthVC?.monthAverageCalories = weekVC?.getAverageOfValue(dataSet: weekVC!.lineChartDataSetCopy)
        }
        
        // Set first entry in chart data set to the average values of the week starting from last Monday
        monthVC?.proteinChartDataSet = BarChartDataSet(entries:
            [BarChartDataEntry(x: 0, y: monthVC?.monthAverageProtein?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Av. Protein (Day)")
        monthVC?.carbsChartDataSet = BarChartDataSet(entries:
            [BarChartDataEntry(x: 0, y: monthVC?.monthAverageCarbs?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Av. Carbs (Day)")
        monthVC?.fatChartDataSet = BarChartDataSet(entries:
            [BarChartDataEntry(x: 0, y: monthVC?.monthAverageFat?.roundToXDecimalPoints(decimalPoints: 1) ?? 0)],
             label: "Av. Fat (Day)")
        monthVC?.lineChartDataSet = LineChartDataSet(entries:
            [ChartDataEntry(x: 0, y: round(monthVC?.monthAverageCalories ?? 0))],
             label: "Av. Calories (Day)")
        
        dateCopy = startOfWeekDate // use dateCopy instead of startOfWeekDate to not affect other code using startOfWeekDate
        
        var value = 0  // value of days to add or subtract from the currect day
        if direction == .backward {
            value = -7
        }
        else {
            value = 7
        }
        dateCopy = dateCopy?.addingTimeInterval(3600)  // to accomodate for daylight saving times
        dateCopy = calendar.startOfDay(for: dateCopy!)
        
        for i in 1...3 {   // Loop through the next weeks of the month and retrive the average values and append to chart data
            
            dateCopy = calendar.date(byAdding: .day, value: value, to: dateCopy ?? Date())
            let sunday = dateCopy!.next(.sunday, direction: .forward, considerToday: considerToday).addingTimeInterval(3600)
            monthChartLabels.append(formatter.string(from: dateCopy ?? Date()) + " - " + formatter.string(from: sunday))
            
            getAverageValuesForWeek(date: dateCopy)
            
            monthVC?.monthAverageProtein = weekVC?.averageProteinCopy.roundToXDecimalPoints(decimalPoints: 1)
            monthVC?.monthAverageCarbs = weekVC?.averageCarbsCopy.roundToXDecimalPoints(decimalPoints: 1)
            monthVC?.monthAverageFat = weekVC?.averageFatCopy.roundToXDecimalPoints(decimalPoints: 1)
            monthVC?.monthAverageCalories = weekVC?.getAverageOfValue(dataSet: weekVC!.lineChartDataSetCopy)
            //print(monthVC?.monthAverageProtein)
            setFoodListCopy(date: dateCopy)
            monthVC?.foodListCopy = foodListCopy
            monthVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: monthVC?.monthAverageProtein?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
            monthVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: monthVC?.monthAverageCarbs?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
            monthVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: monthVC?.monthAverageFat?.roundToXDecimalPoints(decimalPoints: 1) ?? 0))
            monthVC?.lineChartDataSet.append(ChartDataEntry(x: Double(i), y: round(monthVC?.monthAverageCalories ?? 0)))
        }
        
        if direction == .forward {
            endOfWeekDate = dateCopy!.next(.sunday, direction: .forward, considerToday: considerToday)
            dateCopy = calendar.date(byAdding: .day, value: -21, to: dateCopy ?? Date())
        }
        formatter.dateFormat = "E, d MMM"
    }
    
    func getAverageValuesForWeek(date: Date?) {
        // Retrieves the values for the week that is set in the method call and sets the chart data set to averages values for selected week
        formatter.dateFormat = "E, d MMM"
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

        }
        formatter.dateFormat = "d MMM"
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
            dateLabel.text = "Week Starting: \(formatter.string(from: startOfWeekVCDate ?? Date()))"
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
            formatter.dateFormat = "d MMM"
            dateLabel.text = formatter.string(from: dateCopy ?? Date()) + " - " + formatter.string(from: endOfWeekDate ?? Date())
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
            
            var totalCalsArray = [Int]()
            for food in foodList! {
                totalCalsArray.append(food.calories)
            }
            calories = totalCalsArray.reduce(0, +)
            
            let dayVC = children.first as? DayNutritionViewController
            dayVC?.foodList = foodList
            dayVC?.calories = calories
            
            UIView.animate(withDuration: 0.35) {
                self.dateLabel.alpha = 0
                self.dateLabel.text = self.dateAsString
                self.dateLabel.alpha = 1
            }
            self.dayView.frame = self.dayView.frame.offsetBy(dx: -self.dayView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                var viewRightFrame = self.dayView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.dayView.frame = viewRightFrame
            }, completion: nil)
            
            dayVC?.reloadFood()
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            
            setUpWeekView(direction: .backward, date: startOfWeekVCDate, considerToday: false)
            dateLabel.text = "Week Starting: \(formatter.string(from: startOfWeekVCDate ?? Date()))"

            self.weekView.frame = self.weekView.frame.offsetBy(dx: -self.weekView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                var viewRightFrame = self.weekView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.weekView.frame = viewRightFrame
                
            }, completion: nil)
            
            weekVC?.reloadFood()
        }
        else {
            monthVC?.direction = .backward
            setUpMonthView(direction: .backward, date: dateCopy?.addingTimeInterval(3600), considerToday: false)
            formatter.dateFormat = "d MMM"
            dateLabel.text = formatter.string(from: dateCopy ?? Date()) + " - " + formatter.string(from: endOfWeekDate ?? Date())
            formatter.dateFormat = "E, d MMM"

            self.monthView.frame = self.monthView.frame.offsetBy(dx: -self.monthView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                var viewRightFrame = self.monthView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.monthView.frame = viewRightFrame
                
            }, completion: { completed in
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
            
            var totalCalsArray = [Int]()
            for food in foodList! {
                totalCalsArray.append(food.calories)
            }
            
            calories = totalCalsArray.reduce(0, +)
            
            let dayVC = children.first as? DayNutritionViewController
            dayVC?.foodList = foodList
            dayVC?.calories = calories
            
            UIView.animate(withDuration: 0.25) {
                self.dateLabel.alpha = 0
                self.dateLabel.text = self.dateAsString
                self.dateLabel.alpha = 1
            }
            self.dayView.frame = self.dayView.frame.offsetBy(dx: self.dayView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                var viewLeftFrame = self.dayView.frame
                viewLeftFrame.origin.x -= viewLeftFrame.size.width
                self.dayView.frame = viewLeftFrame
            }, completion: nil)
            
            dayVC?.reloadFood()
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            
            setUpWeekView(direction: .forward, date: startOfWeekVCDate, considerToday: false)
            dateLabel.text = "Week Starting: \(formatter.string(from: startOfWeekVCDate ?? Date()))"
            
            self.weekView.frame = self.weekView.frame.offsetBy(dx: self.weekView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                var viewLeftFrame = self.weekView.frame
                viewLeftFrame.origin.x -= viewLeftFrame.size.width
                self.weekView.frame = viewLeftFrame
            }, completion: nil)
            
            weekVC?.reloadFood()
        }
        else {
            monthVC?.direction = .forward
            setUpMonthView(direction: .forward, date: endOfWeekDate, considerToday: false)
            
            formatter.dateFormat = "d MMM"
            dateLabel.text = formatter.string(from: dateCopy ?? Date()) + " - " + formatter.string(from: endOfWeekDate ?? Date())
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



