//
//  MultiTouchCaptureView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 26/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit



class MultiTouchCaptureView: UIView {
	
	//Drawing Params
	var strokeWidth: CGFloat = 5.0
	var fingerLineColor: UIColor = .black
	var pencilLineColor: UIColor = .blue
	
	//Arrays and Models
	var savedTouches = [[Touch?]?]()
	var fromPoint:CGPoint?
	var toPoint:CGPoint?
	var pointsToDraw = [(CGPoint,CGPoint,Bool)]()
	
	
	//Multitouch
	var fingers = [UITouch?](repeating: nil, count:6)
	

	
	
	//MARK: Drawing Code
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		resetView()
		clearsContextBeforeDrawing = false
		backgroundColor = .clear
		isOpaque = true
		self.contentMode = UIView.ContentMode.redraw
	}
	func resetView(){
		toPoint = CGPoint.zero
		fromPoint = CGPoint.zero
		//currentRect = CGRect.zero
		if savedTouches.count != 0{
			savedTouches.removeAll()
			pointsToDraw.removeAll()
		}
		for _ in 0..<5 {
			let newTouchArray = [Touch]()
			savedTouches.append(newTouchArray)
		}
		setNeedsDisplay()
	}
	
	override func draw(_ rect: CGRect){
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		//Draw a rectangle
//		let grayWithAlpha = (UIColor.lightGray).withAlphaComponent(0.1).cgColor
//		context.setFillColor(grayWithAlpha)
//		context.fill(currentRect!)
//		context.stroke(currentRect!)

		
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
	
	func processTouches(indexes:[(Int,Int)]){
		print("Processing \(indexes.count) touches now")
		var pointsforBoxes = [CGPoint]()
		indexes.forEach { (index) in
			let thisTouchArray = savedTouches[index.0]
			let thisTouch = thisTouchArray![index.1]
			var lastTouch:Touch?
			if index.1 == 0 || thisTouch!.touchType == UITouch.Phase.began.rawValue{
				lastTouch = thisTouch
			}
			else{
				lastTouch = thisTouchArray![index.1-1]
			}
	
			fromPoint = TouchHandler.shared.location(fromTouch: thisTouch!)
			toPoint = TouchHandler.shared.location(fromTouch: lastTouch!)
			pointsforBoxes.append(fromPoint!)
			pointsforBoxes.append(toPoint!)
			if thisTouch!.isPencil == true{
				pointsToDraw.append((fromPoint!,toPoint!, true))
			}
			else{
				pointsToDraw.append((fromPoint!,toPoint!, false))
			}
		}
	
		let rect = getRect(fromPoints: pointsforBoxes)
		//currentRect = rect
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

	//MARK: Capturing Touches
	//Multitouch

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		var indexes = [(Int,Int)]()
		for touch in touches{
			//let point = touch.location(in: self)
			for (index,finger)  in fingers.enumerated() {
				print("There are now \(index+1) fingers on screen")
				if finger == nil {
					fingers[index] = touch
					let pencilBool = getPencil(inTouch: touch)
					let convertedTouch = TouchHandler.shared.convertfromUITouchWithFinger(touch, finger: Int64(index), isPencil: pencilBool, inView: self)
					savedTouches[index]?.append(convertedTouch)
					let newIndex = savedTouches[index]!.count - 1
					indexes.append((index,newIndex))
					break
				}
			}
		}
		processTouches(indexes: indexes)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		var indexes = [(Int,Int)]()
		for touch in touches {
			//let point = touch.location(in: self)
			for (index,finger) in fingers.enumerated(){
				if let finger = finger, finger == touch {
					self.fingers[index] = touch
					//Deal with Touches
					let pencilBool = getPencil(inTouch: touch)
					let convertedTouch = TouchHandler.shared.convertfromUITouchWithFinger(touch, finger: Int64(index), isPencil: pencilBool, inView: self)
					savedTouches[index]!.append(convertedTouch)
					let newIndex = savedTouches[index]!.count - 1
					indexes.append((index,newIndex))
					break
				}
			}
		}
		processTouches(indexes: indexes)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		for touch in touches {
			for (index,finger) in fingers.enumerated() {
				if let finger = finger, finger == touch {
					fingers[index] = nil
					break
				}
			}
		}
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		touchesEnded(touches, with: event)
	}

	func getPencil(inTouch:UITouch) -> Bool{
		var isPencil = false
		if inTouch.azimuthAngle(in: self) != 0.0{
			isPencil = true
		}
		return isPencil
	}
}
