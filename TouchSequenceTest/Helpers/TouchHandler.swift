//
//  TouchHandler.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData


public class TouchHandler{
	
	static let shared = TouchHandler()
	
	func convertfromUITouch(_ touch:UITouch, inView:UIView) -> Touch{
		let newTouch = Touch(context: CoreDataHelper.shared.context)
		newTouch.timeStamp = Date()
		let location = touch.location(in: inView)
		newTouch.xLocation = Float(location.x)
		newTouch.yLocation = Float(location.y)
		newTouch.touchType = Int64(Int(touch.phase.rawValue))
		
		return newTouch
	}
}
