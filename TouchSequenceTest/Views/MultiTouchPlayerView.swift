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
	func updateViewsAlpha(withAlpha:CGFloat)
}

class MultiTouchPlayerView: TouchCoreView, PlaybackSettingsDelegate {
	
	
	//Timer STuff
	var hasLinesOfType:(fingers:Bool, pencil:Bool) = (fingers:false, pencil:false)
	
	@IBOutlet var timeIntervalLabel:UILabel?
	
	var playerDelegate:PlaybackViewController?
	var allSavedTouches = [[[Touch?]?]?]()

	//Viewing Options
	var isScrubbing:Bool = false
	var isShowingAll:Bool = false
	var isolatedLines:Bool = false
	var linesVisible:Bool = true
	
	//CoreData Stuff
	var dataSets:[DataSet]?
	
	//MARK: - DRAWING CODE
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func setupPlayerView(){
		//Parse DataSetset
		if isShowingAll == false{
			savedTouches = parseDataSet(dataSet: dataSet!)
		}
		else{
			allSavedTouches = parseAllTouches()
		}
		
		timeElapsed = endTime
		isScrubbing = true
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		playerDelegate?.slider.value = 1
		prepareLinesToDraw()
	}
	
	func parseDataSet(dataSet :DataSet) -> [[Touch]]{
		//Sets in swift are not ordered, so we need to sort the DataSet by timestamp
		let touchArray = (dataSet.touches as! Set<Touch>).sorted(by: { $0.timeInterval < $1.timeInterval })
		for touch in touchArray{
			if touch.isPencil == false{
				hasLinesOfType.fingers = true
				break
			}
			else{
				hasLinesOfType.pencil = true
				break
			}
		}
		print("Fingers: \(hasLinesOfType.fingers) Pencil: \(hasLinesOfType.pencil)")
		endTime = (dataSet.endDate?.timeIntervalSince(dataSet.startDate!))!
		
		let fingersDict = Dictionary(grouping:touchArray){$0.finger}
		var fingerArrays = [[Touch]]()
		for (_,value) in fingersDict{
			fingerArrays.append(value)
		}
		return fingerArrays
	}
	
	func parseAllTouches() -> [[[Touch]]]{
		
		print("Showing All. Here we go...")
		//Get all datasets and draw them.
		//FIXME: All touches in provess
		let touchArray = [[[Touch]]]()
		/*var tempEndDate = 0.0
		if let allDataSets = self.dataSet?.experiment?.stimuli.dataSets{
			allDataSets.forEach({ (singleDataSet) in
				let thisDataSet = singleDataSet as! DataSet
				let thisArray = parseDataSet(dataSet: thisDataSet)
				let thisTimeInterval = (thisDataSet.endDate?.timeIntervalSince(thisDataSet.startDate!))!
				if tempEndDate < thisTimeInterval{
					tempEndDate = thisTimeInterval
				}
				touchArray.append(thisArray)
			})
		}
		endTime = tempEndDate
		print("End time:\(endTime)")*/
		return touchArray
	}
	
	
	//MARK: -  PROCESS LINES
	public func prepareLinesToDraw(){
		if isShowingAll == false{
			prepareLinesFromArray(thisArray: savedTouches)
		}
		else {
			//print("Preparing for all DataSet")
			allSavedTouches.forEach { (arrayOfArrays) in
				prepareLinesFromArray(thisArray: arrayOfArrays!)
			}
		}
	}
	
	func prepareLinesFromArray(thisArray:[[Touch?]?]){
		var indexes = [(Int,Int)]()
		for (fingerIndex,touchArray) in thisArray.enumerated(){
			for (touchIndex,thisTouch) in touchArray!.enumerated(){
				if isolatedLines == true{
					if currentStimulusStartTime...timeElapsed ~= thisTouch!.timeInterval{
						indexes.append((fingerIndex, touchIndex))
					}
				}
				else{
					if isScrubbing == false && (timeElapsed...(timeElapsed + 0.05) ~= thisTouch!.timeInterval){
						indexes.append((fingerIndex, touchIndex))
					}
					else if isScrubbing == true && startTime...timeElapsed ~= thisTouch!.timeInterval{
						indexes.append((fingerIndex, touchIndex))
					}
				}
				if linesShown == 2 && thisTouch!.isPencil == false && indexes.count > 0{
					indexes.removeLast()
				}
				else if linesShown == 1 && thisTouch!.isPencil == true && indexes.count > 0{
					indexes.removeLast()
				}
			
			}
		}
		if isScrubbing == true || isolatedLines == true {
			fingerLineCounts = [0,0,0,0,0,0]
			timeElapsed -= 0.05
			setNeedsDisplay()//Need to do this to erase previous lines
		}
		processTouches(indexes: indexes)
	}
	
	
	
