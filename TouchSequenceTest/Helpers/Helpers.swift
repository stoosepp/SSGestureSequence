//
//  Helpers.swift
//  ImageSelectTest
//
//  Created by Stoo on 17/9/20.
//  Copyright © 2020 Stoo. All rights reserved.
//

import UIKit
import JGProgressHUD

open class Helpers:NSObject{
	
	static let shared = Helpers()
    
    //MARK: Number Conversions
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    func toCGFloat(string:String)-> CGFloat{
          if let double = Double(string) {
              return CGFloat(double)
          } else {
              return CGFloat(0.0)
          }
      }
    
    //MARK: Date Conversions
    
    func getTodayString() -> String{

        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second

        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)

        return today_string
    }
	
	func calculateMedian(array: [Int]) -> Float {
		let sorted = array.sorted()
		if sorted.count % 2 == 0 {
			return Float((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
		} else {
			return Float(sorted[(sorted.count - 1) / 2])
		}
	}
	
	

	
	//MARK: Core Graphics
	func distance(a: CGPoint, b: CGPoint) -> CGFloat {
			let xDist = a.x - b.x
			let yDist = a.y - b.y
			return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
		}
	
	func countdown(fromSeconds:Int, forView:UIView, completion: @escaping(Bool) -> ()){
		let hud = JGProgressHUD()
		hud.indicatorView = nil
		hud.textLabel.text = "\(fromSeconds)"
		hud.textLabel.font = UIFont(name:"HelveticaNeue" , size: 300)
		hud.show(in: forView)
		hud.dismiss(afterDelay: TimeInterval(fromSeconds))
		for counter in 0...fromSeconds{
			print("Counter:\(counter)")
			
			DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(counter + 1)) { // Change `2.0` to the desired number of seconds.
			   // Code you want to be delayed
				if counter == fromSeconds-1{//We've reached the end
					hud.textLabel.text = ""
					completion(true)
				}
				else{
					hud.textLabel.text = "\(fromSeconds - (counter + 1))"
				}
			}
			completion(false)
		}
	}
	
	func deviceOrientationIsLandscape() -> Bool! {
		let device = UIDevice.current
		if device.isGeneratingDeviceOrientationNotifications
		{
			device.beginGeneratingDeviceOrientationNotifications()
			var isLandScape: Bool = true
			if device.orientation.isPortrait{
				isLandScape = false
			}
			else if device.orientation.isLandscape{
				isLandScape = true
			}
			 return isLandScape
		 } else {
			 return nil
		 }
	}
}
