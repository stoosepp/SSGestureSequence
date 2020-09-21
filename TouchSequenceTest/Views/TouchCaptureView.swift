//
//  TouchCaptureView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 19/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class TouchCaptureView: UIView {
	
	struct TouchType {
		static let start = "start"
		static let intermediate = "intermediate"
		static let end = "end"
	}
	var savedTouches = [TouchTest]()
	var visibleTouches = [TouchTest]()
	var lastTouch:TouchTest?
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	@IBOutlet var timeIntervalLabel:UILabel?
	var isPaused:Bool = true
	
	//Deal with Playback
	var timer: Timer?
	var timeElapsed:TimeInterval = 0
    
	//MARK: Drawing Code
    override func draw(_ rect: CGRect) {
		print("Draw Called")
        // Drawing code
		//super.draw(rect)
			   
	   guard let context = UIGraphicsGetCurrentContext() else {
		   return
	   }
		var touchArray = [TouchTest]()
		if timer == nil{
			//If we're not playing back, just display all lines at the same time
			touchArray = savedTouches
		}
		else{
			//If we ARE playing back, just display lines as they correspond to the timer
			touchArray = visibleTouches
		}
		touchArray.forEach { (touch) in
			let currentPoint = CGPoint(x: CGFloat(touch.xLocation!), y: CGFloat(touch.yLocation!))
			let lastPoint = CGPoint(x: CGFloat(lastTouch!.xLocation!), y: CGFloat(lastTouch!.yLocation!))
			context.move(to: currentPoint)
			if touch.touchType != TouchType.start{
				context.addLine(to: lastPoint)
			}
			else{
				//Add Circle (for Pro)
			}
			
			context.setLineWidth(5.0)
			//Set Stroke Color (for Pro)
			context.setStrokeColor(red: 0, green:0 , blue: 0, alpha: 1.0)
			context.setBlendMode(CGBlendMode.normal)
			//print("Drawing Line from \(lastPoint), to \(currentPoint)")
			context.setLineCap(.round)
			context.strokePath()
			lastTouch = touch
			
		}
		
    }
    
	//MARK: Capturing Touches
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			let touch = touches.first! as UITouch
			addNewTouch(touch: touch, touchType: TouchType.start)
			
			if lastTouch == nil{
				lastTouch = savedTouches[0]
			}
		}
		
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			let touch = touches.first! as UITouch
			addNewTouch(touch: touch, touchType: TouchType.intermediate)
			
			setNeedsDisplay()

			//print("Touch Continued with \(savedTouches.count) touches recorded")
		
		}
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count != 0{
			let touch = touches.first! as UITouch
			addNewTouch(touch: touch, touchType: TouchType.end)
			
			setNeedsDisplay()
			print("Touch Ended with \(savedTouches.count) touches recorded")
		
		}
	}
	
	//MARK: Save Touches to Array
	 

	func addNewTouch(touch:UITouch, touchType:String){
		let newTouch = TouchTest()
		newTouch.timeStamp = Date()
		let location = touch.location(in: self)
		newTouch.xLocation = Float(location.x)
		newTouch.yLocation = Float(location.y)
		newTouch.touchType = touchType
		savedTouches.append(newTouch)
	}
	
	
	//MARK: Play Touches
	func playBackTouches(){
		
	}
	

	
	@objc func updateTimer(){
		//Show time elapsed in timer
		timeElapsed += 0.05
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		
		//Show in playback scrubber
		
		//Draw Line
		drawNextLine()
	}
	
	func playPause(){
		if isPaused{
			let newTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
			RunLoop.current.add(newTimer, forMode: .common)
			timer?.tolerance = 0.1
			self.timer = newTimer
			isPaused = false
		} else {
			timer!.invalidate()
			isPaused = true
		}
	}
	
	func drawNextLine(){
		
		print(timeElapsed)
		var tempTouchArray = [TouchTest]()
		let startTime = savedTouches[0].timeStamp
		let endTime = savedTouches[savedTouches.count-1].timeStamp
		let currentTime = startTime! + timeElapsed
		if currentTime < endTime!{
			for touch in savedTouches{
				if touch.timeStamp?.isBetween(startTime!, and: currentTime) == true{
					tempTouchArray.append(touch)
				}
			}
			visibleTouches = tempTouchArray
			print(String(format: "Timer: %.2f", timeElapsed))
			print("There are \(tempTouchArray.count) touches until now")
			setNeedsDisplay()
		}
		else{
			timer?.invalidate()
			//timeIntervalLabel!.text = "The End"
		}
		
		
		
	}
	
	

	
}
