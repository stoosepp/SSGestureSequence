//
//  ViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 2017-01-12.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import AVKit

public protocol ImagePickerDelegate: class {
	func didSelect(image: UIImage?)
}

protocol ExperimentDetailsDelegate {
	func updateStimuliTable()
}

class CaptureViewController: UIViewController, RecordButtonDelegate, ImagePickerDelegate, TimerSelectDelegate, UIPopoverPresentationControllerDelegate {
	
	//Models
	var stimulus:Stimulus?
	var experiment:Experiment?
	var imageOrientation = 0
	
	//Stimuli Views
	var imageView:MovableImageView?
	var videoPlayer:AVPlayer?
	var webView:WKWebView?
	
	//Capture View
	@IBOutlet weak var captureView: MultiTouchCaptureView!//captureView!
	
	//Buttons
	@IBOutlet weak var editingStackView: UIStackView!
	@IBOutlet weak var importStackView: UIStackView!
	@IBOutlet weak var recordButton: RecordButton!
	@IBOutlet weak var durationButton: UIButton!
	
	var displayDuration:Int = 0
	
	//Other Stuff
	var expDetailsDelegate:ExpDetailsTableViewController?
	var imagePicker: ImagePicker!
	
	//MARK: VIEW LIFECYCLE
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view, typically from a nib.
		//Buttons
		if isEditing == true{
			recordButton.isHidden = true
			recordButton.delegate = self
			editingStackView.isHidden = true
			captureView.isHidden = true
			self.view.showBlankView(image: "rectangle.dashed", title: "Nothing Added yet", message: "Select an item above.")
		}
			
		//Start
		self.imagePicker = ImagePicker(presentationController: self, delegate: self)
	
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - NAVIGATION
	
	@IBAction func cancelPressed(_ sender:UIButton){
		self.dismiss(animated: true, completion: nil)
	}
	@IBAction func donePressed(_ sender:UIButton){
		if expDetailsDelegate != nil{
			saveImageTo(thisExperiment: experiment!)
			expDetailsDelegate!.updateStimuliTable()
		}
		self.dismiss(animated: true, completion: nil)
	}
	
	

	func deviceOrientation() -> String! {
		let device = UIDevice.current
		if device.isGeneratingDeviceOrientationNotifications {
		 device.beginGeneratingDeviceOrientationNotifications()
		 var deviceOrientation: String
		 let deviceOrientationRaw = device.orientation.rawValue
		 switch deviceOrientationRaw {
		 case 1:
			 deviceOrientation = "Portrait"
		 case 2:
			 deviceOrientation = "Upside Down"
		 case 3:
			 deviceOrientation = "Landscape Right"
		 case 4:
			 deviceOrientation = "Landscape Left"
		 case 5:
			 deviceOrientation = "Camera Facing Down"
		 case 6:
			 deviceOrientation = "Camera Facing Up"
		 default:
			 deviceOrientation = "Unknown"
		 }
		 return deviceOrientation
	 } else {
		 return nil
	 }
 }
	
	//MARK: - DELEGATE STUFF
	
	
	
	func setupExperiment(theExperiment: Experiment) {
		
		//get All Stimuli
		if theExperiment.dataSets!.count != 0 || theExperiment.stimuli!.count != 0{
			UIView.setAnimationsEnabled(false)
			if theExperiment.isLandscape == true{
				print("Setting to Landscape")
				if !deviceOrientation().contains("Landscape"){
					UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
				}
				AppUtility.lockOrientation(.landscape)
			}
			else if theExperiment.isLandscape == false{
				print("Setting to Portrait")
				if deviceOrientation().contains("Landscape"){
					UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
				}
				AppUtility.lockOrientation(.portrait)
			}
			UIView.setAnimationsEnabled(true)
		}
		else{
			AppUtility.lockOrientation(.all)
		}
		
		
		experiment = theExperiment
		if experiment!.showTouches == true{
			captureView.hideStrokes = false
		}
		print("There are \(experiment!.stimuli!.count) stimuli for this experiment")
		
		if experiment!.stimuli!.count != 0{
			setupStimuli()
		}

		recordButton.isHidden = false
		//FIXME: Rotate the orientation of the device to match the expriment
		
	}
	
	func resetImageView(){
	
		imageView!.removeFromSuperview()
		imageView!.image = nil
		let newImageView = MovableImageView()
		newImageView.frame = self.view.frame
		newImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
		self.view.addSubview(newImageView)
		self.view.sendSubviewToBack(newImageView)
		imageView = newImageView
	}
	
	func setupStimuli(){
		//Get Image and Load it
		let stimuliArray = experiment!.stimuli?.allObjects
		print("There are \(stimuliArray!.count) objects in stimuli")
		let stimulus = stimuliArray![0] as! Stimulus
		//imageView.frame = self.view.frame
		imageView!.removeAllConstraints()
		imageView!.image = UIImage(data: stimulus.imageData!)
		imageView!.center = CGPoint(x: CGFloat(stimulus.xCenter), y: CGFloat(stimulus.yCenter))
		var transform = CGAffineTransform.identity
		transform = transform.rotated(by:CGFloat(stimulus.rotation))
		transform = transform.scaledBy(x:CGFloat(stimulus.scale),y:CGFloat(stimulus.scale))
		self.imageView!.transform = transform
	}
	
	func updateExperimentList(withExperiment: Experiment) {
		experiment = withExperiment
	}
	
	//MARK: RECORD

