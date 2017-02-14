//
//  ViewController.swift
//  QR Scanner
//
//  Created by Eduardo Valencia on 2/11/17.
//  Copyright © 2017 Eduardo Valencia. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var session: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var output: AVCaptureMetadataOutput?
    var scanBorder: ScanBorder?
    var scanAcceptedBorder: UIView?
    var feedbackGenerator: UINotificationFeedbackGenerator?

    override func loadView() {
        super.loadView()
        self.view.contentMode = .redraw
        self.view.backgroundColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        self.view.layer.rasterizationScale = 2
        self.view.layer.shouldRasterize = true
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
        
        session = AVCaptureSession()
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput.init(device: device)
            session?.addInput(input)
        } catch {
            print(error.localizedDescription)
        }
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == .authorized {
            output = AVCaptureMetadataOutput()
            session?.addOutput(output)
            output?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer?.bounds = self.view.bounds
            previewLayer?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            if let previewLayer = previewLayer {
                self.view.layer.addSublayer(previewLayer)
            }
        } else {
            print("Not authorized")
        }
        
        let scanOverlay = ScanOverlay()
        scanOverlay.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scanOverlay)
        
        let scanOverlayHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scanOverlay]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanOverlay" : scanOverlay])
        let scanOverlayVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scanOverlay]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanOverlay" : scanOverlay])
        
        self.view.addConstraints(scanOverlayHorizontalConstraints)
        self.view.addConstraints(scanOverlayVerticalConstraints)
        
        if scanBorder == nil {
            scanBorder = ScanBorder()
            scanBorder?.translatesAutoresizingMaskIntoConstraints = false
            scanBorder?.backgroundColor = .clear
            if let scanBorder = scanBorder {
                self.view.addSubview(scanBorder)
                
                let scanBorderHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scanBorder]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanBorder" : scanBorder])
                let scanBorderVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scanBorder]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanBorder" : scanBorder])
                
                self.view.addConstraints(scanBorderHorizontalConstraints)
                self.view.addConstraints(scanBorderVerticalConstraints)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        session?.startRunning()
        let rectOfInterest = previewLayer?.metadataOutputRectOfInterest(for: CGRect(x: self.view.center.x - 90, y: self.view.center.y - 90, width: 180, height: 180))
        output?.rectOfInterest = rectOfInterest!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if scanBorder == nil {
            scanBorder = ScanBorder()
            scanBorder?.translatesAutoresizingMaskIntoConstraints = false
            scanBorder?.backgroundColor = .clear
            if let scanBorder = scanBorder {
                self.view.addSubview(scanBorder)
                
                let scanBorderHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scanBorder]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanBorder" : scanBorder])
                let scanBorderVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scanBorder]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanBorder" : scanBorder])
                
                self.view.addConstraints(scanBorderHorizontalConstraints)
                self.view.addConstraints(scanBorderVerticalConstraints)
            }
        }
        if scanAcceptedBorder != nil {
            scanAcceptedBorder?.removeFromSuperview()
            scanAcceptedBorder = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        print("Layout")
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        self.previewLayer?.bounds = self.view.bounds
        self.previewLayer?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Functions
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        for metadata in metadataObjects {
            if metadata is AVMetadataMachineReadableCodeObject {
                session?.stopRunning()
                let transformed = metadata as! AVMetadataMachineReadableCodeObject
                print("Scanned QR\(transformed)")
                feedbackGenerator?.notificationOccurred(.success)
                feedbackGenerator = nil
                scanBorder?.removeFromSuperview()
                scanBorder = nil
                scanAcceptedBorder = ScanAcceptedBorder()
                scanAcceptedBorder?.translatesAutoresizingMaskIntoConstraints = false
                scanAcceptedBorder?.backgroundColor = .clear
                if let scanAcceptedBorder = scanAcceptedBorder {
                    self.view.addSubview(scanAcceptedBorder)
                    
                    let scanAcceptedBorderHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scanAcceptedBorder]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanAcceptedBorder" : scanAcceptedBorder])
                    let scanAcceptedBorderVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scanAcceptedBorder]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["scanAcceptedBorder" : scanAcceptedBorder])
                    self.view.addConstraints(scanAcceptedBorderHorizontalConstraints)
                    self.view.addConstraints(scanAcceptedBorderVerticalConstraints)
                }
            }
        }
    }

    // MARK: - Custom Drawing Functions
    
    func drawRoundedRectangle(rect: CGRect, radius: CGFloat) -> CGMutablePath {
        let retPath = CGMutablePath()
        let innerRect = rect.insetBy(dx: radius, dy: radius)
        let insideRight = innerRect.origin.x + innerRect.size.width
        let outsideRight = rect.origin.x + rect.size.width
        let insideBottom = innerRect.origin.y + innerRect.size.height
        let outsideBottom = rect.origin.y + rect.size.height
        let insideTop = innerRect.origin.y
        let outsideTop = rect.origin.y
        let outsideLeft = rect.origin.x
        
        retPath.move(to: CGPoint(x: innerRect.origin.x, y: outsideTop))
        retPath.addLine(to: CGPoint(x: insideRight, y: outsideTop))
        retPath.addArc(tangent1End: CGPoint(x: outsideRight, y: outsideTop), tangent2End: CGPoint(x: outsideRight, y: insideTop), radius: radius)
        retPath.addLine(to: CGPoint(x: outsideRight, y: insideBottom))
        retPath.addArc(tangent1End: CGPoint(x: outsideRight, y: outsideBottom), tangent2End: CGPoint(x: insideRight, y: outsideBottom), radius: radius)
        retPath.addLine(to: CGPoint(x: innerRect.origin.x, y: outsideBottom))
        retPath.addArc(tangent1End: CGPoint(x: outsideLeft, y: outsideBottom), tangent2End: CGPoint(x: outsideLeft, y: insideBottom), radius: radius)
        retPath.addLine(to: CGPoint(x: outsideLeft, y: insideTop))
        retPath.addArc(tangent1End: CGPoint(x: outsideLeft, y: outsideTop), tangent2End: CGPoint(x: innerRect.origin.x, y: outsideTop), radius: radius)
        
        retPath.closeSubpath()
        return retPath
        
    }
    
    
    
}

