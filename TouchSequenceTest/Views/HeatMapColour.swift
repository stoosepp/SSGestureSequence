//
//  HeatMapColour.swift
//  TouchSequenceTest
//
//  Created by Stoo on 22/12/20.
//  Copyright © 2020 StooSepp. All rights reserved.
// Adapted from http://www.andrewnoske.com/wiki/Code_-_heatmaps_and_color_gradients

import Foundation
import UIKit

struct ColourPoint {
	let color: UIColor
	let value: CGFloat
}

 public class HeatMapColour {

	
	var colourPoints: [ColourPoint]

	init(theseColourPoints: [ColourPoint]) {
		colourPoints = theseColourPoints
	}
	
	init(gradientCount: Int) {
		var tempColors = [ColourPoint]()

		let black = ColourPoint.init(color: UIColor.black, value: 1)
		let blue = ColourPoint.init(color: UIColor.blue, value: 2)
		let cyan = ColourPoint.init(color: UIColor.cyan, value: 3)
		let green = ColourPoint.init(color: UIColor.green, value: 4)
		let yellow = ColourPoint.init(color: UIColor.yellow, value: 5)
		let red = ColourPoint.init(color: UIColor.red, value: 6)
		let white = ColourPoint.init(color: UIColor.white, value: 7)
		if gradientCount == 0{
			tempColors.append(black)
			tempColors.append(white)
		}
		else{
			if gradientCount >= 2{
				tempColors.append(blue)
				tempColors.append(red)
			}
			if gradientCount >= 5{
				tempColors.append(cyan)
				tempColors.append(green)
				tempColors.append(yellow)
			}
			if gradientCount == 7{
				tempColors.append(black)
				tempColors.append(white)
			}
		}
		colourPoints = tempColors
	}
	
	
	func sortedColours() -> [UIColor]{
		let sortedColours = colourPoints.sorted(by: { $0.value < $1.value })
		var sortedArray = [UIColor]()
		for colour in sortedColours{
			sortedArray.append(colour.color)
		}
		return sortedArray
	}
	func getColor(densityValue:CGFloat) -> UIColor{
		var finalColour = UIColor()
		let sortedColours = colourPoints.sorted(by: { $0.value < $1.value })
		//Check if the Density Value is between certain Colours.
		for index in 0..<sortedColours.count {
			let thisColourValue  = index + 1
			let percentage = densityValue - CGFloat(thisColourValue)
			if index < sortedColours.count{
				finalColour = sortedColours[index].color.toColor(sortedColours[index].color, percentage: percentage)
			}
			
		}
		return finalColour
	}

	
}
