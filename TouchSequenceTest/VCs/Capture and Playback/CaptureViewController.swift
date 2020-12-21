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
import JGProgressHUD

public protocol ImagePickerDelegate: class {
	func didSelect(image: UIImage?)
}

protocol ExperimentDetailsDelegate {
	func updateStimuliTable()
}

//protocol DataSetListDelegate {
//	func updateDataSetList()
//}
struct CaptureStatus{
	//Static Vars
	static let kAddingStimuli = "addStimuli"
	static let kPreview = "preview"
	static let kCollecting = "collectData"
}

class CaptureViewController: UIViewController, ImagePickerDelegate, TimerSelectDelegate, MultiTouchCaptureViewDelegate, UIPopoverPresentationControllerDelegate, UITextViewDelegate {

	var status = ""
	
	//Models
	var stimuliArray = [Stimulus]()
	var experiment:Experiment?
	var imageOrientation = 0
	
	//Stimuli Views
	var instructionTextView:UITextView?
	var imageView:MovableImageView?
	var videoPlayer:AVPlayer?
	var webView:WKWebView?
	
	//Capture View
	@IBOutlet weak var captureView: MultiTouchCaptureView!//captureView!
	
	//Buttons
	@IBOutlet weak var adminStackView: UIStackView!
	@IBOutlet weak var editingStackView: UIStackView!
	@IBOutlet weak var importStackView: UIStackView!
	@IBOutlet weak var durationButton: UIButton!
	
	var totalDuration:Int = 0
	var stimulusBeingAdded = 0
	
	//Other Stuff
	var dataSetListDelegate:DataSetsCollectionViewController?
	var expDetailsDelegate:ExpDetailsTableViewController?
	var imagePicker: ImagePicker!
	
	//MARK: - VIEW LIFECYCLE
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view, typically from a nib.
		
