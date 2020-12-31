//
//  HeatMapView.swift
//  TouchSequenceTest
//
//  Created by Stoo on 23/12/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

typealias CompletionHandler = (_ success:Bool) -> Void

class HeatMapView: UIView {
	
	var gridSize = 4
	var maxTouchCount:Int = 0
	var minTouchCount:Int = 1
	var gridsArray = [(id:Int, touchCount:Int, rect:CGRect)]()
	var heatMapColour:HeatMapColour?
	var colours = [UIColor]()
	var clearBG:Bool = true

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
//	override init(parentView:UIView, withSize:Int,touches:[Touch]){
//		setupGrid(forView: parentView, withSize: 20, withTouches: touchArray)
//		}
	
	init(frame: CGRect, gradientCount:Int) {
		super.init(frame: frame)
		heatMapColour = HeatMapColour(gradientCount: gradientCount)
		colours = heatMapColour!.sortedColours()
	   }
	/*
    override func draw(_ rect: CGRect) {
        // Drawing code
		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}
	
		for grid in gridsArray{
			// Set the rectangle outerline-colour
			let normalizedValue = getNormalizedValue(value: grid.touchCount, max: maxTouchCount, min: minTouchCount)
			print("Normalized: \(normalizedValue)")
			let color = colours.intermediate(percentage: normalizedValue * 100)
			let thisRect = grid.rect
			context.setFillColor(color.cgColor)
			context.fill(thisRect)
			
		}
    }
	*/
	func getNormalizedValue(value:Int, max:Int, min:Int) -> CGFloat{
		let updatedValue = ( value == min) ? (value + 1) : value
		return abs(CGFloat(updatedValue - min) / CGFloat(max - min))
	}
	

	
	func setupMap(forView:UIView, withSize:Int, withGradientCount:Int, withTouches:[Touch],completionHandler: @escaping CompletionHandler) {
		var index = 0
		var densityCountArray = [Int]()
		//print("W:\(forView.frame.size.width),H:\(forView.frame.size.height)")
		
		for x in stride(from: 0, to: forView.frame.width, by: CGFloat(withSize)) {
			for y in stride(from: 0, to: forView.frame.height, by: CGFloat(withSize)) {
				let newRect = CGRect(x: x, y: y, width: CGFloat(withSize), height: CGFloat(withSize))
				let densityCount = getTouchCountFor(rect: newRect, fromTouchArray: withTouches)
				let newGridItem = (id:index, touchCount:densityCount,rect:newRect)
				gridsArray.append(newGridItem)
				index += 1
				//print("X:\(x),Y:\(y)")
				if densityCount > 0{
					densityCountArray.append(densityCount)
				}
				if y >= forView.frame.size.height-CGFloat(withSize) && x >= forView.frame.size.width-CGFloat(withSize){
					print("We at the end with \(densityCountArray.count) items in Density Array")
					maxTouchCount = densityCountArray.max()!
					minTouchCount = densityCountArray.min()!
					//let median = Helpers.shared.calculateMedian(array: densityCountArray)
					completionHandler(true)
				}
			}
		}
		//completionHandler(false)
		
		
		//print("Median:\(median) Max: \(maxTouchCount), Min:\(minTouchCount)")
		
	}
	
	func getTouchCountFor(rect:CGRect, fromTouchArray:[Touch]) -> Int{
		var density = 0
		
		for  touch in fromTouchArray {
			var point = CGPoint()
			point.x = CGFloat(touch.xLocation)
			point.y = CGFloat(touch.yLocation)
			if rect.contains(point){
				density += 1
			}
		}
		return density
	}
//MARK: - UPDATED STUFF
	
