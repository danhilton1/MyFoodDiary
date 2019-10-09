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
        
        navigationController?.navigationBar.barTintColor = Color.skyBlue
        
        dataSource = self
        
        if let overviewVC = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController {
            
            // Set the inital VC date property to current date
            overviewVC.date = Date()

            setViewControllers([overviewVC], direction: .forward, animated: true, completion: nil)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        presentingViewController?.tabBarController?.tabBar.isHidden = false
        let VC = viewControllers![0] as! OverviewViewController
        VC.loadAllFood()
    }
    
    
    //MARK:- PageViewController Datasource Methods
    
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
    
    
    private func overviewViewController(for date: Date) -> OverviewViewController? {
        // Return a new instance of OverviewViewController and set the date property.
        
        guard let overviewPage = storyboard?.instantiateViewController(withIdentifier: "OverviewVC") as? OverviewViewController else { return nil }
        
        overviewPage.configureWith(date: date)
        
        
        return overviewPage
    }
    
    //MARK:- Button Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        guard
            let popupNav = storyboard?.instantiateViewController(withIdentifier: "PopUpVCNav") as? UINavigationController,
            let popupVC = popupNav.viewControllers.first as? PopUpNewEntryViewController,
            let vc = viewControllers?[0] as? OverviewViewController
            else {
                return
        }
        popupVC.delegate = vc
        popupVC.date = vc.date
        present(popupNav, animated: true)
        
    }
    
    @IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
        let vc = viewControllers?[0] as? OverviewViewController
        vc?.deleteData()
    }
    


}



