//
//  PageViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 06/07/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//
import Foundation
import UIKit
import Firebase

class OverviewPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    //MARK:- Properties
    
    let calendar = Calendar.current
    
    var dateEnteredFromPicker = false
    var dateFromDatePicker: Date?
    let formatter = DateFormatter()
    
    var allFood = [Food]()
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.leftBarButtonItems = nil
        dataSource = self
        formatter.dateFormat = "E, d MMM"
        
        
        if let overviewVC = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController {
            // Set the inital VC date property to current date
            overviewVC.date = Date()
            overviewVC.allFood = allFood
            setViewControllers([overviewVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK:- PageViewController Datasource Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if dateEnteredFromPicker {
            
            guard let today = dateFromDatePicker else { return nil }
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
            //yesterday = calendar.startOfDay(for: yesterday)
            
            return overviewViewController(for: yesterday)
        }
        else {
        
            guard let today = (viewController as! OverviewViewController).date else { return nil }
            
            // Yesterday's date at time: 00:00
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
            
            return overviewViewController(for: yesterday)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if dateEnteredFromPicker {
            
            guard let today = dateFromDatePicker else { return nil }
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }
            //tomorrow = calendar.startOfDay(for: tomorrow)
            
            return overviewViewController(for: tomorrow)
            
        }
        else {
            guard let today = (viewController as! OverviewViewController).date else { return nil }
            
            // Tomorrow's date at time: 00:00
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }
            
            return overviewViewController(for: tomorrow)
        }
        
    }
    
    
    private func overviewViewController(for date: Date) -> OverviewViewController? {
        // Return a new instance of OverviewViewController and set the date property.
        
        guard let overviewPage = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController else { return nil }
        
        if date == calendar.startOfDay(for: Date()) {
            overviewPage.configureWith(date: Date())
        }
        else {
            overviewPage.configureWith(date: date)
        }
        
        
        overviewPage.allFood = allFood
        dateEnteredFromPicker = false
        
        return overviewPage
    }
    
    
    //MARK:- Button Methods
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let newEntrySB = UIStoryboard(name: "NewEntry", bundle: nil)
        guard
            let navController = newEntrySB.instantiateInitialViewController() as? UINavigationController,
            let newEntryVC = navController.viewControllers.first as? NewEntryViewController,
            let vc = viewControllers?[0] as? OverviewViewController
            else {
                return
        }
        newEntryVC.delegate = vc
        newEntryVC.date = vc.date
        newEntryVC.allFood = vc.allFood
        present(navController, animated: true)
    }
}



