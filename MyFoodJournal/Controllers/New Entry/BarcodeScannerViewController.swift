//
//  BarcodeScannerViewController.swift
//  Eat Me
//
//  Created by Daniel Hilton on 30/06/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//
// 


import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    //MARK:- Properties and Objects
    
    var food: Food?
    var workingCopy: Food = Food()
    
    var selectedSegmentIndex = 0
    var date: Date?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var enterBarcodeButton: UIButton!
    private let activityIndicator = UIActivityIndicatorView()

    private let session = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    private var urlString: String = ""
    private let dispatchGroup = DispatchGroup()
    private let dimmedView = UIView()
    
    weak var delegate: NewEntryDelegate?
    weak var mealDelegate: NewEntryDelegate?
    
    //MARK:- View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        setUpCameraDisplay()

        view.addSubview(activityIndicator)
        setUpActivityIndicator()

        if let food = food {
            workingCopy = food.copy()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        workingCopy.date = formatter.string(from: date ?? Date())
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Start running the camera session again if user navigates back to this VC again after scanning an item
        super.viewWillAppear(true)
        dimmedView.removeFromSuperview()
        session.startRunning()
        presentingViewController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presentingViewController?.tabBarController?.tabBar.isHidden = false
    }
    
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setUpActivityIndicator() {
        activityIndicator.style = .whiteLarge
        activityIndicator.frame.size = CGSize(width: 100, height: 100)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    //MARK:- Camera and Barcode Scanning Methods
    
    private func setUpCameraDisplay() {
        
        do {
            guard let captureDevice = captureDevice else {
                // Display an error label on screen if camera fails to connect
                configureCameraErrorLabel()
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
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.upce]
        
        let video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        cameraView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: enterBarcodeButton.topAnchor).isActive = true
        video.frame = cameraView.layer.bounds
        
        cameraView.layer.addSublayer(video)
        
        configureCameraUIElements()
        
        session.startRunning()
        
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count != 0 {    // Check if there is a scanned barcode
            if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.ean13 ||
                    object.type == AVMetadataObject.ObjectType.ean8 ||
                    object.type == AVMetadataObject.ObjectType.upce {   // Check the barcode type is EAN13, EAN8 or UPC-E
                    
                    session.stopRunning()
                    dimViewAndShowLoading()  // Dim the view while loading
                    
                    guard let barcode = object.stringValue else { return }
                    print(barcode)
                    DatabaseServices.retrieveDataFromBarcodeEntry(barcode: barcode) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                            
                        case .success(let food):
                            self.workingCopy = food
                            
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.dimmedView.removeFromSuperview()
                                self.performSegue(withIdentifier: "goToFoodDetail", sender: nil)
                            }
                            
                        case .failure(let error):
                            self.displayErrorAlert(message: error.rawValue)
                            
                        }
                    }
                }
                else {
                    print("Invalid barcode type")
                    displayErrorAlert(message: "This barcode type is not valid. Please try again or try searching for the item.")
                    session.stopRunning()
                }
            }
        }
        else {
            displayErrorAlert(message: "Information for this barcode could not be found. Please try searching for the item or enter details manually.")
            session.stopRunning()
        } 
    }
    
    
    //MARK:- Barcode Entry Methods
    
    @IBAction func enterManuallyTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Enter Barcode", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter barcode here"
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            
            guard let barcode = alertController.textFields?.first?.text, !barcode.isEmpty else {
                self.displayErrorAlert(message: "Please enter a valid barcode.")
                return
            }

            self.dimViewAndShowLoading()
            
            DatabaseServices.retrieveDataFromBarcodeEntry(barcode: barcode) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    
                case .success(let food):
                    self.workingCopy = food
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.dimmedView.removeFromSuperview()
                        self.performSegue(withIdentifier: "goToFoodDetail", sender: nil)
                    }
                       
                case .failure(let error):
                    self.displayErrorAlert(message: error.rawValue)
                }
            }
        }))
    
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.session.startRunning()
        }))
        
        present(alertController, animated: true)
        session.stopRunning()
        
    }
    
    
    
    //MARK: - View and UI Methods
    
    private func configureCameraErrorLabel() {
        let errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textAlignment = .center
        errorLabel.textColor = .red
        errorLabel.font = UIFont(name: "System", size: 22.0)
        errorLabel.text = "Error connecting to camera!"
        
        cameraView.addSubview(errorLabel)
        errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    private func configureCameraUIElements() {
        let torchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        cameraView.addSubview(torchButton)
        
        torchButton.setBackgroundImage(UIImage(named: "TorchIcon"), for: .normal)
        torchButton.layer.cornerRadius = 0.5
        torchButton.alpha = 0.7
        torchButton.addTarget(self, action: #selector(torchButtonTapped), for: .touchUpInside)
        torchButton.translatesAutoresizingMaskIntoConstraints = false
        
        torchButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        torchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        if UIScreen.main.bounds.height < 600 {
            torchButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
            torchButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        }
        else {
            torchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            torchButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        let viewfinderImage = UIImage(named: "view finder")
        let viewfinderImageView = UIImageView(image: viewfinderImage)
        cameraView.addSubview(viewfinderImageView)
        viewfinderImageView.contentMode = .scaleAspectFit
        viewfinderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        viewfinderImageView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        viewfinderImageView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor).isActive = true
        viewfinderImageView.heightAnchor.constraint(equalToConstant: 190).isActive = true
        viewfinderImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.5).isActive = true
    }
    
    
    private func dimViewAndShowLoading() {
        dimmedView.backgroundColor = .black
        dimmedView.alpha = 0.35
        dimmedView.frame = cameraView.frame
        view.addSubview(dimmedView)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    private func displayErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dimmedView.removeFromSuperview()
            self.session.startRunning()
        }))
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    @objc func torchButtonTapped(sender: UIButton) {
        guard let device = captureDevice else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()

            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
                sender.alpha = 0.7
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    sender.alpha = 1
                } catch {
                    print(error)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    
    //MARK:- Segue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            let vc = segue.destination as! FoodDetailViewController
            vc.food = workingCopy
            vc.delegate = delegate
            vc.mealDelegate = mealDelegate
            vc.date = date
            vc.selectedSegmentIndex = selectedSegmentIndex
            vc.isEditingExistingEntry = false
        }
    }
    
}