	override func draw(_ rect: CGRect) {
		
		let sortedGrids = gridsArray.sorted(by: { $0.touchCount < $1.touchCount })
		backgroundColor = .clear
		for grid in sortedGrids{
			let thisRect = grid.rect
			let center = CGPoint(x: (thisRect.origin.x + thisRect.width/2), y: (thisRect.origin.y + thisRect.height/2))
			let normalizedValue = self.getNormalizedValue(value: grid.touchCount, max: self.maxTouchCount, min: self.minTouchCount)
			let thisColor = self.colours.intermediate(percentage: normalizedValue * 100)
			//update radius to focus on the increased density
			
			
			if clearBG == true && grid.touchCount > 0{
				self.drawPoint(point:center, color: thisColor, radius: thisRect.width/1.5)
			}
			else if clearBG == false{
				self.drawPoint(point:center, color: thisColor, radius: thisRect.width/1.5)
			}
		
		
		}
	}
	
	func drawPoint(point: CGPoint, color: UIColor, radius: CGFloat) {
		let ovalPath = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
		color.setFill()
		ovalPath.fill()
	}
	/*
	
	
	func roundThis(number: Double, toNearest:Int) -> Int {
		return toNearest * Int(round( number / Double(toNearest)))
	}
	
	func setupMap(forView:UIView, withSize:Int, withGradientCount:Int, withTouches:[Touch],completionHandler: @escaping CompletionHandler) {
		var index:Int = 0
		var success = false
		self.backgroundColor = .clear//colours[0]

		let theWidth = roundThis(number: Double(forView.frame.size.width), toNearest: Int(withSize))
		let newWidth =  CGFloat(theWidth) < forView.frame.size.width ? theWidth + Int(withSize) : theWidth
		let theHeight = roundThis(number: Double(forView.frame.size.height), toNearest: Int(withSize))
		let newHeight =  CGFloat(theHeight) < forView.frame.size.height ? theHeight + Int(withSize) : theHeight
		let rowCount = (theWidth / withSize)
		let columnCont = (theHeight / withSize)
		let boxCount = rowCount*columnCont
		print("Total Box Count:\(rowCount)x\(columnCont)=\(boxCount) on a canvas of \(theWidth),\(theHeight)")
		
		let startDate = Date()
		for x in stride(from: 0, to: theWidth, by: withSize) {
			for y in stride(from: 0, to: theHeight, by: withSize) {
				index += 1
				let newRect = CGRect(x: x, y: y, width: withSize, height: withSize)
				//let touchesInRect = self.getTouchCountFor(rect: newRect, fromTouchArray: withTouches)
			
				let newGridItem = GridItem(row: Int(x), column: Int(y), touchCount: 0, rect: newRect)
				self.gridsArray.append(newGridItem)
				let endDate = Date()
				let difference = endDate.timeIntervalSince(startDate)
				
				print(String(format:"Box \(index)/\(boxCount) at \(x),\(y) created after %.2f s",difference))
				if index == boxCount{
						
					print("We're done!")
					completionHandler(true)
					success = true
					self.processDensity(forGrids: self.gridsArray, andTouches: withTouches)
				}
			}
		}
	}
	
	func processDensity(forGrids:[GridItem], andTouches:[Touch]){
		let startDate = Date()
		let concurrentQueue = DispatchQueue(label: "swiftlee.concurrent.queue", attributes: .concurrent)
		var counter = 0
		for index in 0..<gridsArray.count{
			//concurrentQueue.async {
				let touchesInRect = self.getTouchCountFor(rect: self.gridsArray[index].rect, fromTouchArray: andTouches)
				self.gridsArray[index].touchCount = touchesInRect
				if self.maxTouchCount < touchesInRect{
					self.maxTouchCount = touchesInRect
				}
				counter += 1
				if counter == self.gridsArray.count{
					print("Counter:\(counter) Count:\(self.gridsArray.count)")
					let endDate = Date()
					let difference = endDate.timeIntervalSince(startDate)
					print(String(format:"Touches Processed in %.2f s",difference))
					self.setNeedsDisplay()
				}
			//}
		
		}
	
		
	}
	

	
	func getTouchCountFor(rect:CGRect, fromTouchArray:[Touch]) -> Int{
		var touchCount = 0
		
		for  touch in fromTouchArray {
			var point = CGPoint()
			point.x = CGFloat(touch.xLocation)
			point.y = CGFloat(touch.yLocation)
			if rect.contains(point){
				touchCount += 1
			}
		}
		return touchCount
	}
	
	*/
    

}
