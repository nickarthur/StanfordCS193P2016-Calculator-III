//
//  GraphViewController.swift
//  Calculator III
//
//  Created by Michel Deiman on 20/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit


protocol GraphViewDataSource: class {
	func graphView(valueYforX x: CGFloat) -> CGFloat
}

class GraphViewController: UIViewController, GraphViewDataSource
{
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
		brain.program = userdefaults.objectForKey(Keys.PropertyList_GVC) ?? []
		
		navigationItem.title = brain.description
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
		navigationItem.leftItemsSupplementBackButton = true
	}
	
	/////////////////////// - private methods and properties
	private let userdefaults = NSUserDefaults.standardUserDefaults()
	private var brain = CalculatorBrain()

	@IBOutlet private weak var graphView: GraphView! {
		didSet {
			graphView.dataSource = self
			setupGestureRecognizers()
			graphView.restoreData()
		}
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


