//
//  ViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 2017-01-12.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit
import CoreData

public protocol ImagePickerDelegate: class {
	func didSelect(image: UIImage?)
}

class CaptureViewController: UIViewController, UpgradeViewDelegate, RecordButtonDelegate, ImagePickerDelegate, UISplitViewControllerDelegate, ExpSessionsListDelegate, UIPopoverPresentationControllerDelegate {
	
	//Models
	var experiment:Experiment?
	var participant:Participant?
	var stimulus:Stimulus?
	
	//Views
	@IBOutlet weak var chosenImageView: MovableImageView!
	@IBOutlet weak var captureView: MultiTouchCaptureView!//captureView!
	
	//Buttons for Everyone
	@IBOutlet weak var startingStackView: UIStackView!
	@IBOutlet weak var imageEditingStackView: UIStackView!
	@IBOutlet weak var recordButton: RecordButton!
	@IBOutlet weak var settingsButton: RoundedButton!
	@IBOutlet weak var playButton: RoundedButton!
	
	@IBOutlet weak var settingsLabel: UILabel!
	
	@IBOutlet weak var titleLabel:UILabel!
	
	//Buttons for Pro
	@IBOutlet weak var splitViewButton: UIButton!
	
	var imagePicker: ImagePicker!
	
	//MARK: VIEW LIFECYCLE
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.isHidden = true
		self.splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.secondaryOnly
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		recordButton.delegate = self
	}

	
    override func viewDidLoad() {
        super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationController?.toolbar.clipsToBounds = true;
		
		//Buttons
		recordButton.isHidden = true
		playButton.isHidden = true
		imageEditingStackView.isHidden = true
		
		//Views
		captureView.isHidden = true
		settingsLabel.text = "Touch Lines: Visible\nTimer:Off"
	
		self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		
		//Deal with Pro stuf
		Core.shared.setDidUpgrade(value: false)
		setupApp(didUpgrade: true)
		
    }


	func setupApp(didUpgrade:Bool){
		//Edit this if testing pro features
		if didUpgrade == true
		{
			splitViewButton.isHidden = false
			self.title = "Touch Capture Pro"
		}
		else{
			splitViewButton.isHidden = true
		}
		//Update TableView
		
		//Deal with CoreDataSet
		if fetchExperiments().count == 0{
			print("There are no sessions")
			//Create Exp Session
			CoreDataHelper.shared.startupBasic()
			let nav = splitViewController?.viewController(for: .supplementary)
			let expVC = nav?.children[0] as! ExpSessionsTableViewController
			expVC.fetchSessions()
		}
		if experiment == nil{
			experiment = fetchExperiments().last!
		}
		
		titleLabel.text = "Experiment: \(experiment!.title!)"
	}
	
	func setupExperiment(experiment: Experiment) {
		titleLabel.text = "Experiment: \(experiment.title!)"
		
		//Get Image and Load it
		let stimuliArray = experiment.stimuli?.allObjects
		let stimulus = stimuliArray![0] as! Stimulus
		
		//If the images is on the screen, send it back to normal.
		if chosenImageView.image != nil{
			//Put imageview back to normal
			self.chosenImageView.center.y = self.view.center.y + UIApplication.statusBarHeight
			self.chosenImageView.center.x = self.view.center.x
			let transformation1 =  CGAffineTransform(rotationAngle: 0)
			let scale1 = CGAffineTransform(scaleX: 1, y: 1)
			self.chosenImageView.transform = transformation1.concatenating(scale1)
	  
			//Set Image with stimulus details
			chosenImageView.image = UIImage(data: stimulus.imageData!)
			self.chosenImageView.center = CGPoint(x: CGFloat(stimulus.xCenter), y: CGFloat(stimulus.yCenter))
			let transformation2 =  CGAffineTransform(rotationAngle: CGFloat(stimulus.rotation))
			let scale2 = CGAffineTransform(scaleX: CGFloat(stimulus.scale), y: CGFloat(stimulus.scale))
			self.chosenImageView.transform = transformation2.concatenating(scale2)
			//print("Scale i\(chosenImageView.transform.scale)")
		}
		else{
			//print("There's no image! Loading the file")
			chosenImageView.image = UIImage(data: stimulus.imageData!)
			self.chosenImageView.removeAllConstraints()
			let transformation =  CGAffineTransform(rotationAngle: CGFloat(stimulus.rotation))
			let scale = CGAffineTransform(scaleX: CGFloat(stimulus.scale), y: CGFloat(stimulus.scale))
			self.chosenImageView.transform = transformation.concatenating(scale)
			self.chosenImageView.center = CGPoint(x: CGFloat(stimulus.xCenter), y: CGFloat(stimulus.yCenter))
		}
	}
	
	func fetchExperiments() -> [Experiment]{
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		var experiments = [Experiment]()
		do {
			experiments = try context.fetch(Experiment.fetchRequest()) as! [Experiment]
	}
		catch{
			print("Error fetching Experiments")
		}
		return experiments
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showUpgradeToPro"{
			let upgradeVC = segue.destination as! UpgradeViewController
			upgradeVC.upgradeDelegate = self
		}
		else if segue.identifier == "showPlaybackSegue"{
			let playbackVC = segue.destination as! PlaybackViewController
			playbackVC.dataSet = captureView.dataSet
		}
		/*
		else if segue.identifier == "chooseExperimentSegue"{
			print("Showing Exp Sessions List")
			let expSessionsVC = segue.destination as! ExpSessionsTableViewController
			expSessionsVC.captureDelegate = self
		}*/
	}
	
	func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
		self.splitViewController?.preferredDisplayMode = .secondaryOnly
		UIView.animate(withDuration: 0.5) {
			self.splitViewController?.preferredDisplayMode = .automatic
		}
		return UISplitViewController.DisplayMode.automatic
	}
	
	@IBAction func toggleMaster(){
		//show maste
		self.splitViewController?.preferredDisplayMode = self.targetDisplayModeForAction(in: self.splitViewController!)
	}
	
	@IBAction func viewPlayback(){
		performSegue(withIdentifier: "showPlaybackSegue", sender: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func chooseExpSession(_ sender:UIButton) {
		let popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "ExpSessionsTVC"))! as! ExpSessionsTableViewController
		let nav = UINavigationController(rootViewController: popoverContent)
		nav.modalPresentationStyle = UIModalPresentationStyle.pageSheet
		popoverContent.title = "Choose an Experiment"
		popoverContent.captureDelegate = self
		self.present(nav, animated: true, completion: nil)

	}
	
	//MARK: RECORD AND PLAYBACK
	@IBAction func newRecordingFromStack(_ sender:UIButton){
		recordButton.isHidden = false
		startingStackView.isHidden = true
		chosenImageView.isHidden = true
	}

	func tapButton(isRecording: Bool) {

			if isRecording {
				print("Started recording")
				if chosenImageView.image == nil{
					chosenImageView.isHidden = true
				}
				captureView.isHidden = false
				//Start new DC Instance
				let newDataSet = CoreDataHelper.shared.createDataSet()
				newDataSet.startDate = Date()
				experiment!.addToDataSets(newDataSet)
				CoreDataHelper.shared.save(experiment!)
				CoreDataHelper.shared.save(newDataSet)
				captureView.dataSet = newDataSet
				
			} else {
				print("Stop recording")
				captureView.isUserInteractionEnabled = false
				playButton.isHidden = false
				//var touchArray = [Touch]()
		
				captureView.dataSet!.endDate = Date()
				CoreDataHelper.shared.save(captureView.dataSet!)
			}
		}
	
	//MARK: NEW RECORDING (RESET)
	@IBAction func newRecording(){
		if chosenImageView.image != nil{
			chosenImageView.removeFromSuperview()
			let newImageView = MovableImageView()
			newImageView.frame = self.view.frame
			newImageView.contentMode = .scaleAspectFit
			self.view.addSubview(newImageView)
			self.view.sendSubviewToBack(newImageView)
			chosenImageView = newImageView
			startingStackView.isHidden = false
		}
		recordButton.isHidden = true
		captureView.resetView()

	}
	
	
	
	//MARK: IMAGE IMPORT
	
	@IBAction func chooseImage(_ sender: UIButton) {
		  //resetTransforms(forView: imageView, transformType: "all", value: 0)
		  self.imagePicker.present(from: sender)
		
	  }
	
	func didSelect(image: UIImage?) {
		//Buttons
		if image != nil{
			startingStackView.isHidden = true
			self.chosenImageView.image = image
			print("Image Chosen")
			imageEditingStackView.isHidden = false
			//importPhotoButton.isHidden = true
			chosenImageView.isHidden = false
			chosenImageView.removeAllConstraints()
			chosenImageView.enableZoom()
			chosenImageView.enablePan()
		}
		
	}
	
	
	@IBAction func toggleRotation(_ sender: UIButton) {
		if chosenImageView.gestureRecognizers!.count == 2{
			print("Unlocking Rotation")
			sender.backgroundColor = .systemGreen
			chosenImageView.enableRotate()
		}
		else {
			print("Locking Rotation")
			sender.backgroundColor = .systemRed
			let rotateRecognizer = chosenImageView.gestureRecognizers?[2]
			chosenImageView.removeGestureRecognizer(rotateRecognizer!)
		
			let rotationTransform = CGAffineTransform(rotationAngle: 0.0)
			let scale:CGFloat = chosenImageView.transform.a
			let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
			//chosenImageView.transform = CGAffineTransform(translationX: 0, y: 0)
			let finalTransform = rotationTransform.concatenating(scaleTransform)
			chosenImageView.transform = finalTransform
		}
	}
	
	@IBAction func confirmImage(_ sender: UIButton) {
		recordButton.isHidden = false
		chosenImageView.isUserInteractionEnabled = false
		imageEditingStackView.isHidden = true
		//Get Details of image
		let ivTransform = chosenImageView.transform
		let thisScale = ivTransform.scale
		let centerX = chosenImageView.center.x
		let centerY = chosenImageView.center.y
		let radians:Float = Float(atan2f(Float(CGFloat(ivTransform.b)), Float(CGFloat(ivTransform.a))));
		
		//Save the image and it's properties to the session for loading later
		stimulus = CoreDataHelper.shared.createStimulus(rotation: radians, scale: thisScale, xCenter: centerX, yCenter: centerY, image: chosenImageView.image, url: nil)
		if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
		 // Use interfaceOrientation
			experiment!.isLandscape = interfaceOrientation.isLandscape
			CoreDataHelper.shared.save(experiment!)
			if experiment!.isLandscape{
				let value = UIInterfaceOrientation.landscapeRight.rawValue
				UIDevice.current.setValue(value, forKey: "orientation")
			}
			
		}
	
		CoreDataHelper.shared.addStimulus(stimulus: stimulus!, experiment: experiment!)
		
	}
	
	//MARK: Animate Buttons
	func animateButtons(buttons:[UIButton], toShow:Bool){
		for button in buttons{
			UIView.animate(withDuration: 0.3) {
				if toShow == true{
					button.center.y -= 100
				
				}
				else{
					button.center.y += 100
				}
			}
		}
	}
	
	override var shouldAutorotate: Bool {
			return false
		}
}






