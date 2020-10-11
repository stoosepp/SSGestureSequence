//
//  TouchPlayerView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol TouchPlayerDelegate{
	func updateViews(isPlaying:Bool)
}
class TouchPlayerView: TouchCaptureView {
	
	//var allTouches = [Touch]()
	var visibleTouches = [Touch]()
	var isPaused:Bool = true
	var timer: Timer?
	var timeElapsed:TimeInterval = 0
	var playerDelgate:PlaybackViewController?
	
	@IBOutlet var timeIntervalLabel:UILabel?

	//MARK: Drawing Code
	override func draw(_ rect: CGRect) {
		print("Draw Called")
		// Drawing code
		//super.draw(rect)
			   
	   
		var touchArray = [Touch]()
		if timer == nil{
			//If we're not playing back, just display all lines at the same time
			touchArray = savedTouches
		}
		else{
			//If we ARE playing back, just display lines as they correspond to the timer
			touchArray = visibleTouches
		}
		touchArray.forEach { (touch) in
			guard let context = UIGraphicsGetCurrentContext() else {
				return
			}
			if lastTouch == nil{
				lastTouch = touch
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
			context.setStrokeColor(red: 0, green:0 , blue: 0, alpha: 1.0)
			context.setBlendMode(CGBlendMode.normal)
			context.setLineCap(.round)
			context.strokePath()
			lastTouch = touch
			
		}
		
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
		var tempTouchArray = [Touch]()
		let startTime = savedTouches[0].timeStamp!
		let endTime = savedTouches[savedTouches.count-1].timeStamp
		let currentTime = startTime + timeElapsed
		if currentTime < endTime!{
			for touch in savedTouches{
				if touch.timeStamp?.isBetween(startTime, and: currentTime) == true{
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
			playerDelgate!.updateViews(isPlaying:false)
			isPaused = true
			timeElapsed = 0
		}
		
		
		
	}
	

}
