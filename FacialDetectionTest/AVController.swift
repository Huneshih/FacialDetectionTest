//
//  AVController.swift
//  FacialDetectionTest
//
//  Created by Fish Shih on 2018/5/4.
//  Copyright © 2018年 Fish Shih. All rights reserved.
//

import UIKit
import AVFoundation

class AVController: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    static let shared = AVController()
    
    var session: AVCaptureSession?
    
//    let scanType = [AVMetadataObject.ObjectType.face]
    
//    let qrCodeField = "order_detail_qrcode"
    
//    var qrCodeContent: String?
    
    weak var delegate: AVOutputDelegate?
    
    func startToScan() {
        session?.startRunning()
    }
    
    func previewLayerOutput() -> AVCaptureVideoPreviewLayer? {
        
        // Prepare CaptureDevice and InputDevice.
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
//            NSLog("Prepare AVCaptureDevice fail.")
//            return nil
//        }
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            NSLog("Prepare AVCaptureDevice fail.")
            return nil
        }
        
        
        guard let inputDevice = try? AVCaptureDeviceInput(device: captureDevice) else {
            NSLog("Prepare AVCaptureDeviceInput fail.")
            return nil
        }
        
        // Prepare session.
        session = AVCaptureSession()
        guard let session = session else { return nil }
        session.addInput(inputDevice)
        
        // Prepare output object.
//        let metadataOutput = AVCaptureMetadataOutput()
//        session.addOutput(metadataOutput)
//
//        metadataOutput.setMetadataObjectsDelegate(self,
//                                                  queue: DispatchQueue.global(qos: .userInteractive))
//        metadataOutput.metadataObjectTypes = scanType
        
        // Prepare preview.
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    func stopToScanning() {
        
        // Session stop!
        session?.stopRunning()
        session = nil
        
    }
    
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods.
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard metadataObjects.count > 0 else {
            NSLog("No metadata available.")
            return
        }
        
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            NSLog("Not valid metadate object.")
            return
        }
        
        guard let content = metadata.stringValue else {
            NSLog("No string content.")
            return
        }
        
        NSLog("Code Content: \(content)")
        
        stopToScanning()
    }
}


protocol AVOutputDelegate: NSObjectProtocol {
    func AVDeliver(_ faceLayer: CALayer)
}
