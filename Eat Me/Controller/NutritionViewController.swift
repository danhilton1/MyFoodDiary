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
    
    let realm = try! Realm()
    let calendar = Calendar.current
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
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
    var weekDate: Date?
    var calories = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        dateLabel.text = dateAsString
        setFoodList(date: date)
        setDataForChildVC()
        setUpWeekVC()
        
    }
    

    
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
    
    func setDataForChildVC() {
        dayView.alpha = 1
        weekView.alpha = 0
        monthView.alpha = 0
        let dayVC = children.first as? DayNutritionViewController
        //let weekVC = children[1] as? WeekNutritionViewController
        //let monthVC = children.last as? MonthNutritionViewController
        
        dayVC?.foodList = foodList
        dayVC?.calories = calories
        
        
    }
    
    func setUpWeekVC() {
        let weekVC = children[1] as? WeekNutritionViewController
        weekDate = date
        guard let today = weekDate else { return }
        let lastMonday = today.next(.monday, direction: .backward)
        weekDate = lastMonday
        
        //set chart data set to food list of each day.
        setFoodListCopy(date: weekDate)
        weekVC?.foodList = foodListCopy
        
        weekVC?.proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.protein ?? 0)],
        label: "Protein")
        weekVC?.carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.carbs ?? 0)],
        label: "Carbs")
        weekVC?.fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.fat ?? 0)],
        label: "Fat")
        
        var dateCopy = weekDate
        for i in 1...6 {
            dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())
            setFoodListCopy(date: dateCopy)
            weekVC?.foodList = foodListCopy
            
            weekVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.protein ?? 0))
            weekVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.carbs ?? 0))
            weekVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.fat ?? 0))
        }
    }
    
    
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
                self.dateLabel.text = "This Week"
                self.dateLabel.alpha = 1
                self.weekView.alpha = 1
                self.monthView.alpha = 0
            }
            dayView.isHidden = true
            weekView.isHidden = false
            monthView.isHidden = true
            dateLabel.text = "Week Starting: \(formatter.string(from: weekDate ?? Date()))"
        default:
            UIView.animate(withDuration: 0.25) {
                self.dayView.alpha = 0
                self.weekView.alpha = 0
                self.dateLabel.alpha = 0
                self.dateLabel.text = "This Month"
                self.dateLabel.alpha = 1
                self.monthView.alpha = 1
            }
            dayView.isHidden = true
            weekView.isHidden = true
            monthView.isHidden = false
        }
    }
    
    @IBAction func leftArrowTapped(_ sender: UIButton) {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let today = date else { return }
            
            // Yesterday's date at time: 00:00
            guard var yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return }
            yesterday = calendar.startOfDay(for: yesterday)
            yesterday = calendar.date(byAdding: .hour, value: 1, to: yesterday) ?? yesterday
            setFoodList(date: yesterday)
            date = yesterday
            
            
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
                var viewRightFrame = self.dayView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.dayView.frame = viewRightFrame
                
            }, completion: nil)
            
            dayVC?.reloadFood()
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            guard let today = weekDate else { return }
            let lastMonday = today.next(.monday, direction: .backward)
            weekDate = lastMonday
            dateLabel.text = "Week Starting: \(formatter.string(from: weekDate ?? Date()))"
            
            //set chart data set to food list of each day.
            setFoodListCopy(date: weekDate)
            let weekVC = children[1] as? WeekNutritionViewController
            weekVC?.foodList = foodListCopy
            
            weekVC?.proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.protein ?? 0)],
            label: "Protein")
            weekVC?.carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.carbs ?? 0)],
            label: "Carbs")
            weekVC?.fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.fat ?? 0)],
            label: "Fat")
            
            var dateCopy = weekDate
            for i in 1...6 {
                dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())
                setFoodListCopy(date: dateCopy)
                weekVC?.foodList = foodListCopy
                
                weekVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.protein ?? 0))
                weekVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.carbs ?? 0))
                weekVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.fat ?? 0))
            }

            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                var viewRightFrame = self.weekView.frame
                viewRightFrame.origin.x += viewRightFrame.size.width
                self.weekView.frame = viewRightFrame
                
            }, completion: nil)
            
            weekVC?.reloadFood()
            

        }
        
    }
    
    
    
    @IBAction func rightArrowTapped(_ sender: UIButton) {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let today = date else { return }
            
            // Yesterday's date at time: 00:00
            guard var tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return }
            tomorrow = calendar.startOfDay(for: tomorrow)
            tomorrow = calendar.date(byAdding: .hour, value: 1, to: tomorrow) ?? tomorrow
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
            guard let today = weekDate else { return }
            let nextMonday = today.next(.monday, direction: .forward)
            weekDate = nextMonday
            dateLabel.text = "Week Starting: \(formatter.string(from: weekDate ?? Date()))"
            
            //set chart data set to food list of each day.
            setFoodListCopy(date: weekDate)
            let weekVC = children[1] as? WeekNutritionViewController
            weekVC?.foodList = foodListCopy
            
            weekVC?.proteinChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.protein ?? 0)],
            label: "Protein")
            weekVC?.carbsChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.carbs ?? 0)],
            label: "Carbs")
            weekVC?.fatChartDataSet = BarChartDataSet(entries: [BarChartDataEntry(x: 0, y: weekVC?.fat ?? 0)],
            label: "Fat")
            
            var dateCopy = weekDate
            for i in 1...6 {
                dateCopy = calendar.date(byAdding: .day, value: 1, to: dateCopy ?? Date())
                setFoodListCopy(date: dateCopy)
                weekVC?.foodList = foodListCopy
                
                weekVC?.proteinChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.protein ?? 0))
                weekVC?.carbsChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.carbs ?? 0))
                weekVC?.fatChartDataSet.append(BarChartDataEntry(x: Double(i), y: weekVC?.fat ?? 0))
            }
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                var viewLeftFrame = self.weekView.frame
                viewLeftFrame.origin.x -= viewLeftFrame.size.width
                self.weekView.frame = viewLeftFrame
            }, completion: nil)
            
            weekVC?.reloadFood()
        }
    }
    
}


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
        let date = calendar.nextDate(after: self, matching: components, matchingPolicy: .nextTime, direction: direction)!
        
        guard let nextDate = calendar.date(byAdding: .hour, value: 1, to: date) else { return date }
        
        return nextDate
    }

    public enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}



