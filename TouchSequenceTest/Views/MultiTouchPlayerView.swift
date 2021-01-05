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
	func updateViewsAlpha(withAlpha:CGFloat)
	func setupHeatMaps()
	func checkIndex()
}

class MultiTouchPlayerView: TouchCoreView, PlaybackSettingsDelegate {
	
	@IBOutlet var timeIntervalLabel:UILabel?
	var playerDelegate:PlaybackViewController?
	

	//Viewing Options
	var isScrubbing:Bool = false
	var isShowingAll:Bool = false
	var touchesSeparatedbyStimuli:Bool = false
	var linesVisible:Bool = true
	
	//CoreData Stuff
	var dataSets:[DataSet]?
	
	//MARK: - DRAWING CODE
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func setupPlayerView(){
		savedTouches = parseDataSet(dataSet: dataSet!)
		timeElapsed = endTime
		isScrubbing = true
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		playerDelegate?.slider.value = 1
		prepareLinesToDraw()
	}
	
	func parseDataSet(dataSet :DataSet) -> [[Touch]]{
		//Sets in swift are not ordered, so we need to sort the DataSet by timestamp
		let touchArray = (dataSet.touches as! Set<Touch>).sorted(by: { $0.timeInterval < $1.timeInterval })
		endTime = (dataSet.endDate?.timeIntervalSince(dataSet.startDate!))!
		
		let fingersDict = Dictionary(grouping:touchArray){$0.finger}
		var fingerArrays = [[Touch]]()
		for (_,value) in fingersDict{
			fingerArrays.append(value)
		}
		return fingerArrays
	}
	

	
	
	//MARK: -  PROCESS LINES
	public func prepareLinesToDraw(){
		//print("Lines to draw fire")
//		let touchCore = TouchCoreViewController()
//		let stimuliArray = dataSet?.experiment?.stimuli?.allObjects as! [Stimulus]
//		let indexForTimeElapsed = touchCore.getStimuliIndexFrom(duration: timeElapsed, forStimuli:stimuliArray)
//		currentStimulusStartTime = touchCore.getDurationFrom(stimulusIndex: indexForTimeElapsed, inStimulusArray: stimuliArray)
		print("Preparing to Draw Lines")
		var indexes = [(Int,Int)]()
		for (fingerIndex,touchArray) in savedTouches.enumerated(){
			for (touchIndex,thisTouch) in touchArray.enumerated(){
				if touchesSeparatedbyStimuli == true{
					if currentStimulusStartTime...timeElapsed ~= thisTouch.timeInterval{
						indexes.append((fingerIndex, touchIndex))
						//break
					}
				}
				else{
					if isScrubbing == false && (timeElapsed...(timeElapsed + 0.05) ~= thisTouch.timeInterval){
						indexes.append((fingerIndex, touchIndex))
					}
					else if isScrubbing == true && startTime...timeElapsed ~= thisTouch.timeInterval{
						indexes.append((fingerIndex, touchIndex))
					}
				}
				if linesShown == 2 && thisTouch.isPencil == false && indexes.count > 0{
					indexes.removeLast()
				}
				else if linesShown == 1 && thisTouch.isPencil == true && indexes.count > 0{
					indexes.removeLast()
				}
		
			}
		}
		if isScrubbing == true || touchesSeparatedbyStimuli == true {
			fingerLineCounts = [0,0,0,0,0,0]
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
		touchesSeparatedbyStimuli = withValue
		if linesVisible == true{
			pointsToDraw.removeAll()
			prepareLinesToDraw()
		}
		if playerDelegate!.isShowingAnalysis == true{
			playerDelegate!.setupHeatMaps()
		}
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
		if linesVisible == true{
			pointsToDraw.removeAll()
			prepareLinesToDraw()
		}
	}
	
	func toggleStartEnd(withValue:Bool) {
		showStartEnd = withValue
		self.setNeedsDisplay()

	}
	
	func toggleLineSpeed(withValue:Bool) {
		showLineVelocity = withValue
		self.setNeedsDisplay()

	}
	
	
	
	func updateLineWidth(withValue: CGFloat) {
		strokeWidth = withValue
		self.setNeedsDisplay()
		//prepareLinesToDraw()
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
			pointsToDraw.removeAll()
			prepareLinesToDraw()
		}
		else{
			print("Setting single DataSet")
			pointsToDraw.removeAll()
			setupPlayerView()
			pointsToDraw.removeAll()
			prepareLinesToDraw()
		}
	}
	
	//MARK: TIMER
	@objc func fireEvent(){
		//Show time elapsed in timer
		playerDelegate!.checkIndex()
		timeElapsed += TimeInterval(frameRate)
		timeIntervalLabel!.text = String(format: "Timer: %.2f", timeElapsed)
		
		//Show in playback scrubber
		let totalTimeInterval = dataSet?.experiment?.totalDuration//dataSet?.endDate!.timeIntervalSince((dataSet?.startDate!)!)
		let sliderPercentage = timeElapsed/totalTimeInterval!
		playerDelegate?.updateSlider(valueAsPercentage: Float(sliderPercentage))
		
		//Do the thing to draw the line
		let currentTime = startTime + timeElapsed
		
		if currentTime < endTime{
			//print("Timer Firing. C:\(currentTime) E:\(endTime)")
			if linesVisible == true{
				pointsToDraw.removeAll()
				prepareLinesToDraw()
			}
		}
		else{
			print("Invalidating Timer")
			timer.invalidate()
		}
	}
	
	
	
	func tapButton(isPlaying:Bool){
		isScrubbing = false
		if isPlaying == true{
			print("Starting Playback")
			let currentTime = startTime + timeElapsed
			if currentTime >= endTime{
				playerDelegate?.updateSlider(valueAsPercentage: 0)
				timeElapsed = 0
				pointsToDraw.removeAll()
				setNeedsDisplay()
			}
			//deal with when the scrubbers at the end
			timer.invalidate()
			let newTimer = Timer.scheduledTimer(timeInterval: TimeInterval(frameRate), target: self, selector: #selector(fireEvent), userInfo: nil, repeats: true)
			RunLoop.current.add(newTimer, forMode: .common)
			timer.tolerance = 0.1
			self.timer = newTimer
		
			if timeElapsed == 0{
				fingerLineCounts = [0,0,0,0,0,0]
				toPoint = CGPoint.zero
				fromPoint = CGPoint.zero
				pointsToDraw.removeAll()
				setNeedsDisplay()
			}
		} else {
			print("Pausing Playback")
			timer.invalidate()
		}
	}
}
