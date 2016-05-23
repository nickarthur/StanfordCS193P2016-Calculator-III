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
	@IBInspectable var origin: CGPoint! {
		didSet { if oldValue != nil { setNeedsDisplay() } }
	}
	@IBInspectable var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() }}
	@IBInspectable var axesColor: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() }}
	@IBInspectable var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() }}
	
	// to lower the load, and increase performance when using 
	// gesture recognizing (ie panning, zooming ... ) -> boolean var 'gesturing'
	@IBInspectable var gesturesContentScaleFactor: CGFloat = 0.5
	weak var dataSource: GraphViewDataSource?
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
		default: break
		}
	}
	
	func pan(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .Began:
			gesturing = true
		case .Changed, .Ended:
			let translation = recognizer.translationInView(self)
			origin.offsetBy(dx: translation.x, dy: translation.y)
			recognizer.setTranslation(CGPointZero, inView: self)
			if recognizer.state == .Ended {
				gesturing = false
			}
		default: break
		}
	}
	
	func setOrigin(recognizer: UITapGestureRecognizer) {
		origin = recognizer.locationInView(self)
	}
	
	private var gesturing: Bool = false
	private var axesDrawer: AxesDrawer!

	override internal func drawRect(rect: CGRect) {
		super.drawRect(rect)
		if origin == nil {
			origin = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
		}
		else if let boundsBeforeTransition = boundsBeforeTransitionToSize {
			origin.x = origin.x * bounds.width / boundsBeforeTransition.width
			origin.y = origin.y * bounds.height / boundsBeforeTransition.height
			boundsBeforeTransitionToSize = nil
		}

		if axesDrawer == nil {
			axesDrawer = AxesDrawer(color: axesColor, contentScaleFactor: contentScaleFactor)
		}
		axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
		if let fx = dataSource?.graphView {
			drawMathFunction(fx)
		}
	}
	
	private func drawMathFunction(fx: (CGFloat) -> CGFloat)
	{	let scaleFactor = !gesturing ? self.contentScaleFactor : gesturesContentScaleFactor
		
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

	
	deinit {
		print("cleaned up all your mess?")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)

	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}
