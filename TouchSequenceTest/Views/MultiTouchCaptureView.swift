//
//  MultiTouchCaptureView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 26/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class MultiTouchCaptureView: UIView {

	
	var savedTouches = [[Touch]?]()
	var lastTouches = [UITouch]()
	var lastTouch:Touch?
	var strokeWidth: CGFloat = 5.0
	var lineColor: UIColor = .black
	var currentRect:CGRect?
	var lastRect:CGRect?
	//Testing Multitouch
	var fingers = [UITouch?](repeating: nil, count:5)
	
	//Testing Simpler Drawing
	var fromPoint:CGPoint?
	var toPoint:CGPoint?
	var isPencil:Bool?
	
	//MARK: Drawing Code
	/*
	override func draw(_ rect: CGRect) {
		// Drawing code
	
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		
		guard let context2 = UIGraphicsGetCurrentContext() else {
			return
		}
		let colors = [UIColor.red,UIColor.blue,UIColor.orange,UIColor.purple,UIColor.systemPink,UIColor.green,UIColor.gray]
		
		savedTouches.forEach { (fingerArray) in
			var localLastTouch:Touch?
			fingerArray!.forEach { (touch) in
				
	
				
				//Draw Line
				if localLastTouch == nil{
					localLastTouch = touch
				}
				let thisPoint = CGPoint(x: CGFloat(touch.xLocation), y: CGFloat(touch.yLocation))
				let lastPoint = CGPoint(x: CGFloat(localLastTouch!.xLocation), y: CGFloat(localLastTouch!.yLocation))
				context.move(to: lastPoint)

				if touch.touchType == UITouch.Phase.began.rawValue {
					//Add a circle for Pro
				}
				else{
						context.addLine(to: thisPoint)
				}
				context.setLineWidth(5.0)
				//Set Stroke Color (for Pro)
				if touch.isPencil{
					let color = UIColor.blue
					context.setStrokeColor(color.cgColor)
				}
				else{
					context.setStrokeColor(lineColor.cgColor)
				}
				
				context.setBlendMode(CGBlendMode.normal)
				context.setLineCap(.round)
				context.strokePath()
				localLastTouch = touch
				
				//Draw a rectangle
//				let boxColor = colors.randomElement()
//				//let alpha = boxColor?.withAlphaComponent(0.1)
//				//context2.setFillColor(alpha!.cgColor)
//				let grayWithAlpha = (UIColor.lightGray).withAlphaComponent(0.1).cgColor
//				context.setFillColor(grayWithAlpha)
//				context.fill(currentRect!)
				}
		}
	}
*/
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		toPoint = CGPoint.zero
		fromPoint = CGPoint.zero
		currentRect = CGRect.zero
	}
	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
		context.move(to: fromPoint!)
		context.addLine(to: toPoint!)
		context.setLineWidth(5.0)
		//Set Stroke Color (for Pro)
		context.setBlendMode(CGBlendMode.normal)
		context.setLineCap(.round)
		context.strokePath()
		
		//Draw a rectangle
		let grayWithAlpha = (UIColor.lightGray).withAlphaComponent(0.1).cgColor
		context.setFillColor(grayWithAlpha)
		context.fill(currentRect!)
		
	}
	
	//MARK: Get Rect to draw in
	
	/*
	func getRect(fromTouch:Touch, toTouch:Touch) -> CGRect{
		//Get Size
		let rectWidth = CGFloat(abs(fromTouch.xLocation - lastTouch!.xLocation))
		let rectHeight = CGFloat(abs(fromTouch.yLocation - lastTouch!.yLocation))
		
		//Get Origin
		var originX = min(fromTouch.xLocation, toTouch.xLocation)
		var originY = min(fromTouch.yLocation, toTouch.yLocation)
		originX -= Float(strokeWidth*4)
		originY -= Float(strokeWidth*4)
		let origin = CGPoint(x: CGFloat(originX), y: CGFloat(originY))
		
		let size = CGSize(width: rectWidth + strokeWidth*4, height: rectHeight + strokeWidth*4)
		currentRect = CGRect(origin: origin, size: size)
		return CGRect(origin: origin, size: size)
	}
	*/
	func theRect(fromTouch:UITouch, toTouch:UITouch) -> CGRect{
		let fromLocation = fromTouch.location(in: self)
		let toLocation = toTouch.location(in: self)
		let rectWidth = CGFloat(abs(fromLocation.x - toLocation.x))
		let rectHeight = CGFloat(abs(fromLocation.y - toLocation.y))
		
		var originX = min(fromLocation.x, toLocation.x)
		var originY = min(fromLocation.y, toLocation.y)
		originX -= strokeWidth*2
		originY -= strokeWidth*2
//		if fromLocation.x > toLocation.x{
//			originX += CGFloat(strokeWidth*2)
//		}
//		else{
//			originX -= CGFloat(strokeWidth*2)
//		}
//		if fromLocation.y > toLocation.y{
//			originY += CGFloat(strokeWidth*2)
//		}
//		else{
//			originY -= CGFloat(strokeWidth*2)
//		}
		let origin = CGPoint(x: CGFloat(originX), y: CGFloat(originY))
		let size = CGSize(width: rectWidth + strokeWidth*2, height: rectHeight + strokeWidth*2)
		currentRect = CGRect(origin: origin, size: size)
		return CGRect(origin: origin, size: size)
	}

	//MARK: Capturing Touches
	//Multitouch
		
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
//		if savedTouches.count == 0{
//			for _ in 0..<5{
//				let newFinger = [Touch]()
//				savedTouches.append(newFinger)
//			}
//		}
		for touch in touches{
			for (index,finger)  in fingers.enumerated() {//This runs through 0...5 to get the index of each finger
				if finger == nil {
					fingers[index] = touch
					
					//CoreData Stuff
//					let convertedTouch = TouchHandler.shared.convertfromUITouchWithFinger(touch, finger: Int64(index), isPencil:getPencil(inTouch: touch),  inView: self)
//					savedTouches[index]?.append(convertedTouch)
					
					//Set Last Touch for drawing
					lastTouches.append(touch)
					print("There are \(lastTouches.count) Fingers on screen now")
					break
				}
			}
		}
		
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		for touch in touches {
			for (index,finger) in fingers.enumerated() {
				
				if let finger = finger, finger == touch {
					//Setup for CoreData
					
//					let convertedTouch = TouchHandler.shared.convertfromUITouchWithFinger(finger, finger: Int64(index), isPencil:getPencil(inTouch: finger),  inView: self)
//					savedTouches[index]?.append(convertedTouch)
					
					fingers[index] = touch
					
					//What are the points we're drawing?
					let lastTouch = lastTouches[index]
					print("This Finger \(index+1) location: \(touch.location(in: self))")
					print("Last Finger \(index+1) location: \(lastTouch.location(in: self))")
					
					
					//Setup for Drawing
					fromPoint = lastTouch.location(in: self)
					toPoint = touch.location(in: self)
					let rect = theRect(fromTouch: lastTouches[index], toTouch: touch)
					currentRect = rect
					setNeedsDisplay()
					lastTouches[index] = touch
					print("Last Touch for finger \(index) set to \(touch.location(in: self))")
					//lastTouches.remove(at: index)
					//lastTouches.append(fingers[index]!)
					break
				}
				
			}
//			let rect = getRect(fromTouch: thisTouch!)
//			self.setNeedsDisplay(rect)
//			lastTouch = thisTouch!
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		for touch in touches {
			for (index,finger) in fingers.enumerated() {
				if let finger = finger, finger == touch {
//					let convertedTouch = TouchHandler.shared.convertfromUITouchWithFinger(fingers[index]!, finger: Int64(index), isPencil:getPencil(inTouch: fingers[index]!),  inView: self)
//					savedTouches[index]?.append(convertedTouch)
					//Draw last line
					
					//Deal with Arrays
					//if lastTouches.count > 0{
					
					//}
					print("Removing Finger \(index+1), No there are \(lastTouches.count) on screen. ")
					fingers[index] = nil
					lastTouches.removeLast()
					break
				}
				
			}
		}
		//self.setNeedsDisplay()
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
//		guard let touches = touches else{
//			return
//		}
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
