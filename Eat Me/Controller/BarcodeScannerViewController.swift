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
    
//    var video = AVCaptureVideoPreviewLayer()
    @IBOutlet weak var cameraView: UIView!
    let session = AVCaptureSession()
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
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
        video.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(video)
        
        session.startRunning()
        
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.ean13 {
                    print(object.stringValue)
                    session.stopRunning()
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
    

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
