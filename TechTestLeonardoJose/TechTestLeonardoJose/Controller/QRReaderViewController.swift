//
//  QRReaderViewController.swift
//  TechTestLeonardoJose
//
//  Created by Leonardo Jose Gunawan on 22/05/24.
//

import UIKit
import AVFoundation

class QRReaderViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func StartScanning(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCaptureSession()
        }
    }

    func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Your device is not aplicable for video processing")
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Your device can't give video input.")
            return
        }
        
        if (self.captureSession.canAddInput(videoInput)) {
            self.captureSession.addInput(videoInput)
        } else {
            print("Your device can't add input in capture session")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (self.captureSession.canAddOutput(metadataOutput)) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        DispatchQueue.main.async {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer.frame = self.view.layer.bounds
            self.previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.previewLayer)
            print("Running")
            self.startCaptureSession()
        }
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
}

extension QRReaderViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let first = metadataObjects.first {
            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            guard let stringValue = readableObject.stringValue else {
                return
            }
            openURL(code: stringValue)
        } else {
            print("Not able to read the code! Please try again or be keep your device on Bar Code or Scanner Code!")
        }
    }
    
    func openURL(code: String) {
        print("Scanned QR Code: \(code)")
        
        guard let url = URL(string: code) else {
            print("Scanned QR Code is not a valid URL")
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            print("Failed to open URL: \(url)")
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("URL opened successfully: \(url)")
            } else {
                print("Failed to open URL: \(url)")
            }
        }
    }

}
