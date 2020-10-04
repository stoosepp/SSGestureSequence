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


class MultiTouchPlayerView: UIView {

	//Drawing Params
	var strokeWidth: CGFloat = 5.0
	var fingerLineColor: UIColor = .black
	var pencilLineColor: UIColor = .blue
	
	//Arrays and Models
	var savedTouches = [[Touch?]?]()
	var fromPoint:CGPoint?
	var toPoint:CGPoint?
	var pointsToDraw = [(CGPoint,CGPoint,Bool)]()
	

	//Timer Stuff
	var timer = Timer()
	var timeElapsed:TimeInterval = 0
	var startTime:Date?
	var endTime:Date?
	@IBOutlet var timeIntervalLabel:UILabel?
	
	var playerDelegate:ViewController?
	
	
	//MARK: Drawing Code
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		//resetView()
		backgroundColor = .clear
		contentMode = UIView.ContentMode.redraw
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
