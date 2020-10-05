//
//  TouchCoreView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 3/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class TouchCoreView: UIView {
	
	//Drawing Params
	var strokeWidth: CGFloat = 5.0
	var fingerLineColor: UIColor = .black
	var pencilLineColor: UIColor = .blue
	
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
			if pointSet.2 == false{//If it's a finger
				context.setStrokeColor(fingerLineColor.cgColor)
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
	
	//MARK: Touch Processing
	func processTouches(indexes:[(Int,Int)]){
		print("Processing \(indexes.count) touches now")
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
		print("Rect is \(rect) and there are \(pointsToDraw.count) points to draw")
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
