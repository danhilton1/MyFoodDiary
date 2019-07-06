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
        
        if let overviewVC = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") {
            setViewControllers([overviewVC], direction: .forward, animated: true, completion: nil)
        }
        
        
    }
    
    
    private func overviewPage(for date: Date) -> OverviewViewController? {
        // Create a new view controller and pass suitable data.
        
        guard let overviewPage = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController else { return nil }
        
        overviewPage.date = date
        
        return overviewPage
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let today = (viewController as! OverviewViewController).date else { return nil }
        guard var yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return nil }
        yesterday = calendar.startOfDay(for: yesterday)
        
        return overviewPage(for: yesterday)
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let today = (viewController as! OverviewViewController).date else { return nil }
        guard var tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }
        tomorrow = calendar.startOfDay(for: tomorrow)
        
        return overviewPage(for: tomorrow)
        
      
        
        
    }
    
    


}
