//
//  TouchCoreView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 3/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class TouchCoreView: UIView {
	
	//Models
	var dataSet:DataSet?

	//Drawing Params
	var strokeWidth: CGFloat = 2.0//5.0
	var fingerLineColor = UIColor(named: "fingerLineColour")!
	var pencilLineColor: UIColor = .blue
	var showStartEnd = false
	var showLineVelocity = false
	var linesShown = 0//0,Both;1,Fingers;2,Pencil
	var fingerLineCounts = [0,0,0,0,0,0]
	
	//Velocty Stuff
	var slowCount = 0.0
	var mediumCount = 0.0
	var fastCount = 0.0
	var slowDistance = 0.0
	var mediumDistance = 0.0
	var fastDistance = 0.0
	
	//UIBezierPathStuff
	var oldControlPoint:CGPoint?
	
	//Timer Stuff
	var timer = Timer()
	var timeElapsed:TimeInterval = 0
	var startTime:TimeInterval = 0
	var endTime:TimeInterval = 0
	var frameRate:CGFloat = 0.05
	var currentStimulusStartTime:TimeInterval = 0
	
	//Arrays and Models
	var savedTouches = [[Touch?]?]()
	var fromPoint:CGPoint?
	var toPoint:CGPoint?
	var pointsToDraw = [(fromPoint:CGPoint,toPoint:CGPoint,isPencil:Bool,touchPhase:Int,number:Int)]()
	

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		backgroundColor = .clear
		contentMode = UIView.ContentMode.redraw
	}
	override func draw(_ rect: CGRect) {
//		guard let context = UIGraphicsGetCurrentContext() else {
//			return
//		}
		//Draw Lines
		for i in 0 ..< pointsToDraw.count{
			
			let path = quadCurvedPath(atIndex: i)
			//Deal with Finger Stuff
			
			if pointsToDraw[i].isPencil == false{//If it's a finger
				fingerLineColor.setStroke()
				if showLineVelocity == true{
					let distance = Helpers.shared.distance(a: pointsToDraw[i].fromPoint, b: pointsToDraw[i].toPoint)
					let colorForDistance = getColorToDraw(withDistance: Double(distance))
					colorForDistance.setStroke()
				}
			}
			else{//if it's a pencil
				pencilLineColor.setStroke()
			}
			path.lineWidth = strokeWidth
			path.stroke()
			
			
		}/*
		pointsToDraw.forEach { (pointSet) in
			context.move(to: pointSet.fromPoint)
			context.addLine(to: pointSet.toPoint)
			context.setLineWidth(strokeWidth)
		
			//Deal with Finger Stuff
			let distance = Helpers.shared.distance(a: pointSet.0, b: pointSet.1)
			if pointSet.isPencil == false{//If it's a finger
				context.setStrokeColor(fingerLineColor.cgColor)
				if showLineVelocity == true{
					context.setStrokeColor(getColorToDraw(withDistance: Double(distance)).cgColor)
				}
			}
			else{//if it's a pencil
				context.setStrokeColor(pencilLineColor.cgColor)
			}
			
			//Set Stroke Color (for Pro)
			context.setBlendMode(CGBlendMode.normal)
			context.setLineCap(.round)
			context.strokePath()
		}
*/
		if showStartEnd == true{
			pointsToDraw.forEach { (pointSet2) in
				//Deal with Start / End stuff
				if pointSet2.touchPhase == UITouch.Phase.began.rawValue{
					let green = UIColor.init(red: 167/255, green: 197/255, blue: 116/255, alpha: 1.0)
					addNumberToLine(touchNumber: pointSet2.number, atLocation: pointSet2.fromPoint, circleColor:green, textColor: .white)
				}
				else if pointSet2.touchPhase == UITouch.Phase.ended.rawValue{
					let red = UIColor.init(red: 190/255, green: 75/255, blue: 85/255, alpha: 1.0)
					addNumberToLine(touchNumber: pointSet2.number, atLocation: pointSet2.toPoint,circleColor:red, textColor: .white)

				}
			}
		}
		
	}
	
	func addNumberToLine(touchNumber:Int, atLocation:CGPoint, circleColor:UIColor, textColor:UIColor){
		
		let ovalPath = UIBezierPath(ovalIn: CGRect(x: atLocation.x-10, y: atLocation.y-10, width: 20, height: 20))
		circleColor.setFill()
		ovalPath.fill()
		
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center
		let adjustedFontSize = 20 / 2
		let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat(adjustedFontSize))!, NSAttributedString.Key.paragraphStyle: paragraphStyle,NSAttributedString.Key.foregroundColor:textColor]

			let string = String(describing:touchNumber)
		string.draw(with: CGRect(x: atLocation.x-10, y: atLocation.y-6.5, width: 20, height: 20), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
		}
	
	//MARK: VELOCITY COLOUR
	func getColorToDraw(withDistance:Double) -> UIColor{
		
		//Record Velocity
		//Flat Yellow 247,203,87
		//Flat Red 229,77,66
		if withDistance < 10{
			slowDistance += withDistance
			slowCount += 1
		}
		else if withDistance > 10 && withDistance < 30{
			mediumDistance += withDistance
			mediumCount += 1
		}
		else if withDistance > 30{
			fastDistance += withDistance
			fastCount += 1
		}
		
		//let totalSegment = slowCount + mediumCount + fastCount
		//let totalDistance = slowDistance + mediumDistance + fastDistance
		
		let totalCombined = (slowCount * slowDistance) +  (mediumCount * mediumDistance) + (fastCount * fastDistance)
		var slowPercentage = (slowCount * slowDistance) / totalCombined
		var mediumPercentage =  (mediumCount * mediumDistance) / totalCombined
		var fastPercentage = (fastCount * fastDistance) / totalCombined
		//let avgDistance = totalDistance / totalSegment
		if slowPercentage.isNaN{
			slowPercentage = 0.0
		}
		if mediumPercentage.isNaN{
			mediumPercentage = 0.0
		}
		if fastPercentage.isNaN{
			fastPercentage = 0.0
		}
		/*
		let slowString = String(format: "Slow: %.2f", slowPercentage * 100)
		let mediumString = String(format: "Medium: %.2f", mediumPercentage * 100)
		let fastString = String(format: "Fast: %.2f", fastPercentage * 100)
		let avgString = String(format: "Avg: %.2f", avgDistance)
		velocityLabel.text = "\(slowString)%\n\(mediumString)%\n\(fastString)%\n\(avgString)pts"
		*/
		
		let redDiff = (withDistance/50) * (247-229)
		let greenDiff = (withDistance/50) * (203-77)
		let blueDiff = (withDistance/50) * (87-66)
		let redValue = CGFloat(247 - redDiff)/255
		let greenValue = CGFloat(203 - greenDiff)/255
		let blueValue = CGFloat(87 - blueDiff)/255
		
		return UIColor(red: redValue, green:greenValue , blue: blueValue, alpha: 1.0)
	}
	
	//MARK: Touch Processing
	func processTouches(indexes:[(finger:Int,touch:Int)]){
		//var isStartEnd = false
		var pointsforBoxes = [CGPoint]()
		indexes.forEach { (index) in
			let thisFingersTouches = savedTouches[index.finger]
			let thisTouch = thisFingersTouches![index.touch]!
			
			var previousTouch:Touch?
			if thisTouch.touchPhase == UITouch.Phase.began.rawValue{
				previousTouch = thisTouch
				fingerLineCounts[index.finger] += 1
			}
			else{
				previousTouch = thisFingersTouches![index.touch-1]
			}
	
			toPoint = TouchHandler.shared.location(fromTouch: thisTouch)
			fromPoint = TouchHandler.shared.location(fromTouch: previousTouch!)
//			fromPoint = TouchHandler.shared.location(fromTouch: thisTouch)
//			toPoint = TouchHandler.shared.location(fromTouch: previousTouch!)
			
			pointsforBoxes.append(fromPoint!)
			pointsforBoxes.append(toPoint!)
	
			
			pointsToDraw.append((fromPoint: fromPoint!, toPoint: toPoint!, isPencil: thisTouch.isPencil, touchPhase: Int(thisTouch.touchPhase), number: fingerLineCounts[index.finger]))
			
		}
		let rect = getRect(fromPoints: pointsforBoxes)
		if showStartEnd == true && rect.width < 20{
			self.setNeedsDisplay()

		}
		else{
			self.setNeedsDisplay(rect)
		}
		
	}
	
	func getRect(fromPoints:[CGPoint]) -> CGRect{
		let path = CGMutablePath()
		path.addLines(between: fromPoints)
		var finalRect = path.boundingBoxOfPath
		finalRect.size.width += strokeWidth * 2
		finalRect.size.height += strokeWidth * 2
		finalRect.origin.x -= strokeWidth
		finalRect.origin.y -= strokeWidth
		return finalRect
		
	}
	
	//MARK: - TESTING BEZIER PATH
	

	func quadCurvedPath(atIndex:Int) -> UIBezierPath {
		var thisPoint = pointsToDraw[atIndex]
		let path = UIBezierPath()
		if atIndex > 0{
			thisPoint = pointsToDraw[atIndex - 1]
		}
		let p1 = CGPoint(x: thisPoint.fromPoint.x, y: thisPoint.fromPoint.y)
		let p2 = CGPoint(x: thisPoint.toPoint.x, y: thisPoint.toPoint.y)
		path.move(to: p1)
		//drawPoint(point: p1, color: UIColor.red, radius: 3)//Draws the circle at specific points
		
		//let upperP2 = CGPoint(x: p2.x, y:p2.y-5)
		//drawPoint(point: p2, color: .orange, radius: 2)
		if (pointsToDraw.count == 2) {
			print("Only 2 Points")
			path.addLine(to: p2)
			return path
		}

		var p3: CGPoint?
		if atIndex < (pointsToDraw.count) {
			let nextPoint = pointsToDraw[atIndex]
			p3 = CGPoint(x: nextPoint.toPoint.x, y: nextPoint.toPoint.y)
			let upperP3 = CGPoint(x: p3!.x, y:p3!.y+5)
			//drawPoint(point: upperP3, color: .green, radius: 2)
		}
		//print("P3 is \(p3)")
		//let newControlP = controlPointForPoints(p1: p1, p2: p2, next: p3)
		//let newControlP = p2.controlPointToPoint(p1)
		//drawPoint(point: newControlP ?? p2, color: .gray, radius: 2)
		//drawPoint(point: oldControlPoint ?? p1, color: .white, radius: 2)
		//path.addCurve(to: p2, controlPoint1: oldControlPoint ?? p1, controlPoint2: newControlP/* ?? p2*/)
		//path.addQuadCurve(to: p2, controlPoint: oldControlPoint ?? p1)
		path.addLine(to: p2)
		//p1 = p2
		//oldControlPoint = antipodalFor(point: newControlP, center: p2)
		return path;
	}

		/// located on the opposite side from the center point
		func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
			guard let p1 = point, let center = center else {
				return nil
			}
			let newX = 2 * center.x - p1.x
			let diffY = abs(p1.y - center.y)
			let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)

			return CGPoint(x: newX, y: newY)
		}

		/// halfway of two points
		func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
			return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2);
		}

		/// Find controlPoint2 for addCurve
		/// - Parameters:
		///   - p1: first point of curve
		///   - p2: second point of curve whose control point we are looking for
		///   - next: predicted next point which will use antipodal control point for finded
		func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
			guard let p3 = p3 else {
				return nil
			}

			let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
			let rightMidPoint = midPointForPoints(p1: p2, p2: p3)

			var controlPoint = midPointForPoints(p1: leftMidPoint, p2: antipodalFor(point: rightMidPoint, center: p2)!)

			if p1.y.between(a: p2.y, b: controlPoint.y) {
				controlPoint.y = p1.y
			} else if p2.y.between(a: p1.y, b: controlPoint.y) {
				controlPoint.y = p2.y
			}


			let imaginContol = antipodalFor(point: controlPoint, center: p2)!
			if p2.y.between(a: p3.y, b: imaginContol.y) {
				controlPoint.y = p2.y
			}
			if p3.y.between(a: p2.y, b: imaginContol.y) {
				let diffY = abs(p2.y - p3.y)
				controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
			}

			// make lines easier
			controlPoint.x += (p2.x - p1.x) * 0.1

			return controlPoint
		}

		func drawPoint(point: CGPoint, color: UIColor, radius: CGFloat) {
			let ovalPath = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
			color.setFill()
			ovalPath.fill()
		}

}
private extension CGPoint {
	
	/// Get the mid point of the receiver with another passed point.
	///
	/// - Parameter p2: other point.
	/// - Returns: mid point.
	func midPointForPointsTo(_ p2: CGPoint) -> CGPoint {
		CGPoint(x: (x + p2.x) / 2, y: (y + p2.y) / 2)
	}
	
	/// Control point to another point from receiver.
	///
	/// - Parameter p2: other point.
	/// - Returns: control point for quad curve.
	func controlPointToPoint(_ p2:CGPoint) -> CGPoint {
		var controlPoint = midPointForPointsTo(p2)
		let  diffY = abs(p2.y - controlPoint.y)
		if y < p2.y {
			controlPoint.y = controlPoint.y + diffY
		} else if y > p2.y {
			controlPoint.y = controlPoint.y - diffY
		}
		return controlPoint
	}
	
}
