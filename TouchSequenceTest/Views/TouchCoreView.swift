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
	var strokeWidth: CGFloat = 5.0
	var fingerLineColor: UIColor = .black
	var pencilLineColor: UIColor = .blue
	var showStartEnd = false
	var showLineVelocity = false
	var linesShown = 0//0,Both;1,Fingers;2,Pencil
	var mostRecentTouch:Int = 1
	
	//Velocty Stuff
	var slowCount = 0.0
	var mediumCount = 0.0
	var fastCount = 0.0
	var slowDistance = 0.0
	var mediumDistance = 0.0
	var fastDistance = 0.0
	
	//Arrays and Models
	var savedTouches = [[Touch?]?]()
	var fromPoint:CGPoint?
	var toPoint:CGPoint?
	var pointsToDraw = [(CGPoint,CGPoint,Bool)]()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		backgroundColor = .clear
		contentMode = UIView.ContentMode.redraw
	}
	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		//Draw Lines
		pointsToDraw.forEach { (pointSet) in
			context.move(to: pointSet.0)
			context.addLine(to: pointSet.1)
			context.setLineWidth(5.0)
			
			let distance = Helpers.shared.distance(a: pointSet.0, b: pointSet.1)
			
			if pointSet.2 == false{//If it's a finger
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
		
		let totalSegment = slowCount + mediumCount + fastCount
		let totalDistance = slowDistance + mediumDistance + fastDistance
		
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
	func processTouches(indexes:[(Int,Int)]){
		var pointsforBoxes = [CGPoint]()
		indexes.forEach { (index) in
			let thisTouchArray = savedTouches[index.0]
			let thisTouch = thisTouchArray![index.1]!
			var lastTouch:Touch?
			if index.1 == 0 || thisTouch.touchType == UITouch.Phase.began.rawValue{
				lastTouch = thisTouch
			}
			else{
				lastTouch = thisTouchArray![index.1-1]
			}
	
			fromPoint = TouchHandler.shared.location(fromTouch: thisTouch)
			toPoint = TouchHandler.shared.location(fromTouch: lastTouch!)
			
			pointsforBoxes.append(fromPoint!)
			pointsforBoxes.append(toPoint!)
	
			if thisTouch.isPencil == true{
				pointsToDraw.append((fromPoint!,toPoint!, true))
			}
			else{
				pointsToDraw.append((fromPoint!,toPoint!, false))
			}
		}
	
		let rect = getRect(fromPoints: pointsforBoxes)
		//print("Rect is \(rect) and there are \(pointsToDraw.count) points to draw")
		self.setNeedsDisplay(rect)
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

}
