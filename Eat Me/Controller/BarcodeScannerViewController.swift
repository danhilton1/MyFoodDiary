//
//  BarcodeScannerViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 30/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK:- Properties and Objects
    
    var date: Date?
    var foodName: String = ""
    var servingSize: String? = ""
    var calories: Int = 0
    var calories100g: Int = 0
    var protein: Double?
    var protein100g: Double?
    var carbs: Double?
    var carbs100g: Double?
    var fat: Double?
    var fat100g: Double?
    
    @IBOutlet weak var cameraView: UIView!
    private let activityIndicator = UIActivityIndicatorView()

    private let session = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    private var urlString: String!
    private let dispatchGroup = DispatchGroup()
    
    weak var delegate: NewEntryDelegate?
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setUpCameraDisplay()
        
        activityIndicator.style = .whiteLarge
        activityIndicator.frame.size = CGSize(width: 100, height: 100)
        activityIndicator.center = view.center
//        activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.addSubview(activityIndicator)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Start running the camera session again if user navigates back to this VC again scanning an item
        session.startRunning()
    }
    
    
    private func dismissViewWithAnimation() {
        
        // Custom animation to dismiss the VC from top to bottom as anmiation of NavController is fade
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismissViewWithAnimation()
    }
    
    
    //MARK:- Camera and Barcode Scanning Methods
    
    private func setUpCameraDisplay() {
        
        do {
            guard let captureDevice = captureDevice else {
                print("Error establishing capture device")
                
                // Display an error label on screen if camera fails to connect
                let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
                errorLabel.center = CGPoint(x: cameraView.bounds.midX, y: cameraView.bounds.midY)
                errorLabel.textAlignment = .center
                errorLabel.textColor = .red
                errorLabel.font = UIFont(name: "System", size: 22.0)
                errorLabel.text = "Error connecting to camera!"
                
                cameraView.addSubview(errorLabel)
                
                return
            }
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
            
        }
        catch {
            print(error)
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: .main)
        // Set the barcode types the camera can scan
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8]
        
        let video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.754)
        video.frame = cameraView.layer.bounds
