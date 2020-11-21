//
//  Helpers.swift
//  ImageSelectTest
//
//  Created by Stoo on 17/9/20.
//  Copyright © 2020 Stoo. All rights reserved.
//

import UIKit

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
	

	
	//MARK: Core Graphics
	func distance(a: CGPoint, b: CGPoint) -> CGFloat {
			let xDist = a.x - b.x
			let yDist = a.y - b.y
			return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
		}
}
