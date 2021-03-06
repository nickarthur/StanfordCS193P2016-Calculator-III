//
//  ViewController.swift
//  Calculator
//
//  Created by Michel Deiman on 11/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate
{
// all methods and properties are private, except for
// except for UIViewController methodds (override)
	
	@IBOutlet private weak var decimalPointButton: UIButton! {
		didSet {
			decimalPointButton.setTitle(numberFormatter.decimalSeparator,
			                            forState: .Normal)
		}
	}
	@IBOutlet private weak var display: UILabel!
	@IBOutlet private weak var descriptionDisplay: UILabel!
	
	@IBOutlet private weak var graphButton: UIBarButtonItem!
	private var brain = CalculatorBrain()
	private var userIsInTheMiddleOfTyping = false

	@IBAction private func touchDigit(sender: UIButton) {
		let digit = sender.currentTitle!
		if userIsInTheMiddleOfTyping
		{	display.text = display.text! + digit
		} else
		{	display.text = digit
			userIsInTheMiddleOfTyping = true
		}
	}
	
	@IBAction private func floatingPoint()
	{
		if !userIsInTheMiddleOfTyping {
			display.text = "0."
		} else
		if display.text?.rangeOfString(".") == nil {
			display.text = display.text! + "."
		}
		userIsInTheMiddleOfTyping = true
	}
	
	@IBAction private func backSpace()
	{	if !userIsInTheMiddleOfTyping  {
			brain.undoLast()
			displayValue = brain.result
		} else
		{	if display.text?.characters.count > 1 {
				display.text = String(display.text!.characters.dropLast())
			} else {
				displayValue = nil
			}
		}
	}
	
	@IBAction private func setValueForKey() {
		let key = "M"
		brain.variableValues[key] = displayValue!
		displayValue = brain.result
	}

	@IBAction private func performOperation(sender: UIButton) {
		if userIsInTheMiddleOfTyping {
			brain.setOperand(displayValue!)
		}
		let symbol = sender.currentTitle
		brain.performOperation(symbol!)
		displayValue = brain.result
	}

	private var displayValue: Double? {
		get {
			return Double(display.text!)
		}
		set {
			display.text = numberFormatter.stringFromNumber(newValue ?? 0)
			let postfixDescription = brain.isPartialResult ? "..." : "="
			descriptionDisplay.text = brain.description + postfixDescription
			userIsInTheMiddleOfTyping = false
			graphButton.enabled = !brain.isPartialResult
			
			userdefaults.setObject(brain.program, forKey: Keys.PropertyList_CVC)
		}
	}

	@IBAction private func clearAll()
	{	brain.reset()
		displayValue = brain.result
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		brain.numberFormatter = thisAppStandardNumberFormatter()
		if let brainProgram = userdefaults.objectForKey(Keys.PropertyList_CVC) {
			brain.program = brainProgram
			displayValue = brain.result
		}
		if let splitVC = splitViewController {
			splitVC.delegate = self
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		return !brain.isPartialResult
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{	userdefaults.setObject(brain.program, forKey: Keys.PropertyList_GVC)
	}
	
	private var numberFormatter: NSNumberFormatter = thisAppStandardNumberFormatter()
	private let userdefaults = NSUserDefaults.standardUserDefaults()
	
//	perform delegate responsibilities... Start up in masterViewController (this one)
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool
	{
		return false
	}
}

func thisAppStandardNumberFormatter () -> NSNumberFormatter {
	let numberFormatter = NSNumberFormatter()
	numberFormatter.locale = NSLocale.currentLocale()
	numberFormatter.numberStyle = .DecimalStyle
	numberFormatter.notANumberSymbol = "Error.."
	numberFormatter.alwaysShowsDecimalSeparator = false
	numberFormatter.maximumFractionDigits = 6
	numberFormatter.minimumFractionDigits = 0
	numberFormatter.minimumIntegerDigits = 1
	return numberFormatter
}

struct Keys {
	static let PropertyList_GVC = "GraphViewControllerPropertyList"
	static let PropertyList_CVC = "CalculatorViewControllerPropertyList"
}

