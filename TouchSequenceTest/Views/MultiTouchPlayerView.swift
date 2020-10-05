//
//  MultiTouchPlayerView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 27/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol MultiTouchPlayerViewDelegate {
	func updateSlider(valueAsPercentage:Float)
	func updateViews(isPlaying:Bool)
}

class MultiTouchPlayerView: TouchCoreView {
	
	//Timer Stuff
	var timer = Timer()
	var timeElapsed:TimeInterval = 0
	var startTime:Date?
	var endTime:Date?
	@IBOutlet var timeIntervalLabel:UILabel?
	
	var playerDelegate:CaptureViewController?
	
	
	//MARK: Drawing Code
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func setupPlayerView(){
		//Get Start and End Date
		var tempStart = [Date]()
		var tempEnd = [Date]()
		savedTouches.forEach { (touchArray) in
			if touchArray!.count > 0{
				let array = touchArray as! [Touch]
				print("This array contains \(array.count) touches")
				tempStart.append(array[0].timeStamp!)
				tempEnd.append(array[array.count-1].timeStamp!)
			}
		}
		startTime = tempStart.min()
		endTime = tempEnd.max()
		print("Start:\(String(describing: startTime)) End:\(String(describing: endTime))")
		setNeedsDisplay()
	}
	

	
	

	
	public func prepareLinesToDraw(isScrubbing:Bool){
		
		print(timeElapsed)
		let currentTime = startTime! + timeElapsed
		//var pointsforBoxes = [CGPoint]()
		var indexes = [(Int,Int)]()
		for (fingerIndex,touchArray) in savedTouches.enumerated(){
			for (touchIndex,thisTouch) in touchArray!.enumerated(){
				
				if isScrubbing == false && (thisTouch!.timeStamp?.isBetween(currentTime, and: currentTime + 0.05) == true){
					indexes.append((fingerIndex, touchIndex))
					//break
				}
				else if isScrubbing == true && (thisTouch!.timeStamp?.isBetween(currentTime, and: startTime!) == true){
					indexes.append((fingerIndex, touchIndex))
				}
			}
		}
		if isScrubbing == true {
			setNeedsDisplay()
		}
		processTouches(indexes: indexes)
	}
	
	func fireEvent(){
		let currentTime = startTime! + timeElapsed
		if currentTime < endTime!{
			prepareLinesToDraw(isScrubbing:false)
		}
		else{
			timer.invalidate()
			playerDelegate!.updateViews(isPlaying:false)
			timeElapsed = 0
		}
	}
	
	
	//MARK: Timer Functions
	@objc func updateTimer(){
		//Show time elapsed in timer
		timeElapsed += 0.05
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		
		//Show in playback scrubber
		
		let totalTimeInterval = endTime?.timeIntervalSince(startTime!)
		let sliderPercentage = timeElapsed/totalTimeInterval!
		playerDelegate?.updateSlider(valueAsPercentage: Float(sliderPercentage))
		
		//Do the thing to draw the line
		fireEvent()
		
	}
	
	func tapButton(isPlaying:Bool){
		if isPlaying == true{
			if timeElapsed == 0{
				print("Playing after time exhausted")
				toPoint = CGPoint.zero
				fromPoint = CGPoint.zero
				pointsToDraw.removeAll()
				setNeedsDisplay()
			}
			let newTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
			RunLoop.current.add(newTimer, forMode: .common)
			timer.tolerance = 0.1
			self.timer = newTimer
		} else {
			timer.invalidate()
		}
	}
	
	

}
