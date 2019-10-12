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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    
    var foodList: Results<Food>?
    var date: Date?
    var calories = 0
    private let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        //tableView.register(UINib(nibName: "DayNutritionCell", bundle: nil), forCellReuseIdentifier: "DayNutritionCell")
        //tableView.delegate = self
        //tableView.dataSource = self
        dayView.alpha = 1
        weekView.alpha = 0
        monthView.alpha = 0
        
        foodList = realm.objects(Food.self)
        let predicate = NSPredicate(format: "date contains[c] %@", formatter.string(from: date ?? Date()))
        foodList = foodList?.filter(predicate)
        let deletedPredicate = NSPredicate(format: "isDeleted == FALSE")
        foodList = foodList?.filter(deletedPredicate)
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
            UIView.animate(withDuration: 0.2) {
                self.dayView.alpha = 1
                self.weekView.alpha = 0
                self.monthView.alpha = 0
            }
        case 1:
            UIView.animate(withDuration: 0.2) {
                self.dayView.alpha = 0
                self.weekView.alpha = 1
                self.monthView.alpha = 0
            }
        default:
            UIView.animate(withDuration: 0.2) {
                self.dayView.alpha = 0
                self.weekView.alpha = 0
                self.monthView.alpha = 1
            }
        }
    }
    
}


//extension NutritionViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DayNutritionCell", for: indexPath) as! DayNutritionCell
//
//        let text = """
//                   \(calories)
//                   kcal
//                   """
//        let font = UIFont(name: "Montserrat-Medium", size: 16)
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .center
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: font!,
//            .paragraphStyle: paragraphStyle
//        ]
//        let attributedText = NSAttributedString(string: text, attributes: attributes)
//        cell.pieChart.centerAttributedText = attributedText
//
//        let chartDataSet = PieChartDataSet(entries: [PieChartDataEntry(value: 1.0),
//                                                     PieChartDataEntry(value: 1.0),
//                                                     PieChartDataEntry(value: 1.0)], label: nil)
//        chartDataSet.drawValuesEnabled = false
//        chartDataSet.colors = [Color.mint, Color.skyBlue, Color.salmon]
//        chartDataSet.selectionShift = 0
//        let chartData = PieChartData(dataSet: chartDataSet)
//
//        cell.pieChart.data = chartData
//
//
//
//        return cell
//    }
//
//
//}

