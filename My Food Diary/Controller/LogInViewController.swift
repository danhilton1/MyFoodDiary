//
//  LogInViewController.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 27/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class LogInViewController: UIViewController {

    typealias FinishedDownload = () -> ()
    
    private let db = Firestore.firestore()
    
    let formatter = DateFormatter()
    var allFood = [Food]()
    var testFoodArray = [Food]()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.skyBlue
        logInButton.setTitleColor(Color.skyBlue, for: .normal)
        logInButton.layer.cornerRadius = logInButton.frame.size.height / 2
        passwordTextField.placeholder = "Password"
        
        formatter.dateFormat = "E, d MMM"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    
    func loadAllFoodData(user: String?, completed: @escaping FinishedDownload) {
        
        Food.downloadAllFood(user: user!) { (allFood) in
            self.allFood = allFood
            completed()
        }
        
        
//        db.collection("users").document(user!).collection("foods").order(by: "dateValue").getDocuments() { [weak self] (foods, error) in
//            guard let strongSelf = self else { return }
//            if let error = error {
//                print("Error getting documents: \(error)")
//            }
//            else {
//                for foodDocument in foods!.documents {
//                    let foodDictionary = foodDocument.data()
//                    let food = Food()
//                    food.name = "\(foodDictionary["name"] ?? "Food")"
//                    food.meal = "\(foodDictionary["meal"] ?? Food.Meal.breakfast.stringValue)"
//                    food.date = "\(foodDictionary["date"] ?? strongSelf.formatter.string(from: Date()))"
//                    let dateValue = foodDictionary["dateValue"] as? Timestamp
//                    food.dateValue = dateValue?.dateValue()
//                    food.servingSize = "\(foodDictionary["servingSize"] ?? "100 g")"
//                    food.serving = (foodDictionary["serving"] as? Double) ?? 1
//                    food.calories = foodDictionary["calories"] as! Int
//                    food.protein = foodDictionary["protein"] as! Double
//                    food.carbs = foodDictionary["carbs"] as! Double
//                    food.fat = foodDictionary["fat"] as! Double
//                    food.isDeleted = foodDictionary["isDeleted"] as! Bool
//
//                    strongSelf.allFood.append(food)
//                }
//
//                completed()
//            }
//        }
    }
    
    
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        
        SVProgressHUD.show()
        passwordTextField.resignFirstResponder()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if error != nil {
                print(error!)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            else {
                print("Log In Successful")
                strongSelf.loadAllFoodData(user: authResult?.user.email, completed: { () in
                    strongSelf.performSegue(withIdentifier: "GoToOverview", sender: self)
                    SVProgressHUD.dismiss()
                })
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func viewTapped() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    
    
    // Methods to move up/down the messageTableView with the keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.5) {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToOverview" {
            let tabController = segue.destination as! UITabBarController
            let navController = tabController.viewControllers?.first as! UINavigationController
            let pageController = navController.viewControllers.first as! OverviewPageViewController
            pageController.allFood = allFood
        }
    }
    

}
