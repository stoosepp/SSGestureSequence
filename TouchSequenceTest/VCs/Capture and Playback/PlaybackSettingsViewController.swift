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
	func updateImageAlpha(withValue:CGFloat)
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
	@IBOutlet var linesToDrawSegmentedControl:UISegmentedControl!
	@IBOutlet var speedSwitch:UISwitch!
	@IBOutlet var showAllSwitch:UISwitch!
	@IBOutlet var startEndSwitch:UISwitch!
	@IBOutlet var lineWidthLabel:UILabel!
	@IBOutlet var lineWidthStepper:UIStepper!
	@IBOutlet var alphaSlider:UISlider!
	
	var currentImageAlpha:Float = 1.0
	var delegate:MultiTouchPlayerView?
	var colorUpdating:String?
	

    override func viewDidLoad() {
        super.viewDidLoad()
		//FIXME: DYNAMIC CONTENT SIZE BASED ON WHAT IS VISIBLE
		self.preferredContentSize.height = 600
		
		fingerButton.backgroundColor = delegate?.fingerLineColor
		pencilButton.backgroundColor = delegate?.pencilLineColor
		startEndSwitch.isOn = delegate!.showStartEnd
		showAllSwitch.isOn = delegate!.isShowingAll
		
		alphaSlider.value = currentImageAlpha
		linesToDrawSegmentedControl.selectedSegmentIndex = delegate!.linesShown
		lineWidthLabel.text = "Line Width: \(String(describing: delegate?.strokeWidth))"
		lineWidthStepper.value = Double(delegate!.strokeWidth)
		
		fingerButton.strokeColor = UIColor.white.cgColor
		pencilButton.strokeColor = UIColor.white.cgColor
		
		
    }
	

	@IBAction func toggleLinesDisplayed(_ sender: UISegmentedControl) {
		print("Drawing: \(sender.selectedSegmentIndex)")
		delegate!.updateLinesDrawn(withValue:sender.selectedSegmentIndex)
		//delegate!.setNeedsDisplay()
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
	
	@IBAction func updateLineWidth(_ sender: UIStepper) {
		delegate?.updateLineWidth(withValue: CGFloat(sender.value))
		lineWidthLabel.text = "Line Width: \(sender.value)"
	}
	
	@IBAction func updateImageAlpha(_ sender: UISlider) {
		delegate?.updateImageAlpha(withValue: CGFloat(sender.value))
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
		picker.modalPresentationStyle = .currentContext
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


