//
//  TimerSelectViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 11/11/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol TimerSelectDelegate {
	func updateDuration(withMins:Int, seconds:Int)
}

class TimerSelectViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		pickerView.delegate = self
	}

	@IBOutlet var pickerView: UIPickerView!
	
	var delegate:Any?
	
	//var hour: Int = 0
	var minutes: Int = 0
	var seconds: Int = 0
	
	@IBAction func confirmPressed(_ sender:UIButton){
		if minutes == 0 && seconds == 0{
			self.view.shake(times: 3, direction: .Horizontal)
		}
		else{
			if delegate is CaptureViewController{
				let captureDelegate = delegate as! CaptureViewController
				captureDelegate.updateDuration(withMins:minutes, seconds:seconds)
			}
			else if delegate is ExpDetailsTableViewController{
				let expDetailsDelegate = delegate as! ExpDetailsTableViewController
				expDetailsDelegate.updateDuration(withMins:minutes, seconds:seconds)
			}
			self.dismiss(animated: true, completion: nil)
		}
	
	}
	
	@IBAction func cancelPressed(_ sender:UIButton){
		self.dismiss(animated: true, completion: nil)
	}
}

	 extension TimerSelectViewController: UIPickerViewDelegate, UIPickerViewDataSource {

		 func numberOfComponents(in pickerView: UIPickerView) -> Int {
			 return 2
		 }

		 func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
			var rows = 0
			if delegate is CaptureViewController{
				switch component {
				case 0:
					rows = 6
				case 1:
					rows = 12
				default:
					rows = 0
				}
			}
			else if delegate is ExpDetailsTableViewController{
				switch component {
				case 0:
					rows = 2
				case 1:
					rows = 59
				default:
					rows = 0
				}
			}
			return rows
			
		 }

		 func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
			 return pickerView.frame.size.width/2
		 }

		 func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
			var string = ""
			switch component {
			case 0:
				string =  "\(row) min"
			case 1:
				if delegate is ExpDetailsTableViewController{
					string =  "\(row) sec"
				}
				else{
					string =  "\(row * 5) sec"
				}
				
			default:
				string =  ""
			}
			return string
			
		 }
		 func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
			 switch component {
			 case 0:
				 minutes = row
			 case 1:
				if delegate is ExpDetailsTableViewController{
					seconds = row
				}
				else{
					seconds = row * 5
				}
				 
			 default:
				 break;
			 }
	
			
		 }
		
	 }