	func tapButton(isRecording: Bool) {
		if isRecording {
			print("Started recording")
			animateButtons(withAlpa: 0)
			if imageView!.image == nil{
				imageView!.isHidden = true
			}
			captureView.isHidden = false
			//Start new DC Instance
			let newDataSet = CoreDataHelper.shared.createDataSet()
			newDataSet.startDate = Date()
			experiment!.addToDataSets(newDataSet)
			CoreDataHelper.shared.saveContext()
			captureView.dataSet = newDataSet

		} else {
			print("Stop recording")
			captureView.isUserInteractionEnabled = false
			//var touchArray = [Touch]()
	
			captureView.dataSet!.endDate = Date()
			CoreDataHelper.shared.saveContext()
			animateButtons(withAlpa: 1)
		}
	}
	
	
	//MARK: Animate Buttons
	func animateButtons(withAlpa:CGFloat){
		for view in self.view.subviews{
			UIView.animate(withDuration: 0.3) {
				if view.isKind(of: UIStackView.self){
					view.alpha = withAlpa
				}
			}
		}
	}
	
	override var shouldAutorotate: Bool {
			return false
		}
	
	
	
	//MARK:- STIMULI IMPORT
	//MARK: Image Import
	@IBAction func addImage(_ sender: UIButton) {
		self.imagePicker.present(from: sender)
	  }
	
	func didSelect(image: UIImage?) {
		//ImageView Exists
		if imageView != nil{
			imageView!.removeFromSuperview()
			imageView = nil
		}
		if image != nil{
			self.view.removeBlankView()
			imageOrientation = image!.imageOrientation.rawValue
	
			let newImageView = MovableImageView()
			newImageView.frame = captureView.frame
			newImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
			newImageView.image = image
			self.view.addSubview(newImageView)
			imageView = newImageView
			imageView!.removeAllConstraints()
			imageView!.enableZoom()
			imageView!.enablePan()
			editingStackView.isHidden = false
		}
		
	}
	
	
	@IBAction func toggleRotation(_ sender: UIButton) {
		if imageView!.gestureRecognizers!.count == 2{
			sender.backgroundColor = .systemGreen
			imageView!.enableRotate()
		}
		else {
			sender.backgroundColor = .systemRed
			let rotateRecognizer = imageView!.gestureRecognizers?[2]
			imageView!.removeGestureRecognizer(rotateRecognizer!)
		 
			let ivTransform = imageView!.transform
			let thisScale = ivTransform.scale
			//let radians:Float = -Float(atan2(Double(ivTransform.b), Double(ivTransform.a)) + .pi);
			let rotationTransform = CGAffineTransform(rotationAngle: 0)
			let scaleTransform = CGAffineTransform(scaleX: thisScale, y: thisScale)
			let finalTransform = rotationTransform.concatenating(scaleTransform)
			UIView.animate(withDuration: 0.3) {
				self.imageView!.transform = finalTransform
			}

		}
	}
	
	@IBAction func centerImage(_ sender:UIButton){
		print("Center Image")
		UIView.animate(withDuration: 0.3) {
			self.imageView!.center = self.view.center
		}
	}
	
	func saveImageTo(thisExperiment:Experiment) {
		
		imageView!.isUserInteractionEnabled = false
		
		//Get Details of image
		let ivTransform = imageView!.transform
		let thisScale = ivTransform.scale
		let centerX = imageView!.center.x
		let centerY = imageView!.center.y
		var radians:Float = Float(atan2(Double(ivTransform.b), Double(ivTransform.a)))
		if self.imageOrientation != 0{
			radians += .pi
		}
		let chosenImage = imageView!.image
		
		for view in self.view.subviews{
			if view.isKind(of: UIStackView.self){
				view.isHidden = true
			}
		}
		let screenshot = self.view.takeScreenshot()
		thisExperiment.imageData = screenshot.pngData()
		
		//Save the image and it's properties to the session for loading later
		let newStimulus = CoreDataHelper.shared.createStimulus(rotation: radians, scale: thisScale, xCenter: centerX, yCenter: centerY, image:chosenImage , url: nil)
	
		if deviceOrientation().contains("Landscape"){
			thisExperiment.isLandscape = true
		}
		CoreDataHelper.shared.saveContext()
		
		CoreDataHelper.shared.addStimulus(stimulus: newStimulus, experiment: thisExperiment)
		
		for view in self.view.subviews{
			if view.isKind(of: UIStackView.self){
				view.isHidden = false
			}
		}
		recordButton.isHidden = false
		editingStackView.isHidden = true
		stimulus = newStimulus
	}
	
	//MARK: - Add WebPage
	@IBAction func addVideo(_ sender:UIButton){
		let ac = UIAlertController(title: "Add a Video", message: "Coming Soon", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(ac, animated: true)
	}
	
	@IBAction func addWebPage(_ sender:UIButton){
		let ac = UIAlertController(title: "Add a Webpage", message: "Coming Soon", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(ac, animated: true)
	}
	
	//MARK:- SET DURATION
	func updateDuration(withMins:Int, seconds:Int){
		displayDuration = (withMins * 60) + seconds//this is in Seconds
		durationButton.setTitle("\(withMins)m \(seconds)s", for: .normal)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDurationSegue"{
			let timerVC = segue.destination as! TimerSelectViewController
			timerVC.popoverPresentationController!.delegate = self
			timerVC.delegate = self
		}
	}
	public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
			return false
		}
	
	
	
}






