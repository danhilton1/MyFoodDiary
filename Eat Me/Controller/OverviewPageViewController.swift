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
    
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let overviewVC = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController {
            
            // Set the PageViewController nav bar to the same as OverviewViewController
            //            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 30)!]
            self.navigationItem.title = overviewVC.navigationItem.title
            self.navigationItem.leftBarButtonItems = overviewVC.navigationItem.leftBarButtonItems
            self.navigationItem.rightBarButtonItems = overviewVC.navigationItem.rightBarButtonItems
            
            setViewControllers([overviewVC], direction: .forward, animated: true, completion: nil)
            
            // Set the inital view controller date property
            let initalVC = viewControllers?.first as! OverviewViewController
            initalVC.date = Date()
            
        }
    }
    
    private func overviewViewController(for date: Date) -> OverviewViewController? {
        // Return a new instance of OverviewViewController and set the date property.
        
        guard let overviewPage = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController else { return nil }
        
        navigationItem.leftBarButtonItems = overviewPage.navigationItem.leftBarButtonItems
        navigationItem.rightBarButtonItems = overviewPage.navigationItem.rightBarButtonItems
        
        overviewPage.configureWith(date: date)
        
        return overviewPage
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let today = (viewController as! OverviewViewController).date else { return nil }
        
        // Yesterday's date at time: 00:00
        guard var yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
        yesterday = calendar.startOfDay(for: yesterday)
        yesterday = calendar.date(byAdding: .hour, value: 1, to: yesterday) ?? yesterday
        
        return overviewViewController(for: yesterday)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let today = (viewController as! OverviewViewController).date else { return nil }
        
        // Tomorrow's date at time: 00:00
        guard var tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }
        tomorrow = calendar.startOfDay(for: tomorrow)
        tomorrow = calendar.date(byAdding: .hour, value: 1, to: tomorrow) ?? tomorrow
        
        return overviewViewController(for: tomorrow)
        
    }
    
    
    @IBAction func goToToday(_ sender: Any) {
        
        present(overviewViewController(for: Date())!, animated: true, completion: nil)
        
    }


}

extension Notification.Name {
    // Create a new notification name
    static let dateNotification = Notification.Name(rawValue: dateNotificationKey)
}

