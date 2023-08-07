//
//  CropImageVC.swift
//  LongTester
//
//  Created by Long on 4/3/23.
//

import Foundation
import UIKit

class CropImageVC : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didPress(){
        DispatchQueue.main.async {
            let image = UIImage(named: "ThaiCMND") ?? UIImage()
            let a = self.cropImage(image: image, type: "TR")
            let b = self.cropImage(image: image, type: "TL")
            let c = self.cropImage(image: image, type: "BR")
            let d = self.cropImage(image: image, type: "BL")
            self.readQRCode(from: a)
            self.readQRCode(from: b)
            self.readQRCode(from: c)
            self.readQRCode(from: d)
        }
    }
    func cropImage(image: UIImage, type: String) -> UIImage{
        let sourceImage = image
        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        
        var xOffset : CGFloat = 0
        var yOffset : CGFloat = 0
        let sourceSize = sourceImage.size
        switch type {
        case "TL" :
            xOffset = sourceSize.width * sourceImage.scale / 2.0
            yOffset = 0
        case "TR" :
            xOffset = 0
            yOffset = 0
        case "BR" :
            xOffset = 0
            yOffset = sourceSize.height * sourceImage.scale / 2.0
        case "BL" :
            xOffset = sourceSize.width * sourceImage.scale / 2.0
            yOffset = sourceSize.height * sourceImage.scale / 2.0
        default:
            break
        }
        
        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sourceSize.width * sourceImage.scale / 2.0,
            height: sourceSize.height * sourceImage.scale / 2.0
        ).integral

        // Center crop the image
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        return UIImage(cgImage: croppedCGImage)
    }
    func readQRCode(from image: UIImage) {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let ciImage = CIImage(image: image)
        let features = detector?.features(in: ciImage!)
        for feature in features as! [CIQRCodeFeature] {
            let qrCodeContent = feature.messageString
            print("QR Code Content: \(qrCodeContent)")
        }
    }
    
}
