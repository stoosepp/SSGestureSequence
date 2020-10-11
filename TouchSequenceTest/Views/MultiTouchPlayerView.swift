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

class MultiTouchPlayerView: TouchCoreView, PlaybackSettingsDelegate {
	
	
	//Timer STuff
	var timer = Timer()
	var timeElapsed:TimeInterval = 0
	var startTime:Date?
	var endTime:Date?
	var frameRate:CGFloat = 0.05
	@IBOutlet var timeIntervalLabel:UILabel?
	
	var playerDelegate:PlaybackViewController?

	//Viewing Options
	var isScrubbing:Bool = false

	
	//MARK: DRAWING CODE
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func setupPlayerView(){

		//Parse DataSetset
		savedTouches = parseDataSet(dataSet: dataSet!)
		//Set start and end times (based on dataset)
		startTime = dataSet!.startDate
		endTime = dataSet!.endDate
		isScrubbing = true
		timeElapsed = endTime!.timeIntervalSince(startTime!)
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		prepareLinesToDraw()
	}
	
	func parseDataSet(dataSet :DataSet) -> [[Touch]]{
		//Sets in swift are not ordered, so we need to sort the DataSet by timestamp
		let touchArray = (dataSet.touches as! Set<Touch>).sorted(by: { $0.timeStamp! < $1.timeStamp! })

		//let touchArray = dataSet.touches?.allObjects as! [Touch]
		let fingersDict = Dictionary(grouping:touchArray){$0.finger}
		var fingerArrays = [[Touch]]()
		for (_,value) in fingersDict{
			fingerArrays.append(value)
		}
		return fingerArrays
	}
	
	func addSequenceCount(currentTouch:Int, atLocation:CGPoint, radius:CGFloat, color:UIColor){
			let circleView = CircleView(frame: CGRect(x: atLocation.x - radius, y: atLocation.y - radius , width: radius * 2, height: radius * 2))
			circleView.labelText = "\(currentTouch)"
			circleView.theColor = color
		}

	//MARK: PROCESS LINES
	public func prepareLinesToDraw(){
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
				if linesShown == 2 && thisTouch!.isPencil == false && indexes.count > 0{
					//pointsToDraw.append((fromPoint!,toPoint!, true))
					indexes.removeLast()
				}
				else if linesShown == 1 && thisTouch!.isPencil == true && indexes.count > 0{
					//pointsToDraw.append((fromPoint!,toPoint!, false))
					indexes.removeLast()
				}
				
			}
		}
		if isScrubbing == true {
			timeElapsed -= 0.05
			setNeedsDisplay()//Need to do this to erase previous lines
		}
		processTouches(indexes: indexes)
	}
	
	func fireEvent(){
		let currentTime = startTime! + timeElapsed
		if currentTime < endTime!{
			prepareLinesToDraw()
		}
		else{
			timer.invalidate()
			playerDelegate!.updateViews(isPlaying:false)
			timeElapsed = 0
		}
	}
	
	//MARK: DELEGATE STUFF
	func updatePencilColor(color: UIColor) {
		pencilLineColor = color
		setNeedsDisplay()
	}
	
	func updateFingerColor(color: UIColor) {
		fingerLineColor = color
		setNeedsDisplay()
	}
	
	func updateLinesDrawn(withValue: Int) {
		linesShown = withValue
		pointsToDraw.removeAll()
		self.setNeedsDisplay()
		prepareLinesToDraw()
	}
	func toggleStartEnd(withValue:Bool) {
		
		
		self.setNeedsDisplay()
		prepareLinesToDraw()
	}
	
	func toggleLineSpeed(withValue:Bool) {
		showLineVelocity = withValue
		pointsToDraw.removeAll()
		self.setNeedsDisplay()
		prepareLinesToDraw()
	}
	
	//MARK: TIMER
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
			let atEndTime = endTime!.timeIntervalSince(startTime!) - 0.05
			if timeElapsed == atEndTime{
				print("Payhead at the end, resetting")
				playerDelegate?.updateSlider(valueAsPercentage: 0)
				timeElapsed = 0
				pointsToDraw.removeAll()
				setNeedsDisplay()
			}
			if timeElapsed == 0{
				toPoint = CGPoint.zero
				fromPoint = CGPoint.zero
				pointsToDraw.removeAll()
				setNeedsDisplay()
			}
			else{
				print("Time elapsed is \(timeElapsed)")
				print("Final Time Elapsed is \(atEndTime)")
			}
	
			//deal with when the scrubbers at the end
			
			let newTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
			RunLoop.current.add(newTimer, forMode: .common)
			timer.tolerance = 0.1
			self.timer = newTimer
		} else {
			timer.invalidate()
		}
	}
	
	

}
