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
	
	/*override init(frame: CGRect) {
		
		   super.init(frame: frame)
			//Load if you have them saved somehwere
		self.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
		   NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
		   NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0).isActive = true
		   NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0).isActive = true
		   
	   }
	
	required init(coder aDecoder: NSCoder) {
		super.init(aDecoder: coder)
		   //fatalError("This class does not support NSCoding")
			print("Initialized")
	}*/
	
	//MARK: Drawing Code
    override func draw(_ rect: CGRect) {
		//print("Draw Called")
        // Drawing code
		super.draw(rect)
			   
	  
		print("In Draw there are \(savedTouches.count) displayed")
		savedTouches.forEach { (touch) in
			guard let context = UIGraphicsGetCurrentContext() else {
				return
			}
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
		}
		
		
    }
    
	//MARK: Capturing Touches
	//FIXME: Enable Multitouch
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			let touch = touches.first! as UITouch
			//for touch in touches{
			//let touch = touches.first! as UITouch
			let convertedTouch = TouchHandler.shared.convertfromUITouch(touch, inView: self)
			savedTouches.append(convertedTouch)
			
			//Set Last touch if there are no saved touches
			if lastTouch == nil{
				print("Setting Last Touch")
				lastTouch = convertedTouch
			}
			//}
		}
		
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			
			let touch = touches.first! as UITouch
			print("This touch phase is \(touch.phase.rawValue)")
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
			
			print("Touch Ended with \(savedTouches.count) touches recorded")
	
		}
		setNeedsDisplay()
	}

	
}
