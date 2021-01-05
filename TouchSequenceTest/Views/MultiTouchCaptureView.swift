//
//  MultiTouchCaptureView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 26/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol MultiTouchCaptureViewDelegate {
	func completeDataCollection()
	func setupStimuli()
}

class MultiTouchCaptureView: TouchCoreView {
	
	//Multitouch
	var fingers = [UITouch?](repeating: nil, count:6)
	var experimentDuration:Double = 0.0
	
	@IBOutlet var timeIntervalLabel:UILabel?
	
	var captureDelegate:CaptureViewController?
	var currentStimulus:Stimulus?
	//MARK: Drawing Code
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		resetView()
	}
	
	func resetView(){
		//check to see if the view should hide lines
		//let experiment = dataSet?.experiment
		
	
		toPoint = CGPoint.zero
		fromPoint = CGPoint.zero
		//currentRect = CGRect.zero
		if savedTouches.count != 0{
			savedTouches.removeAll()
			pointsToDraw.removeAll()
		}
		for _ in 0..<5 {
			let newTouchArray = [Touch]()
			savedTouches.append(newTouchArray)
		}
		setNeedsDisplay()
	}
	func startTimer(){
		let newTimer = Timer.scheduledTimer(timeInterval: TimeInterval(frameRate), target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
		RunLoop.current.add(newTimer, forMode: .common)
		timer.tolerance = 0.1
		self.timer = newTimer
		
	}
	
	@objc func updateTimer(){
		//Show time elapsed in timer
		timeElapsed += TimeInterval(frameRate)
		timeIntervalLabel!.text = timeElapsed.stringFromTimeInterval(withFrameRate: frameRate)
		captureDelegate!.setupStimuli()
		if timeElapsed > experimentDuration{
			timer.invalidate()
			captureDelegate!.completeDataCollection()
		}
	}
	

	//MARK: Capturing Touches
	//Multitouch

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		var indexes = [(Int,Int)]()
		for touch in touches{
			//let point = touch.location(in: self)
			for (index,finger)  in fingers.enumerated() {
				print("There are now \(index+1) fingers on screen")
				if finger == nil {
					fingers[index] = touch
					let pencilBool = getPencil(inTouch: touch)
					let convertedTouch = CoreDataHelper.shared.createTouchfromUITouchWith(dataSet:dataSet!, stimulus:currentStimulus!, touch:touch, finger: Int64(index), isPencil: pencilBool, inView: self)
					savedTouches[index].append(convertedTouch)
					dataSet!.addToTouches(convertedTouch)
					CoreDataHelper.shared.saveContext()
					
					let indexOfLastTouch = savedTouches[index].count - 1
					indexes.append((index,indexOfLastTouch))
					break
				}
			}
		}
		processTouches(indexes: indexes)
		
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		var indexes = [(Int,Int)]()
		for touch in touches {
			//let point = touch.location(in: self)
			for (index,finger) in fingers.enumerated(){
				if let finger = finger, finger == touch {
					self.fingers[index] = touch
					//Deal with Touches
					let pencilBool = getPencil(inTouch: touch)
					let convertedTouch = CoreDataHelper.shared.createTouchfromUITouchWith(dataSet:dataSet!, stimulus:currentStimulus!, touch:touch, finger: Int64(index), isPencil: pencilBool, inView: self)
					dataSet!.addToTouches(convertedTouch)
					CoreDataHelper.shared.saveContext()
					savedTouches[index].append(convertedTouch)
					let indexOfLastTouch = savedTouches[index].count - 1
		
					indexes.append((index,indexOfLastTouch))
					break
				}
			}
		}
		processTouches(indexes: indexes)
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		var indexes = [(Int,Int)]()
		for touch in touches {
			for (index,finger) in fingers.enumerated() {
				if let finger = finger, finger == touch {
					fingers[index] = nil
					//self.fingers[index] = touch
					//Deal with Touches
					let pencilBool = getPencil(inTouch: touch)
					let convertedTouch = CoreDataHelper.shared.createTouchfromUITouchWith(dataSet:dataSet!, stimulus:currentStimulus!, touch:touch, finger: Int64(index), isPencil: pencilBool, inView: self)
					dataSet!.addToTouches(convertedTouch)
					CoreDataHelper.shared.saveContext()
					savedTouches[index].append(convertedTouch)
					
					let indexOfLastTouch = savedTouches[index].count - 1
					indexes.append((index,indexOfLastTouch))
					break
				}
			}
		}
		processTouches(indexes: indexes)
		
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		touchesEnded(touches, with: event)
	}

	func getPencil(inTouch:UITouch) -> Bool{
		var isPencil = false
		if inTouch.azimuthAngle(in: self) != 0.0{
			isPencil = true
		}
		return isPencil
	}
}
