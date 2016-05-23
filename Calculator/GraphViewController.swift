//
//  GraphViewController.swift
//  Calculator III
//
//  Created by Michel Deiman on 20/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

protocol hasCalculatorBrain: class {
	var brainProgram: CalculatorBrain.PropertyList? { get set }
}

protocol GraphViewDataSource: class {
	func graphView(valueYforX x: CGFloat) -> CGFloat
}

class GraphViewController: UIViewController, hasCalculatorBrain, GraphViewDataSource
{
	var brainProgram: CalculatorBrain.PropertyList? {
		didSet {
			guard brain != nil && brainProgram != nil else { return }
			brain.program = brainProgram!
		}
	}
	
	func graphView(valueYforX x: CGFloat) -> CGFloat
	{	brain.variableValues["M"] = Double(x)
		return CGFloat(brain.result)
	}
	
	private var brain: CalculatorBrain!
	
	@IBOutlet private weak var graphView: GraphView! {
		didSet {
			graphView.dataSource = self
			graphView.scale = 100
			setupGestureRecognizers()
		}
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
	{	graphView.boundsBeforeTransitionToSize = graphView.bounds
	}
	
	override func viewDidLoad()
	{	super.viewDidLoad()
		
		brain = CalculatorBrain()
		brain.numberFormatter = thisAppStandardNumberFormatter()
		if brainProgram != nil {
			brain.program = brainProgram!
		}
		
		navigationItem.title = brainProgram != nil ? brain.description : "Graph of Calculator Function"
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
		navigationItem.leftItemsSupplementBackButton = true
	}
	
	private func setupGestureRecognizers() {
		graphView.addGestureRecognizer(UIPinchGestureRecognizer(
			target: graphView,
			action: #selector(graphView.zoom(_:))
			))
		graphView.addGestureRecognizer(UIPanGestureRecognizer(
			target: graphView,
			action: #selector(graphView.pan(_:))
			))
		graphView.addGestureRecognizer(UITapGestureRecognizer(
			target: graphView,
			action: #selector(graphView.setOrigin(_:))
			))
	}

}


