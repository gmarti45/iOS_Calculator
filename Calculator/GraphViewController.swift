//
//  GraphViewController.swift
//  Calculator
//
//  Created by Gloria Martinez on 4/13/17.
//  Copyright © 2017 Gloria Martinez. All rights reserved.
//

import Foundation


import UIKit

class GraphViewController: UIViewController {
    
    var function: ((Double) -> Double)?
    
    @IBOutlet weak var graph: GraphView!{
        didSet {
            graph.function = function
            let zoomRecognizer = UIPinchGestureRecognizer(target: graph, action: #selector(GraphView.zoom(byReactingTo:)))
            graph.addGestureRecognizer(zoomRecognizer)
            let panRecognizer = UIPanGestureRecognizer (target: graph, action: #selector(GraphView.panning(byReactingTo:)))
            graph.addGestureRecognizer(panRecognizer)
            let doubleTapRecognizer = UITapGestureRecognizer(target: graph, action: #selector(GraphView.moveOrigin(byReactingTo:)))
                doubleTapRecognizer.numberOfTapsRequired = 2
                graph.addGestureRecognizer(doubleTapRecognizer)
        }
    }
}
