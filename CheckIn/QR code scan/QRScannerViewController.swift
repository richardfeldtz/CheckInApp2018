//
//  QRScannerViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 04/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class QRScannerViewController : UIViewController {
    
    //Variable used to identify selected student before passing it to the profile view
    var selectedStudent: StudentData?
    
    //Variable used to store the shared data
    var sharedData: String?
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var scan = true
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        //Reset scanner when view appears
        scan = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 5
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
        
        let roundButton = UIButton(frame: .init(x: 0, y: 0, width: 100, height: 100))
        roundButton.addTarget(self, action: #selector(self.returnToStudentList), for: .touchUpInside)
        roundButton.layer.cornerRadius = 0.5 * roundButton.bounds.size.width
        roundButton.backgroundColor=ColorHelper.navBarColor
        //roundButton.clipsToBounds = true
        roundButton.setImage(#imageLiteral(resourceName: "icons8-menu-filled-100"), for: .normal)
        roundButton.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        roundButton.imageView?.layer.masksToBounds = true
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        roundButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        roundButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        roundButton.layer.shadowOpacity = 1.0
        roundButton.layer.shadowRadius = 0.0
        roundButton.layer.borderWidth = 2.0
        roundButton.layer.masksToBounds = false
        
        view.addSubview(roundButton)
        NSLayoutConstraint.activate([
            roundButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            roundButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            roundButton.widthAnchor.constraint(equalToConstant: 100),
            roundButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func analyzeInput(_ code:String){
        if scan {
            scan = false
            
            if code.contains(":")
            {
                sharedData = code
                self.performSegue(withIdentifier: "dataRead", sender: self)
            }
            else {
            
                let index = StudentListViewController.idmap[code]
                if(index == nil){
                    //Show alert
                    print("Not found : "+code)
                    scan = true
                }
                else {
                    selectedStudent = StudentListViewController.data[index!]
                    self.performSegue(withIdentifier: "scanProfile", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let profile = segue.destination as? ProfileViewController
        {
            
            profile.name = (selectedStudent?.name)!
            profile.id = (selectedStudent?.id)!
            profile.sname = (selectedStudent?.sname)!
            profile.alreadyChecked = (selectedStudent?.checked)!
            
        }
        else if let dataRead = segue.destination as? DataReadViewController
        {
            dataRead.data = sharedData!
        }
    }
    
    @objc func returnToStudentList() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            let codeString = metadataObj.stringValue
            if codeString != nil {
                analyzeInput(codeString!)
            }
        }
    }
    
}
