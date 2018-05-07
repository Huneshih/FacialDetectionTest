//
//  ViewController.swift
//  FacialDetectionTest
//
//  Created by Fish Shih on 2018/4/26.
//  Copyright © 2018年 Fish Shih. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var changeBtnOl: UIButton!
    
    var rightEye = UIView()
    var leftEye = UIView()
    var mouth = UIView()
    var mouthBox = UIView()
    var faceBox = UIView()
    let glasses = UIImageView(image: #imageLiteral(resourceName: "glassess"))
    let smok = UIImageView(image: #imageLiteral(resourceName: "smok"))
    let hat = UIImageView(image: #imageLiteral(resourceName: "hat"))
    let goldChain = UIImageView(image: #imageLiteral(resourceName: "gc"))
    
    let thugLife = UIImageView(image: #imageLiteral(resourceName: "tl"))
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeBtnOl.layer.cornerRadius = changeBtnOl.frame.height / 2
        
//        thugLife.contentMode = .scaleAspectFit
//        thugLife.frame = CGRect
        
        detect()
    }
    
    
    func setFeaturePoint(at: CGPoint) -> UIView {
        let color = #colorLiteral(red: 0.001306270133, green: 1, blue: 0.8659981489, alpha: 1)
        let frame = CGRect(origin: CGPoint(x: at.x, y: at.y), size: CGSize(width: 20, height: 20))
        let view = UIView(frame: frame)
        view.backgroundColor = color
        view.layer.cornerRadius = view.bounds.height / 2
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }
    
    func getHypot(pointA a: CGPoint, pointB b: CGPoint) -> Double {
        let w = abs(Double(a.x - b.x))
        let h = abs(Double(a.y - b.y))
        return hypot(w, h)
    }
    
    func getAngle(pointA a: CGPoint, pointB b: CGPoint) -> Double {
        let w = Double(b.x - a.x)
        let h = getHypot(pointA: a, pointB: b)
        return acos(w / h) / Double.pi * 180
    }
    
    @objc func detect() {
        
        faceBox.removeFromSuperview()
        leftEye.removeFromSuperview()
        rightEye.removeFromSuperview()
        mouth.removeFromSuperview()
        mouthBox.removeFromSuperview()
        
        // 將圖片轉為 CIImage
        guard let faceImage = CIImage(image: imageView.image!) else { return }
        
        
        // 精準度設定準備
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        // 偵測器準備
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace,
                                      context: nil,
                                      options: accuracy)
        
//        let faceRecognition = 
        
        // 取得偵測臉部
        let faces = faceDetector?.features(in: faceImage)
        
        // 將 UIKit 座標，切換為 CoreImage 座標 ( 兩者座標紀錄方式不同 )
        let ciImageSize = faceImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        // 將找到的所有特徵，逐一處理
        for face in faces as! [CIFaceFeature] {
            
//            print("Found bounds are \(face.bounds)")
            
            // 套用座標轉換實作
            var faceViewBounds = face.bounds.applying(transform)
            
            // 計算矩形在 imageView 中的實際位置與尺寸
            let viewSize = imageView.bounds.size
            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2

            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            // 設置捕捉筐
            faceBox = UIView(frame: faceViewBounds)
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = #colorLiteral(red: 0.8588281197, green: 0.5327028827, blue: 0.601378951, alpha: 1)
            faceBox.backgroundColor = UIColor.clear
            
            func getFeatureFrame(featurePosition: CGPoint) -> CGRect {
                let originPosition = CGPoint(x: featurePosition.x,
                                             y: (imageView.image?.size.height)! - featurePosition.y)
                let imageSize = imageView.image?.size
                let x = originPosition.x * UIScreen.main.bounds.width / (imageSize?.width)!
                let y = originPosition.y * UIScreen.main.bounds.height / (imageSize?.height)!
                return CGRect(x: x, y: y, width: 20, height: 20)
            }
            
            func getFeaturePoint(featurePosition: CGPoint) -> CGPoint {
                let originPosition = CGPoint(x: featurePosition.x,
                                             y: (imageView.image?.size.height)! - featurePosition.y)
                let imageSize = imageView.image?.size
                let x = originPosition.x * UIScreen.main.bounds.width / (imageSize?.width)!
                let y = originPosition.y * UIScreen.main.bounds.height / (imageSize?.height)!
                return CGPoint(x: x, y: y)
            }
            
//            var left: CGRect?
//            var right: CGRect?
            var left: CGPoint?
            var right: CGPoint?
            var mouth: CGPoint?
//            var mouthRect: CGRect?
            
            if face.hasLeftEyePosition {
//                leftEye = setFeaturePoint(at: face.leftEyePosition)
//                print("face.leftEyePosition = \(face.leftEyePosition)")
//                leftEye.frame = getFeatureFrame(featurePosition: face.leftEyePosition)
//                print("Left eye bounds are \(leftEye.frame)")
                left = getFeaturePoint(featurePosition: face.leftEyePosition)
            }
            
            if face.hasRightEyePosition {
//                rightEye = setFeaturePoint(at: face.rightEyePosition)
//                print("face.rightEyePosition = \(face.rightEyePosition)")
//                rightEye.frame = getFeatureFrame(featurePosition: face.rightEyePosition)
//                print("Right eye bounds are \(rightEye.frame)")
                right = getFeaturePoint(featurePosition: face.rightEyePosition)
            }
            
            if face.hasMouthPosition {
                mouthBox = setFeaturePoint(at: face.mouthPosition)
                print("face.mouthPosition = \(face.mouthPosition)")
                mouthBox.frame = getFeatureFrame(featurePosition: face.mouthPosition)
                print("Mouth bounds are \(mouthBox.frame)")
                mouth = getFeaturePoint(featurePosition: face.mouthPosition)
            }
            
//            imageView.addSubview(faceBox)
//            imageView.addSubview(leftEye)
//            imageView.addSubview(rightEye)
//            imageView.addSubview(mouthBox)
            
            if let left = left, let right = right, let mouth = mouth {
                
                let h = CGFloat(getHypot(pointA: left, pointB: right)) * 1.5
                
                var y: CGFloat = 0.0
                if left.y < right.y {
                    y = left.y + (right.y - left.y) / 2
                } else {
                    y = right.y + (left.y - right.y) / 2
                }
                print("Y = \(y), X = \((right.x - left.x) / 2)")
//                let x = left.x + (right.x - left.x) / 2 - (h / 2)
                y = y - (h / 5) / 2
                
                let angle = getAngle(pointA: left, pointB: right)
                print("Angle = \(angle)")
                glasses.frame = CGRect(x: faceBox.frame.minX, y: y, width: faceViewBounds.width, height: faceViewBounds.width / 5)
                imageView.addSubview(glasses)
                glasses.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
                glasses.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                smok.frame = CGRect(x: faceBox.frame.minX, y: mouth.y,
                                    width: mouth.x - faceBox.frame.minX, height:  mouth.x - faceBox.frame.minX)
                
                
                let hatLeftSpace  = faceBox.frame.width * 15 / 65
                let hatRightSpace = faceBox.frame.width * 16 / 65
                let hatWidth = hatLeftSpace + faceBox.frame.width + hatRightSpace
                let hatSize = CGSize(width: hatWidth, height: hatWidth * 121 / 179)
                hat.frame = CGRect(x: faceBox.frame.minX - hatLeftSpace, y: faceBox.frame.minY - hatSize.height * 0.8,
                                   width: hatSize.width, height: hatSize.height)
                imageView.addSubview(hat)
                
                let chainWidth = faceBox.frame.width
                goldChain.frame = CGRect(x: faceBox.frame.minX, y: faceBox.frame.maxY, width: chainWidth, height: chainWidth)
                imageView.addSubview(goldChain)
                imageView.addSubview(smok)
                
            }
        }
    }
    
    
    @IBAction func changeBtnAction(_ sender: Any) {
        glasses.removeFromSuperview()
        index += 1
        let img = [#imageLiteral(resourceName: "man"), #imageLiteral(resourceName: "man1"), #imageLiteral(resourceName: "man2"), #imageLiteral(resourceName: "man3")]
        if index > 3 {
            index = 0
        }
        imageView.image = img[index]
        detect()
    }
}