		//Buttons
		if status == CaptureStatus.kAddingStimuli{
			editingStackView.isHidden = true
			captureView.isHidden = true
			self.view.showBlankView(image: "rectangle.dashed", title: "Nothing Added yet", message: "Select an item above.")
			self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		}
		else{

			captureView.frameRate = 1.0
			adminStackView.isHidden = true
			importStackView.isHidden = true
			editingStackView.isHidden = true
			captureView.timeIntervalLabel!.text = ""
			//Setup Stimuli and Start Playing
			setupExperiment()
			if status == CaptureStatus.kPreview{
				
			}
			else if status == CaptureStatus.kCollecting{
				
			}
		}
    }
	override var prefersStatusBarHidden: Bool {
		return true
	}
	

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	//MARK: SETUP ROTATION
	override var shouldAutorotate: Bool {
			return false
		}
	
	//MARK: - NAVIGATION
	
	@IBAction func cancelPressed(_ sender:UIButton){
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func donePressed(_ sender:UIButton){
		if totalDuration != 0 && expDetailsDelegate != nil{
			switch stimulusBeingAdded {
			case StimulusType.kText:
				print("Adding text instructions")
				saveTextTo(thisExperiment: experiment!)
			case StimulusType.kImage:
				saveImageTo(thisExperiment: experiment!)//Saved here
			case StimulusType.kVideo:
				print("Adding videos")
			case StimulusType.kWebView:
				print("Adding Web Page")
			default:
				print("Adding Nothing")
			}
			//Update Delegate
			
			expDetailsDelegate!.updateStimuliTable()
			self.dismiss(animated: true, completion: nil)
		}
		else{
			let ac = UIAlertController(title: "No Duration", message: "Set a duration for how long this stimulus will appear.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(ac, animated: true)
		}
		
	}


	
	//MARK: - SETUP EXPERIMENT
	func setupExperiment() {
		let hud = JGProgressHUD()
		hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
		hud.textLabel.text = "Setting up..."
		hud.show(in: self.view)
		//Show touches
		if experiment!.showTouches == true{
			captureView.alpha = 1.0
		}
		else{
			captureView.alpha = 0.0
		}
		
		captureView.experimentDuration = experiment!.totalDuration
		captureView.captureDelegate = self
		//Record Audio
		
		//Show Timer
		if experiment!.showTime == false{
			captureView.timeIntervalLabel?.isHidden = true
		}
		
		//Set all and Add them to the Screen
		stimuliArray = fetchStimuli()
		print("There are \(stimuliArray.count) Stimuli to show")
		hud.dismiss()
		startExperiment()
	}
	
	func startExperiment(){
		//Add Countdown
		if experiment!.countDown != 0{
			
			setupCountDown { (completion) in
				if completion == true{
					self.captureView.startTimer()
					self.showStimuli()
					self.createDataSet()
				}
			}
		}
		else{
			self.captureView.startTimer()
			self.showStimuli()
			createDataSet()
		}
		
	
	}
	func createDataSet(){
		//Create New DataSet
		let newDataSet = CoreDataHelper.shared.createDataSet()
		newDataSet.startDate = Date()
		experiment!.addToDataSets(newDataSet)
		CoreDataHelper.shared.saveContext()
		captureView.dataSet = newDataSet
	}
	
	func setupCountDown(withCompletion:@escaping (Bool)->()){
		var countdownSeconds = 0
		if experiment!.countDown == 1{
			countdownSeconds = 3
		}
		else if experiment!.countDown == 2{
			countdownSeconds = 5
		}
		Helpers.shared.countdown(fromSeconds: countdownSeconds, forView: self.view) { (completion) in
			var didComplete = false
			//setupStimuli()
			if completion == true{
				print("end reached")
				didComplete = true
			}
			else{
				print("Still Counting Down...")
				didComplete = false
			}
			withCompletion(didComplete)
		}
	}
	
	func fetchStimuli() -> [Stimulus]{
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		var tempArray = [Stimulus]()
		do {
			var fetchRequest:NSFetchRequest<Stimulus>?
			fetchRequest = Stimulus.fetchRequest()
			if experiment != nil{
				fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(Stimulus.experiment), experiment!)
			}
			tempArray = try context.fetch(fetchRequest!)
			tempArray.sort {
				$0.order < $1.order
			}
		}
		catch{
			print("There was an error")
		}
		return tempArray
	}
	
	
	func showStimuli(){
		print("Setting up Stimuli")
		var delay:TimeInterval = 0
		for index in 0..<stimuliArray.count{
			let thisStimulus = stimuliArray[index]
			if delay == 0{
				//Present First Stimuli
				show(thisStimulus: thisStimulus)
				captureView.currentStimulus = thisStimulus
				delay += TimeInterval(thisStimulus.duration)
			}
			else{
				//Prsesent Other Stimulis
				DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
					self.show(thisStimulus: thisStimulus)
					
				}
				delay += TimeInterval(thisStimulus.duration)
			}
		}
	}
	
	
	func show(thisStimulus:Stimulus){
		//Set Capture view Stimulus
		captureView.currentStimulus = thisStimulus
		
		//Remove StackView
		for view in self.view.subviews{
			if view.isKind(of: UIStackView.self){
				view.removeFromSuperview()
			}
			if view.isKind(of: UITextView.self){
				view.removeFromSuperview()
			}
			if view.isKind(of: UIImageView.self){
				view.removeFromSuperview()
			}
		}
		
		//Show different Types
		switch Int(thisStimulus.type) {
		case StimulusType.kBlank://Image
			print("Showing Blank")
			//setupImageView()
		case StimulusType.kText://Image
			print("Showing Text: \(thisStimulus.text!)")
			//setupText
			addInstructionView(withText: thisStimulus.text)
			instructionTextView?.isUserInteractionEnabled = false
		case StimulusType.kImage://Image
			if instructionTextView != nil{
				instructionTextView?.removeFromSuperview()
			}
			print("Showing Image")
			setupImageView()
			imageView!.removeAllConstraints()
			imageView!.image = UIImage(data: thisStimulus.imageData!)
			imageView!.center = CGPoint(x: CGFloat(thisStimulus.xCenter), y: CGFloat(thisStimulus.yCenter))
			var transform = CGAffineTransform.identity
			transform = transform.rotated(by:CGFloat(thisStimulus.rotation))
			transform = transform.scaledBy(x:CGFloat(thisStimulus.scale),y:CGFloat(thisStimulus.scale))
			self.imageView!.transform = transform
		case StimulusType.kVideo://Video
			print("Showing Video")
			if instructionTextView != nil{
				instructionTextView?.removeFromSuperview()
			}
		case StimulusType.kWebView://WebPage
			print("Showing WebPage")
			if instructionTextView != nil{
				instructionTextView?.removeFromSuperview()
			}
		default:
			print("No Stimulus Type Defined")
		}
	
	}
	//MARK: - FINISH DATA COLLECTION
	func completeDataCollection() {
		print("Data Collection Completed. Dismissing")
		//Set end time for Data Collection
		//Take ScreenShot
		captureView.alpha = 1.0
		let image = self.view.takeScreenshot()
		DispatchQueue.global(qos: .background).async {
			
			let screenShot = CoreDataHelper.shared.createScreenShot(image)
			self.captureView.dataSet!.addToScreenShots(screenShot)
			//Dismiss
			//self.captureView.removeFromSuperview()
			let currentDataSet = self.captureView.dataSet
			if self.status == CaptureStatus.kPreview{
				print("Deleting DataSet")
				CoreDataHelper.shared.delete(currentDataSet!)
			}
			else if self.status == CaptureStatus.kCollecting{
				currentDataSet!.endDate = Date()
			}
			CoreDataHelper.shared.saveContext()
		}
		
		
		showCompletionAlert()
		//Update Data Collectionview
	}
	func showCompletionAlert(){
		let alert = UIAlertController(title: "You're Done.", message: "Give the device back to the researcher or facilitator.", preferredStyle: .alert)

		//alert.addTextField(configurationHandler: configurationTextField)

		alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ [self] (UIAlertAction)in
			self.dismiss(animated: true, completion: nil)
			dataSetListDelegate?.updateDataSetListWith(thisExperiment: self.experiment!)
			//print(self.textField.text)
		}))

		self.present(alert, animated: true, completion: {
			print("completion block")
		})
	}

	func configurationTextField(textField: UITextField!){
		textField.text = "Filename"
	}
	
	//MARK: RECORD

	

	//MARK:- STIMULI IMPORT
	
	//MARK: Text Import
	@IBAction func addText(_ sender:UIButton){
		stimulusBeingAdded = StimulusType.kText
		self.view.removeBlankView()
		addInstructionView(withText: nil)
		instructionTextView!.delegate = self
		instructionTextView!.becomeFirstResponder()
	}
	
	func addInstructionView(withText:String?){
		instructionTextView = UITextView()
		instructionTextView!.translatesAutoresizingMaskIntoConstraints = false
		instructionTextView!.textColor = UIColor.label
		instructionTextView!.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
		if withText != nil{
			instructionTextView!.text = withText
		}
		self.view.addSubview(instructionTextView!)
		self.view.sendSubviewToBack(instructionTextView!)
		
		//Constraints
		let margins = self.view.layoutMarginsGuide
		instructionTextView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		instructionTextView!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
		instructionTextView!.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 50).isActive = true
		instructionTextView!.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -50).isActive = true
		instructionTextView!.heightAnchor.constraint(equalToConstant: 300).isActive = true
		instructionTextView!.isScrollEnabled = false
		instructionTextView!.textAlignment = .center
		
	}
	
	func saveTextTo(thisExperiment:Experiment) {

		let newStimulus = Stimulus(context: CoreDataHelper.shared.context)
		newStimulus.type = Int16(StimulusType.kText)//Set as Image
		
		newStimulus.text = instructionTextView!.text
		
		let stimulusCount = thisExperiment.stimuli?.count
		newStimulus.order = Int16(stimulusCount!)
	
		newStimulus.duration = Float(totalDuration)
	
		
		if thisExperiment.orientation == "Not Set"{
			print("This is the first stimulus. Setting Orientation")
			let isLandscape = Helpers.shared.deviceOrientationIsLandscape()
			if isLandscape == true{
				thisExperiment.orientation = "Landscape"
			}
			else{
				thisExperiment.orientation = "Portrait"
			}
		}
		thisExperiment.addToStimuli(newStimulus)
		newStimulus.experiment = thisExperiment
		CoreDataHelper.shared.saveContext()

	}
	
	//MARK: Image Import
	@IBAction func addImage(_ sender: UIButton) {
		stimulusBeingAdded = StimulusType.kImage
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
			self.view.sendSubviewToBack(newImageView)
			imageView = newImageView
			imageView!.removeAllConstraints()
			
			imageView!.enableZoom()
			imageView!.enablePan()
			editingStackView.isHidden = false
		}
		
	}

	func setupImageView(){
		if imageView != nil{
			imageView!.removeFromSuperview()
			imageView!.image = nil
		}
	
		let newImageView = MovableImageView()
		newImageView.frame = self.view.frame
		newImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
		
		self.view.addSubview(newImageView)
		self.view.sendSubviewToBack(newImageView)
		imageView = newImageView
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
		
		for view in self.view.subviews{
			if view.isKind(of: UIStackView.self){
				view.isHidden = true
			}
		}
		
		imageView!.isUserInteractionEnabled = false
		
		let newStimulus = Stimulus(context: CoreDataHelper.shared.context)
		newStimulus.type = Int16(StimulusType.kImage)//Set as Image
		
		//Save Details of image
		let ivTransform = imageView!.transform
		let thisScale = ivTransform.scale
		newStimulus.scale = Float(thisScale)
		
		let centerX = imageView!.center.x
		let centerY = imageView!.center.y
		newStimulus.xCenter = Float(centerX)
		newStimulus.yCenter = Float(centerY)
		
		var radians:Float = Float(atan2(Double(ivTransform.b), Double(ivTransform.a)))
		newStimulus.rotation = radians
		
		if self.imageOrientation != 0{
			radians += .pi
		}
		if let theChosenimage = imageView?.image{
			newStimulus.imageData = theChosenimage.pngData() //screenshot.pngData()
		}
		
		let stimulusCount = thisExperiment.stimuli?.count
		newStimulus.order = Int16(stimulusCount!)
	
		newStimulus.duration = Float(totalDuration)
		//let screenshot = self.view.takeScreenshot()
		
		if thisExperiment.orientation == "Not Set"{
			print("This is the first stimulus. Setting Orientation")
			let isLandscape = Helpers.shared.deviceOrientationIsLandscape()
			if isLandscape == true{
				thisExperiment.orientation = "Landscape"
			}
			else{
				thisExperiment.orientation = "Portrait"
			}
		}
		thisExperiment.addToStimuli(newStimulus)
		newStimulus.experiment = thisExperiment
		CoreDataHelper.shared.saveContext()
		for view in self.view.subviews{
			if view.isKind(of: UIStackView.self){
				view.isHidden = false
			}
		}
		editingStackView.isHidden = true
	}
	
	//MARK: - Add WebPage
	@IBAction func addVideo(_ sender:UIButton){
		stimulusBeingAdded = StimulusType.kVideo
		let ac = UIAlertController(title: "Add a Video", message: "Coming Soon", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(ac, animated: true)
	}
	
	@IBAction func addWebPage(_ sender:UIButton){
		stimulusBeingAdded = StimulusType.kWebView
		let ac = UIAlertController(title: "Add a Webpage", message: "Coming Soon", preferredStyle: .actionSheet)
		ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(ac, animated: true)
	}
	
	//MARK:- SET DURATION
	func updateDuration(withMins:Int, seconds:Int){
		totalDuration = (withMins * 60) + seconds//this is in Seconds
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






