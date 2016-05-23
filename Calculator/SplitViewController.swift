//
//  SplitViewController.swift
//  Calculator III
//
//  Created by Michel Deiman on 21/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate
{	// This delegate methods is used to make "CalculatorViewController"
	// the initial viewcontroller. 
	
	private var collapseDetailViewController = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
	}
		
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
	{
		return collapseDetailViewController
  	}
	

}
