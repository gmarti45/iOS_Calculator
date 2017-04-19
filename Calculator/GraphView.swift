//
//  GraphView.swift
//  Calculator
//
//  Created by Gloria Martinez on 4/13/17.
//  Copyright © 2017 Gloria Martinez. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var function: ((Double) -> Double)? {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay()}}
    
    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay()}}
    
    @IBInspectable
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay()}}
    
    
    private var axesDrawer = AxesDrawer()

    
    
    
    func modifyCoordinatePts (x: CGFloat, y: CGFloat)-> CGPoint
    {
        return CGPoint(x: origin.x + (x*scale), y: origin.y - (y*scale))
    }
    
    func modifyCoordinates (x: Double, y: Double)-> CGPoint
    {
        return CGPoint(x: origin.x + (CGFloat(x)*scale), y: origin.y - (CGFloat(y)*scale))
    }
    
    
    private func pathForFunction() -> UIBezierPath
    {
        let path = UIBezierPath()
        path.lineWidth = 2
        var firstPoint = true
        
        if function != nil {
            for x in 0...Int(bounds.size.width * scale) {
                let pointX = CGFloat(x) / scale
                
                let xVal = Double((pointX - origin.x) / scale)
                let yVal = function!(xVal)
                
                if !yVal.isZero && !yVal.isNormal {
                    firstPoint = true
                    continue
                }
                
                let pointY = origin.y - CGFloat(yVal) * scale
                
                if firstPoint {
                    path.move(to: CGPoint(x: pointX, y: pointY))
                    firstPoint = false
                } else {
                    path.addLine(to: CGPoint(x: pointX, y: pointY))
                    
                }
            }
        }
        return path
    }
    
    
    
    func zoom(byReactingTo pinchRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    
    
    func panning(byReactingTo panRecognizer: UIPanGestureRecognizer)
    {
        switch panRecognizer.state {
        case .changed, .ended:
            let translation = panRecognizer.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
        panRecognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    
    
    func moveOrigin(byReactingTo doubleTapRecognizer: UITapGestureRecognizer)
    {
        switch doubleTapRecognizer.state {
        case . changed, .ended:
            origin = doubleTapRecognizer.location(in: self)
        default:
            break
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        color.set() //sets the fill and stroke color
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        axesDrawer.drawAxes(in: rect, origin: origin, pointsPerUnit: scale)
        pathForFunction().stroke()
        
//        let testPath: UIBezierPath
//        testPath = UIBezierPath()
//        testPath.lineWidth = lineWidth
//        
//        testPath.move(to: CGPoint(x: origin.x, y: origin.y))
//        testPath.addLine(to: modifyCoordinatePts(x: 10, y: 10))
//        testPath.close()
//        testPath.stroke()
//        testPath.fill()
        
        
    }
}
