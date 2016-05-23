//
//  GraphView.swift
//  Calculator III
//
//  Created by Michel Deiman on 20/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//
import UIKit

@IBDesignable
class GraphView: UIView
{
	@IBInspectable var scale: CGFloat = 100 { didSet { setNeedsDisplay() }}
	@IBInspectable var origin: CGPoint! { didSet { setNeedsDisplay() }}
	@IBInspectable var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() }}
	@IBInspectable var axesColor: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() }}
	@IBInspectable var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() }}
	
	weak var dataSource: GraphViewDataSource?
	
	// set when bounds change (ie rotation), 
	// to maintain relative origin
	var boundsBeforeTransitionToSize: CGRect?
	
	func zoom(recognizer: UIPinchGestureRecognizer) {
		switch recognizer.state {
		case .Began:
			gesturing = true
		case .Changed:
			scale *= recognizer.scale
			recognizer.scale = 1.0
		case .Ended:
			scale *= recognizer.scale
			gesturing = false
			storeData()
		default: break
		}
	}
	
	func pan(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .Began:
			gesturing = true
		case .Changed:
			let translation = recognizer.translationInView(self)
			origin.offsetBy(dx: translation.x, dy: translation.y)
			recognizer.setTranslation(CGPointZero, inView: self)
		case .Ended:
			let translation = recognizer.translationInView(self)
			origin.offsetBy(dx: translation.x, dy: translation.y)
			recognizer.setTranslation(CGPointZero, inView: self)
			gesturing = false
			storeData()
		default: break
		}
	}
	
	func setOrigin(recognizer: UITapGestureRecognizer) {
		origin = recognizer.locationInView(self)
		storeData()
	}
	
	override internal func drawRect(rect: CGRect) {
		super.drawRect(rect)
		if origin == nil {
			origin = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
			storeData()
		} else if boundsBeforeTransitionToSize != nil { // interface rotation
			origin.x = origin.x * bounds.width / boundsBeforeTransitionToSize!.width
			origin.y = origin.y * bounds.height / boundsBeforeTransitionToSize!.height
			boundsBeforeTransitionToSize = nil
		}
		if axesDrawer == nil {
			axesDrawer = AxesDrawer(color: axesColor, contentScaleFactor: contentScaleFactor)
		}
		axesDrawer!.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
		if let fx = dataSource?.graphView {
			drawMathFunction(fx)
		}
	}
	
	func storeData() {
		let dataToSave = [scale, origin.x, origin.y]
		userdefaults.setObject(dataToSave, forKey: Keys.ScaleAndOrigin)
	}
	
	func restoreData() {
		if let dataToRestore = userdefaults.arrayForKey(Keys.ScaleAndOrigin) as? [CGFloat]
		{	if dataToRestore.count == 3 {
			scale = dataToRestore[0]
			origin = CGPoint(x: dataToRestore[1], y: dataToRestore[2])
			}
		}
	}

	///////////////////////////  private methods and properties
	// for performance, use low contentScaleFactor when 'gesturing'
	private var gesturingContentScaleFactor: CGFloat = 0.5
	private var gesturing: Bool = false
	private var axesDrawer: AxesDrawer?
	
	private func drawMathFunction(fx: (CGFloat) -> CGFloat)
	{	let scaleFactor = !gesturing ? self.contentScaleFactor : gesturingContentScaleFactor
		
		let maxY = bounds.maxY + bounds.height * 0.2
		let minY = bounds.minY - bounds.height * 0.2
		let minX = Int(bounds.minX * scaleFactor)
		let maxX = Int(bounds.maxX * scaleFactor)
		
		func isValidTargetPointFor(x: CGFloat) -> CGPoint? {
			let cartesianY = fx((x - origin.x) / scale)
			guard cartesianY.isNormal || cartesianY.isZero else { return nil }
			let y = origin.y - cartesianY * scale
			let yIsInBounds = y >= minY && y <= maxY
			return yIsInBounds ? CGPoint(x: x, y: y) : nil
		}
		
		color.set()
		var path: UIBezierPath?
		for pixelX in minX...maxX
		{
			let x = CGFloat(pixelX) / scaleFactor
			if let targetPoint = isValidTargetPointFor(x) {
				if path != nil {
					path!.addLineToPoint(targetPoint)
				} else {
					path = UIBezierPath()
					path!.moveToPoint(targetPoint)
				}
			} else  {
				path?.lineWidth = lineWidth
				path?.stroke()
				path = nil
			}
		}
		path?.lineWidth = lineWidth
		path?.stroke()
	}

	private let userdefaults = NSUserDefaults.standardUserDefaults()
	private struct Keys {
		static let ScaleAndOrigin = "GraphViewScaleAndOrigin"
	}
	
}
