//
//  PageViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 06/07/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//
import Foundation
import UIKit

class OverviewPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    
    let calendar = Calendar.autoupdatingCurrent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let overviewVC = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") {
//            overviewVC.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.title = overviewVC.navigationItem.title
            self.navigationItem.leftBarButtonItems = overviewVC.navigationItem.leftBarButtonItems
            self.navigationItem.rightBarButtonItems = overviewVC.navigationItem.rightBarButtonItems
            
            setViewControllers([overviewVC], direction: .forward, animated: true, completion: nil)
        }
        
        
    }
    
    
    private func overviewPage(for date: Date) -> OverviewViewController? {
        // Create a new OverviewViewController and set the date property.
        
        guard let overviewPage = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController else { return nil }
        
        self.navigationItem.leftBarButtonItems = overviewPage.navigationItem.leftBarButtonItems
        self.navigationItem.rightBarButtonItems = overviewPage.navigationItem.rightBarButtonItems
        
        overviewPage.date = date
//        print(overviewPage.date)
        return overviewPage
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let today = (viewController as! OverviewViewController).date else { return nil }
//        print(today)
        guard var yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
        
        yesterday = calendar.startOfDay(for: yesterday)
        
        yesterday = calendar.date(byAdding: .hour, value: 1, to: yesterday) ?? yesterday
//        print(yesterday)
        
        return overviewPage(for: yesterday)
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let today = (viewController as! OverviewViewController).date else { return nil }
        
        guard var tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }
        tomorrow = calendar.startOfDay(for: tomorrow)
        tomorrow = calendar.date(byAdding: .hour, value: 1, to: tomorrow) ?? tomorrow
        
        return overviewPage(for: tomorrow)
        
      
        
        
    }
    
    


}
