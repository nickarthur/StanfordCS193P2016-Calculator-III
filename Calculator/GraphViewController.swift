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
	weak var brainProgram: CalculatorBrain.PropertyList?
	{	get {	return userdefaults.objectForKey(Keys.PropertyList) ?? []	}
		set {
			userdefaults.setObject(newValue, forKey: Keys.PropertyList)
			brain.program = newValue ?? []
		}
	}

	func graphView(valueYforX x: CGFloat) -> CGFloat
	{	brain.variableValues["M"] = Double(x)
		return CGFloat(brain.result)
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
	{	graphView.boundsBeforeTransitionToSize = graphView.bounds
	}
	
	override func viewDidLoad()
	{	super.viewDidLoad()
		brain.numberFormatter = thisAppStandardNumberFormatter()
		if brainProgram != nil {
			brain.program = brainProgram!
		}
		
		navigationItem.title = brainProgram != nil ? brain.description : "Graph of Calculator Function"
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
		navigationItem.leftItemsSupplementBackButton = true
	}
	
	/////////////////////// - private methods and properties
	private var brain = CalculatorBrain()
	@IBOutlet private weak var graphView: GraphView! {
		didSet {
			graphView.dataSource = self
			setupGestureRecognizers()
			graphView.restoreData()
		}
	}
	
	private let userdefaults = NSUserDefaults.standardUserDefaults()
	private struct Keys {
		static let PropertyList = "GraphViewControllerPropertyList"
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