//        video.masksToBounds = true
        
        cameraView.layer.addSublayer(video)

        session.startRunning()
        
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count != 0 {    // Check if there is a scanned barcode
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.ean13 || object.type == AVMetadataObject.ObjectType.ean8 {   // Check the barcode type is EAN13 or EAN8
                    
                    session.stopRunning()
                    // Dim the view while loading
                    let dimmedView = UIView()
                    dimmedView.backgroundColor = .black
                    dimmedView.alpha = 0.55
                    dimmedView.frame = cameraView.frame
                    view.addSubview(dimmedView)
                    view.bringSubviewToFront(activityIndicator)
                    activityIndicator.startAnimating()
                    
                    dispatchGroup.enter()
                    
                    guard let barcodeAsString = object.stringValue else { return }
                    urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcodeAsString).json"
                    
                    guard let url = URL(string: urlString) else { return }
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        
                        guard let data = data else { return }
                        
                        do {
                            let food = try JSONDecoder().decode(DatabaseFood.self, from: data)
                            
                            self.foodName = food.product.productName
                            if food.product.servingSize == nil {
                                // If no serving size information is available, use a default value of 100g
                                self.servingSize = "100g"
                                self.calories = food.product.nutriments.calories100g
                                self.protein = food.product.nutriments.protein100g
                                self.carbs = food.product.nutriments.carbs100g
                                self.fat = food.product.nutriments.fat100g
                                
                                self.calories100g = food.product.nutriments.calories100g
                                self.protein100g = food.product.nutriments.protein100g
                                self.carbs100g = food.product.nutriments.carbs100g
                                self.fat100g = food.product.nutriments.fat100g
                            } else {
                            
                                self.servingSize = food.product.servingSize
                                self.calories = food.product.nutriments.calories
                                self.protein = food.product.nutriments.proteinServing
                                self.carbs = food.product.nutriments.carbServing
                                self.fat = food.product.nutriments.fatServing
                                
                                self.calories100g = food.product.nutriments.calories100g
                                self.protein100g = food.product.nutriments.protein100g
                                self.carbs100g = food.product.nutriments.carbs100g
                                self.fat100g = food.product.nutriments.fat100g
                            }
                            
                            self.session.stopRunning()
                            self.dispatchGroup.leave()
                            
                        } catch {
                            DispatchQueue.main.async {  // This needs to be exectued on main thread
                                print("Error parsing JSON - \(error)")
                                
                                self.activityIndicator.stopAnimating()
                                dimmedView.removeFromSuperview()
                                self.displayErrorAlert(message: "There was an error retrieving information for this barcode.")
                            }
                            
                        }
                        
                        }.resume()
                    
                    dispatchGroup.notify(queue: .main) {
                        self.session.stopRunning()
                        
                        self.activityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "goToFoodDetail", sender: nil)
                        dimmedView.removeFromSuperview()
                    }
                    
                } else {
                    print("Invaled barcode type")
                    displayErrorAlert(message: "This barcode type is not valid.")
                    session.stopRunning()
                    
                }
            }
        } else {
            displayErrorAlert(message: "There was an error retrieving information for this barcode.")
            session.stopRunning()
            
        }
        
    }
    
    
    //MARK:- Manual Barcode Entry Method
    
    @IBAction func enterManuallyTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Enter Barcode", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter barcode here"
        }
        
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            
            guard let barcodeAsString = alertController.textFields![0].text else { return }
            self.urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcodeAsString).json"
            
            guard let url = URL(string: self.urlString) else { return }
            
            self.dispatchGroup.enter()
            
            let dimmedView = UIView()
            dimmedView.backgroundColor = .black
            dimmedView.alpha = 0.55
            dimmedView.frame = self.cameraView.frame
            self.view.addSubview(dimmedView)
            self.view.bringSubviewToFront(self.activityIndicator)
            self.activityIndicator.startAnimating()
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
                
                do {
                    
                    let food = try JSONDecoder().decode(DatabaseFood.self, from: data)
                    
                    self.foodName = food.product.productName
                    if food.product.servingSize == nil {
                        
                        self.servingSize = "100g"
                        self.calories = food.product.nutriments.calories100g
                        self.protein = food.product.nutriments.protein100g
                        self.carbs = food.product.nutriments.carbs100g
                        self.fat = food.product.nutriments.fat100g
                        
                        self.calories100g = food.product.nutriments.calories100g
                        self.protein100g = food.product.nutriments.protein100g
                        self.carbs100g = food.product.nutriments.carbs100g
                        self.fat100g = food.product.nutriments.fat100g
                        
                    } else {
                        
                        self.servingSize = food.product.servingSize
                        self.calories = food.product.nutriments.calories
                        self.protein = food.product.nutriments.proteinServing
                        self.carbs = food.product.nutriments.carbServing
                        self.fat = food.product.nutriments.fatServing
                        
                        self.calories100g = food.product.nutriments.calories100g
                        self.protein100g = food.product.nutriments.protein100g
                        self.carbs100g = food.product.nutriments.carbs100g
                        self.fat100g = food.product.nutriments.fat100g
                    }
                    self.dispatchGroup.leave()
                    
                } catch {

                    DispatchQueue.main.async {
                        print("Error parsing JSON - \(error)")
                        
                        self.activityIndicator.stopAnimating()
                        dimmedView.removeFromSuperview()
                        self.displayErrorAlert(message: "There was an error retrieving information for this barcode.")
                    }
                    
                }
                
                }.resume()
            
            self.dispatchGroup.notify(queue: .main, execute: {
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "goToFoodDetail", sender: nil)
                dimmedView.removeFromSuperview()
            })

        }))
    
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
        session.stopRunning()
        
    }
    
    
    func displayErrorAlert(message: String) {
        
        let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.session.startRunning()
        }))
        
        present(alertController, animated: true)
        
        
    }
    
    
    
    //MARK:- Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            let vc = segue.destination as! FoodDetailViewController
            
            vc.delegate = delegate
            vc.date = date
            
            vc.foodName = foodName
            vc.servingSize = servingSize ?? "100g"
            vc.calories = calories
            vc.protein = protein
            vc.carbs = carbs
            vc.fat = fat
            
            vc.calories100g = calories100g
            vc.protein100g = protein100g
            vc.carbs100g = carbs100g
            vc.fat100g = fat100g
            
        }
        
        
    }
    
}


