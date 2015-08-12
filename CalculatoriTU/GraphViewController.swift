//
//  GraphViewController.swift
//  CalculatoriTU
//
//  Created by Guillermo on 5/19/15.
//  Copyright (c) 2015 guillermo. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource
{
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: "zoom:")
            graphView.addGestureRecognizer(pinchRecognizer)
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: "move:")
            graphView.addGestureRecognizer(panRecognizer)
            let tap = UITapGestureRecognizer(target: graphView, action: "center:")
            tap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tap)
        }
        
    }
    
    //What is the Model - I think y-value?
    var yValue: Double? {
        didSet {
            println("\(yValue)")
        }
    }
    
    private var brain = CalculatorBrain()
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return brain.program
        }
        set {
            brain.program = newValue
        }
    }
    
    func y(x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        if let y = brain.evaluate() {
            return CGFloat(y)
        }
        return nil
    }
}
