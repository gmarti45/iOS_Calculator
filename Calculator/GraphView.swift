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
    
    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay()}}
    
    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay()}}
    
    @IBInspectable
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay()}}
    
    private var axesDrawer = AxesDrawer()
    
    
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
    
    private func pathForFunction() -> UIBezierPath
    {
        let path: UIBezierPath
        path = UIBezierPath()
        path.lineWidth = lineWidth
        return path
    }

    override func draw(_ rect: CGRect) {
        color.set() //sets the fill and stroke color
        pathForFunction().stroke()
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        axesDrawer.drawAxes(in: rect, origin: origin, pointsPerUnit: scale)
    }
}
