//
//  TouchCaptureView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 19/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class TouchCaptureView: UIView {
	
	var savedTouches = [Touch]()
	var lastTouch:Touch?
	var strokeWidth: CGFloat = 5.0
	var lineColor: UIColor = .black
	
	//Testing Multitouch
	var fingers = [UITouch?](repeating: nil, count:5)
	
	//MARK: Drawing Code
    override func draw(_ rect: CGRect) {
        // Drawing code
		super.draw(rect)
		guard let context = UIGraphicsGetCurrentContext() else {
			return

		}
		
		savedTouches.forEach { (touch) in
			
			let thisPoint = CGPoint(x: CGFloat(touch.xLocation), y: CGFloat(touch.yLocation))
			let lastPoint = CGPoint(x: CGFloat(lastTouch!.xLocation), y: CGFloat(lastTouch!.yLocation))
			
			context.move(to: lastPoint)
			//Add lines
			//print("Touch phase is \(touch.touchType)")
			if touch.touchType == UITouch.Phase.began.rawValue {
				//Add a circle for Pro
			}
			else{
				context.addLine(to: thisPoint)
			}
			context.setLineWidth(5.0)
			//Set Stroke Color (for Pro)
			context.setStrokeColor(lineColor.cgColor)
			context.setBlendMode(CGBlendMode.normal)
			context.setLineCap(.round)
			context.strokePath()
			lastTouch = touch
			
			lastTouch = touch
		}
    }
    
	//MARK: Capturing Touches
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		//Single Touch
		if touches.count != 0{
			let touch = touches.first! as UITouch
			let convertedTouch = TouchHandler.shared.convertfromUITouch(touch, inView: self)
			savedTouches.append(convertedTouch)

			if lastTouch == nil{
				lastTouch = convertedTouch
			}
		}
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			
			let touch = touches.first! as UITouch
			if let coalescedTouches = event!.coalescedTouches(for: touch)
			{
				for coalescedTouch in coalescedTouches
					{
						let convertedTouch = TouchHandler.shared.convertfromUITouch(coalescedTouch, inView: self)
						savedTouches.append(convertedTouch)
					}
			}
			else{
				let convertedTouch = TouchHandler.shared.convertfromUITouch(touch, inView: self)
				savedTouches.append(convertedTouch)
			}
		}
		setNeedsDisplay()
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			let touch = touches.first! as UITouch
			savedTouches.append(TouchHandler.shared.convertfromUITouch(touch, inView: self))
		}
		setNeedsDisplay()
	}

}
