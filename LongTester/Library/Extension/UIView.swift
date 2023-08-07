//
//  UIView.swift
//  LongTester
//
//  Created by Long on 4/12/23.
//

import Foundation
import UIKit

extension UIView {
    func addDashedBorder(color: UIColor,radius : CGFloat) {
        let color = color.cgColor

        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6, 3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: radius).cgPath
        self.layer.addSublayer(shapeLayer)
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nibView.frame = bounds
        addSubview(nibView)
    }
    
    func addBottomShadow(height : CGFloat = 10.0, alpha : CGFloat = 0.5, radius: CGFloat = 10 , color : UIColor = Color.defaultShadow)  {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.withAlphaComponent(alpha).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowRadius = radius
    }
    
    func addLeftShadow() {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(red: 0.118, green: 0.255, blue: 0.608, alpha: 0.5).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 10, height: 0.0)
        self.layer.shadowRadius = 10
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
    
    // there can be other views between `subview` and `self`
    func getConvertedFrame(fromSubview subview: UIView) -> CGRect? {
        // check if `subview` is a subview of self
        guard subview.isDescendant(of: self) else {
            return nil
        }
        
        var frame = subview.frame
        if subview.superview == nil {
            return frame
        }
        
        var superview = subview.superview
        while superview != self {
            frame = superview!.convert(frame, to: superview!.superview)
            if superview!.superview == nil {
                break
            } else {
                superview = superview!.superview
            }
        }
        
        return superview!.convert(frame, to: self)
    }
    
    func addBorderGradient(startColor:UIColor, endColor: UIColor, lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint) {
    //This will make view border circular
    self.layer.cornerRadius = self.bounds.size.height / 2.0
    //This will hide the part outside of border, so that it would look like circle
    self.clipsToBounds = true
    //Create object of CAGradientLayer
    let gradient = CAGradientLayer()
    //Assign origin and size of gradient so that it will fit exactly over circular view
    gradient.frame = self.bounds
    //Pass the gredient colors list to gradient object
    gradient.colors = [startColor.cgColor, endColor.cgColor]
    //Point from where gradient should start
    gradient.startPoint = startPoint
    //Point where gradient should end
    gradient.endPoint = endPoint
    //Now we have to create a circular shape so that it can be added to view’s layer
    let shape = CAShapeLayer()
    //Width of circular line
    shape.lineWidth = lineWidth
    //Create circle with center same as of center of view, with radius equal to half height of view, startAngle is the angle from where circle should start, endAngle is the angle where circular path should end
    shape.path = UIBezierPath(
    arcCenter: CGPoint(x: self.bounds.height/2,
    y: self.bounds.height/2),
    radius: self.bounds.height/2,
    startAngle: CGFloat(0),
    endAngle:CGFloat(CGFloat.pi * 2),
    clockwise: true).cgPath
    //the color to fill the path’s stroked outline
    shape.strokeColor = UIColor.black.cgColor
    //The color to fill the path
    shape.fillColor = UIColor.clear.cgColor
    //Apply shape to gradient layer, this will create gradient with circular border
    gradient.mask = shape
    //Finally add the gradient layer to out View
    self.layer.addSublayer(gradient)
    }
    
}
