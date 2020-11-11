//
//  TimePicker.swift
//  TouchSequenceTest
//
//  Created by Stoo on 14/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class TimePicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

	
	var hour:Int = 0
	var minute:Int = 0
	var second:Int = 0

//
//	override init() {
//		super.init()
//		self.setup()
//	}
//
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setup()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}

	func setup(){
		self.delegate = self
		self.dataSource = self

		let height = CGFloat(20)
		let offsetX = self.frame.size.width / 3
		let offsetY = self.frame.size.height/2 - height/2
		let marginX = CGFloat(42)
		let width = offsetX - marginX

		let hourLabel = UILabel(frame: CGRect(x: marginX, y: offsetY, width: width, height: height))
		hourLabel.text = "min"
		self.addSubview(hourLabel)

		let minsLabel = UILabel(frame: CGRect(x: marginX + offsetX, y: offsetY, width: width, height: height))
		minsLabel.text = "sec"
		self.addSubview(minsLabel)
	}

	func getDate() -> Date{
		let dateFormatter = DateFormatter()
		//dateFormatter.dateFormat = "HH:mm"
		dateFormatter.dateFormat = "mm:ss"
		let date = dateFormatter.date(from: String(format: "%02d", self.minute) + ":" + String(format: "%02d", self.second))
		return date!
	}

	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}

	private func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch component {
		case 0:
			self.minute = row
		case 1:
			self.second = row
		default:
			print("No component with number \(component)")
		}
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if component == 0 {
			return 60
		}

		return 60
	}

	private func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 30
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return "Hello"
	}
	

}