	//MARK: DELEGATE STUFF
	
	func toggleLineVisbility(withValue:Bool){
		linesVisible = withValue
		if withValue == true{
			self.alpha = 1.0
		}
		else{
			self.alpha = 0.0
		}
	}
	
	func toggleIsloatedLines(withValue:Bool){
		isolatedLines = withValue
		print("Isolating Lines:\(withValue)")
		pointsToDraw.removeAll()
		//self.setNeedsDisplay()
		prepareLinesToDraw()
	}
	func updatePencilColor(color: UIColor) {
		pencilLineColor = color
		setNeedsDisplay()
	}
	
	func updateFingerColor(color: UIColor) {
		fingerLineColor = color
		setNeedsDisplay()
	}
	
	func updateLinesDrawn(withValue: Int) {
		print("Updating Lines Drawn")
		linesShown = withValue
		pointsToDraw.removeAll()
		//self.setNeedsDisplay()
		prepareLinesToDraw()
	}
	
	func toggleStartEnd(withValue:Bool) {
		showStartEnd = withValue
		self.setNeedsDisplay()
		//prepareLinesToDraw()
	}
	
	func toggleLineSpeed(withValue:Bool) {
		showLineVelocity = withValue
		//pointsToDraw.removeAll()
		self.setNeedsDisplay()
		//prepareLinesToDraw()
	}
	
	
	
	func updateLineWidth(withValue: CGFloat) {
		strokeWidth = withValue
		//pointsToDraw.removeAll()
		self.setNeedsDisplay()
		prepareLinesToDraw()
	}
	
	func updateViewsAlpha(withValue: CGFloat) {
		playerDelegate?.updateViewsAlpha(withAlpha: withValue)
	}
	
	
	
	//MARK: EXPERIMENTAL
	func toggleShowAll(withValue:Bool) {
		isShowingAll = withValue
		if withValue == true{
			print("Setting all DataSets")
			pointsToDraw.removeAll()
			setupPlayerView()
			prepareLinesToDraw()
		}
		else{
			print("Setting single DataSet")
			pointsToDraw.removeAll()
			setupPlayerView()
			prepareLinesToDraw()
		}
	}
	
	//MARK: TIMER
	@objc func updateTimer(){
		//Show time elapsed in timer
		timeElapsed += TimeInterval(frameRate)
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		
		//Show in playback scrubber
		
		let totalTimeInterval = dataSet?.experiment?.totalDuration//dataSet?.endDate!.timeIntervalSince((dataSet?.startDate!)!)
		let sliderPercentage = timeElapsed/totalTimeInterval!
		playerDelegate?.updateSlider(valueAsPercentage: Float(sliderPercentage))
		
		//Do the thing to draw the line
		let currentTime = startTime + timeElapsed
		if currentTime < endTime{
			prepareLinesToDraw()
			playerDelegate!.updateViews(isPlaying:true)
		}
		else{
			timer.invalidate()
			playerDelegate!.updateViews(isPlaying:false)
			//timeElapsed = 0
		}
	}
	
	
	
	func tapButton(isPlaying:Bool){
		if isPlaying == true{
			let atEndTime = endTime - 0.05
			let endTimeString = String(format: "%.2f", atEndTime)
			let timeElapseString = String(format: "%.2f", timeElapsed)
			if timeElapseString == endTimeString || timeElapsed > atEndTime{
				print("Payhead at the end, resetting")
				playerDelegate?.updateSlider(valueAsPercentage: 0)
				timeElapsed = 0
				pointsToDraw.removeAll()
				setNeedsDisplay()
			}
			if timeElapsed == 0{
				fingerLineCounts = [0,0,0,0,0,0]
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
			let newTimer = Timer.scheduledTimer(timeInterval: TimeInterval(frameRate), target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
			RunLoop.current.add(newTimer, forMode: .common)
			timer.tolerance = 0.1
			self.timer = newTimer
		} else {
			timer.invalidate()
		}
	}
	
	

}
