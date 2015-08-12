//
//  GraphView.swift
//  CalculatoriTU
//
//  Created by Guillermo on 5/19/15.
//  Copyright (c) 2015 guillermo. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {//could be called GraphViewDelegate
    func y(xValue: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {

//    private var axes = AxesDrawer(contentScaleFactor: contentScaleFactor)

    weak var dataSource: GraphViewDataSource?
    
    var lineWidth: CGFloat = 1.0 {didSet { setNeedsDisplay() }}
    var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() }}
    
    var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    @IBInspectable
    var scale: CGFloat = 50.0 {didSet {setNeedsDisplay()}}
    var origin: CGPoint = CGPoint() {
        didSet {
            resetOrigin = false
            setNeedsDisplay()
        }
    }
    
    private var resetOrigin: Bool = true {
        didSet {
            if resetOrigin {
                setNeedsDisplay()
            }
        }
    }

    func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    var snapshot: UIView?
    
    func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Began:
                snapshot = self.snapshotViewAfterScreenUpdates(false)
                snapshot!.alpha = 0.8
                self.addSubview(snapshot!)
            case .Changed:
                let translation = gesture.translationInView(self)
                snapshot!.center.x += translation.x
                snapshot!.center.y += translation.y
                gesture.setTranslation(CGPointZero, inView: self)
            case .Ended:
                origin.x += snapshot!.frame.origin.x
                origin.y += snapshot!.frame.origin.y
                snapshot!.removeFromSuperview()
                snapshot = nil
            default: break
        }
    }
    
    func center(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }
    
    override func drawRect(rect: CGRect) {
        if resetOrigin {
            origin = center
        }
        let axes = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axes.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var firstValue = true
        var point = CGPoint()
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            point.x = CGFloat(i) / contentScaleFactor
            if let y = dataSource?.y((point.x - origin.x) / scale) {
                if !y.isNormal && !y.isZero {
                    firstValue = true
                    continue
                }
                point.y = origin.y - y * scale
                if firstValue {
                    path.moveToPoint(point)
                    firstValue = false
                } else {
                    path.addLineToPoint(point)
                }
            } else {
                firstValue = true
            }
        }
        path.stroke()

        //Strategy: Use delegate to iterate over every pixel across the width of the view and draw a line to next point
        
    }
 
    
}
