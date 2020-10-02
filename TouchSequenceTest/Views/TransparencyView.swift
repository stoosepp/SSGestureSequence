//
//  DrawingView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class TransparencyView: UIView {
	
	@IBOutlet weak var velocityLabel: UILabel!
	@IBOutlet weak var tempImageView: UIImageView!
	@IBOutlet weak var mainImageView: UIImageView!

	var lastPoint = CGPoint.zero
	var swiped = false
	var currentTouch = 0

	var slowCount = 0.0
	var mediumCount = 0.0
	var fastCount = 0.0

	var slowDistance = 0.0
	var mediumDistance = 0.0
	var fastDistance = 0.0

	var linesHidden:Bool?
	var captureRect:CGRect?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	public func resetView(){
		for view in tempImageView.subviews{
			view.removeFromSuperview()
		}
		tempImageView.image = nil
		mainImageView.image = nil
		currentTouch = 0
		velocityLabel.text = "Slow: 0%\nMedium: 0%\nFast: 0%\nAvg: 0pts"
		slowCount = 0.0
		mediumCount = 0.0
		fastCount = 0.0
		
		slowDistance = 0.0
		mediumDistance = 0.0
		fastDistance = 0.0
	}
	
	//MARK: - DRAWING CODE
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		currentTouch += 1
		swiped = false
		if touches.count != 0{
			let touch = touches.first! as UITouch
			lastPoint = touch.location(in: self.mainImageView)
			let green = UIColor.init(red: 167/255, green: 197/255, blue: 116/255, alpha: 1.0)
			addSequenceCount(atLocation: lastPoint, radius: 10, color:green)
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		swiped = true
		if touches.count != 0{
			let touch = touches.first! as UITouch
			//Line below might not be needed
			//lastPoint = touch.location(in: self.mainImageView)
			//Using Coalesced point.
			for coalescedTouch in (event?.coalescedTouches(for: touch))!{
				let coalescedPoint = coalescedTouch.location(in: mainImageView)
				let distanceBetween = distance(a: lastPoint, b: coalescedPoint)
				drawLineFrom(lastPoint, toPoint: coalescedPoint, withDistance: Double(distanceBetween))
				lastPoint = coalescedPoint
			}
		}
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if !swiped {
			// draw a single point
			 drawLineFrom(lastPoint, toPoint: lastPoint, withDistance: 0.0)
		}
		else
		{
			
		}
	   
		let red = UIColor.init(red: 190/255, green: 75/255, blue: 85/255, alpha: 1.0)
		addSequenceCount(atLocation: lastPoint, radius: 10, color:red)
		
		// Merge tempImageView into mainImageView
		UIGraphicsBeginImageContext(mainImageView.frame.size)
		mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
		tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
		mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
		//This line above is screwing things up 2/15/2020
		UIGraphicsEndImageContext()
		tempImageView.image = nil
	 
	}
	
	func distance(a: CGPoint, b: CGPoint) -> CGFloat {
		let xDist = a.x - b.x
		let yDist = a.y - b.y
		return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
	}
	
	func addSequenceCount(atLocation:CGPoint, radius:CGFloat, color:UIColor){
		let circleView = CircleView(frame: CGRect(x: atLocation.x - radius, y: atLocation.y - radius , width: radius * 2, height: radius * 2))
		circleView.labelText = "\(currentTouch)"
		circleView.theColor = color
		tempImageView.insertSubview(circleView, at: 10)
	}
	
	
	func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint, withDistance:Double) {
		
		// 1
		UIGraphicsBeginImageContext(mainImageView.frame.size)
		let context = UIGraphicsGetCurrentContext()
		tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
		
		// 2
		context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
		context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
		
		// 3
		context!.setLineCap(CGLineCap.round)
		context!.setLineWidth(5.0)


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
		let avgDistance = totalDistance / totalSegment
		if slowPercentage.isNaN{
			slowPercentage = 0.0
		}
		if mediumPercentage.isNaN{
			mediumPercentage = 0.0
		}
		if fastPercentage.isNaN{
			fastPercentage = 0.0
		}
		
		let slowString = String(format: "Slow: %.2f", slowPercentage * 100)
		let mediumString = String(format: "Medium: %.2f", mediumPercentage * 100)
		let fastString = String(format: "Fast: %.2f", fastPercentage * 100)
		let avgString = String(format: "Avg: %.2f", avgDistance)
		//print("TotalSegments:\(totalSegment)\nSlowSegments:\(slowCount)")
		
		velocityLabel.text = "\(slowString)%\n\(mediumString)%\n\(fastString)%\n\(avgString)pts"
		
		let redDiff = (withDistance/50) * (247-229)
		let greenDiff = (withDistance/50) * (203-77)
		let blueDiff = (withDistance/50) * (87-66)
		let redValue = CGFloat(247 - redDiff)/255
		let greenValue = CGFloat(203 - greenDiff)/255
		let blueValue = CGFloat(87 - blueDiff)/255
		
		context!.setStrokeColor(red: redValue, green:greenValue , blue: blueValue, alpha: 1.0)

		context!.setBlendMode(CGBlendMode.normal)
		
		// 4
		context!.strokePath()
		
		// 5
		tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
		//tempImageView.alpha = 0.0//Unhide this for production
		
		UIGraphicsEndImageContext()
	}

}
