//
//  PlaybackSettingsTableViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 4/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol PlaybackSettingsDelegate{
	func updatePencilColor(color:UIColor)
	func updateFingerColor(color:UIColor)
	func toggleStartEnd(withValue:Bool)
	func toggleLineSpeed(withValue:Bool)
	func updateLinesDrawn(withValue:Int)
	func updateLineWidth(withValue:CGFloat)
	func updateViewsAlpha(withValue:CGFloat)
	func toggleShowAll(withValue:Bool)
}

struct PlaybackStruct{
	static let kFingerColor = "fingerColor" //tag 1
	static let  kPencilColor = "pencilColor" //tag 2
}

class PlaybackSettingsViewController: UIViewController, UIColorPickerViewControllerDelegate {
	
	//Color Buttons
	@IBOutlet var fingerButton:RoundedButton!
	@IBOutlet var pencilButton:RoundedButton!
	
	//Segmented Control
	@IBOutlet var linesToDrawSegmentedControl:UISegmentedControl!
	
	//Switches
	@IBOutlet var showHideSwitch:UISwitch!
	@IBOutlet var isolatedLinesSwitch:UISwitch!
	@IBOutlet var startEndSwitch:UISwitch!
	@IBOutlet var speedSwitch:UISwitch!
	
	//Change Line Width
	@IBOutlet var lineWidthLabel:UILabel!
	@IBOutlet var lineWidthStepper:UIStepper!
	
	//Change opacity of Stimuli
	@IBOutlet var alphaSlider:UISlider!
	
	var currentAlpha:Float = 1.0
	var delegate:MultiTouchPlayerView?
	var colorUpdating:String?
	

    override func viewDidLoad() {
        super.viewDidLoad()
		self.preferredContentSize.height = 600
		
		fingerButton.backgroundColor = delegate?.fingerLineColor
		pencilButton.backgroundColor = delegate?.pencilLineColor
		startEndSwitch.isOn = delegate!.showStartEnd
		showHideSwitch.isOn = delegate!.linesVisible
		isolatedLinesSwitch.isOn = delegate!.isolatedLines
		
		alphaSlider.value = currentAlpha
		linesToDrawSegmentedControl.selectedSegmentIndex = delegate!.linesShown
		lineWidthLabel.text = "Line Width: \(String(describing: delegate!.strokeWidth))"
		lineWidthStepper.value = Double(delegate!.strokeWidth)
		
		fingerButton.strokeColor = UIColor.white.cgColor
		pencilButton.strokeColor = UIColor.white.cgColor
		
		//print(self.preferredContentSize)
		
		var dynamicHeight:CGFloat = 0
		for view in self.view.subviews{
			dynamicHeight += view.frame.size.height
		}
		self.preferredContentSize.height = dynamicHeight
    }
	
	@IBAction func toggleLineVisibility(_ sender: UISwitch) {
		delegate?.toggleLineVisbility(withValue: sender.isOn)
	}

	@IBAction func toggleLinesForStimuli(_ sender: UISwitch) {
		delegate?.toggleIsloatedLines(withValue: sender.isOn)
	}
	
	@IBAction func toggleLineSpeed(_ sender: UISwitch) {
		//Update Drawing through Delegate
		delegate?.toggleLineSpeed(withValue: sender.isOn)
	}
	
	@IBAction func toggleShowAll(_ sender: UISwitch) {
		delegate?.toggleShowAll(withValue: sender.isOn)
	}
	
	@IBAction func toggleStartEnd(_ sender: UISwitch) {
		delegate?.toggleStartEnd(withValue: sender.isOn)
	}
	
	@IBAction func toggleLinesDisplayed(_ sender: UISegmentedControl) {
		print("Drawing: \(sender.selectedSegmentIndex)")
		delegate!.updateLinesDrawn(withValue:sender.selectedSegmentIndex)
		//delegate!.setNeedsDisplay()
	}
	
	@IBAction func updateLineWidth(_ sender: UIStepper) {
		delegate?.updateLineWidth(withValue: CGFloat(sender.value))
		lineWidthLabel.text = "Line Width: \(sender.value)"
	}
	
	@IBAction func updateViewsAlpha(_ sender: UISlider) {
		delegate?.updateViewsAlpha(withValue: CGFloat(sender.value))
	}
	
	//MARK: Color Picker Stuff
	@IBAction func colorPressed(_ sender:UIButton){
		if sender.tag == 1{
			//Changing FingerColor
			pickColor(forColor: PlaybackStruct.kFingerColor, withSender: sender)
			
		}
		else if sender.tag == 2{
			//Changing PencilColor
			pickColor(forColor: PlaybackStruct.kPencilColor, withSender: sender)
		}
	}
	
	func pickColor(forColor:String, withSender:UIButton){
		colorUpdating = forColor
		let picker = UIColorPickerViewController()
		picker.modalPresentationStyle = .formSheet
		picker.delegate = self
		picker.selectedColor = withSender.backgroundColor!
		present(picker, animated: true, completion: nil)
	}
	
	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
			dismiss(animated: true, completion: nil)
	}

	func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
			let color = viewController.selectedColor
		if colorUpdating == PlaybackStruct.kFingerColor{
			fingerButton.backgroundColor = color
			delegate?.updateFingerColor(color: color)
		}
		else if colorUpdating == PlaybackStruct.kPencilColor{
			pencilButton.backgroundColor = color
			delegate?.updatePencilColor(color: color)
		}
	}
	

	


   

}


