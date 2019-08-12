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
    
    var foodName: String?
    var servingSize: String?
    var calories: Int?
    var protein: Int?
    var carbs: Double?
    var fat: Double?
    
    
    @IBOutlet weak var cameraView: UIView!

    let session = AVCaptureSession()
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    
    
    var urlString: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationController?.navigationBar.barTintColor = UIColor.flatSkyBlue()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setUpCameraDisplay()
        
    }
    
    func setUpCameraDisplay() {
        
        do {
            guard let captureDevice = captureDevice else {
                print("Error establishing capture device")
                
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
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
        
        let video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.754)
        video.frame = cameraView.layer.bounds
//        video.masksToBounds = true
        
        cameraView.layer.addSublayer(video)
        
        
        session.startRunning()
        
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.ean13 {
                    
                    let activityIndicator = UIActivityIndicatorView()
                    activityIndicator.style = .gray
                    activityIndicator.frame.size = CGSize(width: 80, height: 80)
                    activityIndicator.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                    view.addSubview(activityIndicator)
                    view.bringSubviewToFront(activityIndicator)
                    activityIndicator.startAnimating()
                    
                    guard let barcodeAsString = object.stringValue else { return }
                    urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcodeAsString).json"
                    
                    guard let url = URL(string: urlString) else { return }
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        
                        guard let data = data else { return }
                        
                        do {
                            
                            let food = try JSONDecoder().decode(DatabaseFood.self, from: data)
                            self.calories = food.product.nutriments.calories
                            print(food.product.nutriments.proteins_100g)
                            print(food.product.nutriments.carbohydrates_100g)
                            print(food.product.nutriments.fat_100g)
                            print(food.product.serving_size)
                            print(food.product.product_name)
                            
                            
                            
                        } catch {
                            print("Error parsing JSON - \(error)")
                        }
                        
                        }.resume()
                    
                    
                    session.stopRunning()
                    
                    activityIndicator.stopAnimating()
                    
                    dismissViewWithAnimation()
                    
                } else {
                    print("Invaled barcode type")
                    session.stopRunning()
                }
            }
        } else {
            print("There was an error retrieving information for this barcode.")
            session.stopRunning()
        }
        
    }
    
    @IBAction func enterManuallyTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Enter Barcode", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter barcode here"
        }
        
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            
            guard let barcodeAsString = alertController.textFields![0].text else { return }
            self.urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcodeAsString).json"
            
            guard let url = URL(string: self.urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
                
                do {
                    
                    let food = try JSONDecoder().decode(DatabaseFood.self, from: data)
                    print(food.product.nutriments.calories)
                    print(food.product.nutriments.proteins_100g)
                    print(food.product.nutriments.carbohydrates_100g)
                    print(food.product.nutriments.fat_100g)
                    print(food.product.serving_size)
                    print(food.product.product_name)
                    
                    self.dismissViewWithAnimation()
                    
                } catch {
                    print("Error parsing JSON - \(error)")
                    self.dismissViewWithAnimation()
                }
                
                }.resume()
            
            self.dismissViewWithAnimation()
        }))
    
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
        
    }
    
    

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        
        dismissViewWithAnimation()
        
    }
    
    
    func dismissViewWithAnimation() {
        
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            let vc = segue.destination as! FoodDetailViewController
            
            
            
        }
        
        
    }
    
}


