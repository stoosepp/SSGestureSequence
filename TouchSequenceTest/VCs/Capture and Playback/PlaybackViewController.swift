//
//  PlaybackViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 5/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

class PlaybackViewController: UIViewController, MultiTouchPlayerViewDelegate  {
	
	//Views
	@IBOutlet weak var playbackView: MultiTouchPlayerView!
	
	var instructionTextView:UITextView?
	var imageView:UIImageView?
	
	//Buttons
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var cameraButton: UIButton!
	@IBOutlet weak var photosButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var slider: UISlider!
	
	//DataSet
	var dataSet:DataSet?
	var experiment:Experiment?
	var stimuli:[Stimulus]?
	var savedTouches = [[Touch?]?]()
	var currentOrientation:String?
	var currentIndex = 0

	//MARK: - VIEW LIFECYCLE
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.navigationBar.isHidden = true
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//print("ImageViewFrame:\(chosenImageView.frame)")
		playbackView.dataSet = dataSet!
		playbackView.playerDelegate = self
		
		updateSlider(valueAsPercentage: 1)
		if dataSet?.screenShots?.count != 0{
			photosButton.isHidden = false
		}
		experiment = dataSet?.experiment
		
		if experiment!.stimuli!.count != 0{
			print("There are now \(self.view.subviews.count) subviews")
			stimuli = fetchStimuli()
			print("there are \(stimuli!.count) stimuli")
			for index in 0..<stimuli!.count{
				setupStimuli(atIndex: index)
			}
			print("There are now \(self.view.subviews.count) subviews")
		}
		playbackView.setupPlayerView()
		
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	//MARK: - SETUP STIMULI
	
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
	
	func setupStimuli(atIndex:Int){
		let thisStimulus = stimuli![atIndex]
		let thisType = Int(thisStimulus.type)
		if thisType == StimulusType.kText{
			setupInstructionView(withText: thisStimulus.text)
		}
		else if thisType == StimulusType.kImage{
			setupImageView(forStimulus:thisStimulus)
		}
			//ELSE VIDEO
			//ELSE WEB VIEW
	}
	func setupInstructionView(withText:String?){
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.textColor = UIColor.label
		textView.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
		if withText != nil{
			textView.text = withText
		}
		self.view.addSubview(textView)
		self.view.sendSubviewToBack(textView)
		
		//Constraints
		let margins = self.view.layoutMarginsGuide
		textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
		textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 50).isActive = true
		textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -50).isActive = true
		textView.heightAnchor.constraint(equalToConstant: 300).isActive = true
		textView.isScrollEnabled = false
		textView.textAlignment = .center
		textView.isUserInteractionEnabled = false
		textView.isHidden = true
		
	}
	func setupImageView(forStimulus:Stimulus){
//		if imageView != nil{
//			imageView!.removeFromSuperview()
//			imageView!.image = nil
//		}
		let image = UIImage(data: forStimulus.imageData!)
		let newImageView = UIImageView()
		newImageView.image = image
		newImageView.frame = self.view.frame
		newImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
		newImageView.removeAllConstraints()
		self.view.addSubview(newImageView)
		self.view.sendSubviewToBack(newImageView)
		
		newImageView.center = CGPoint(x: CGFloat(forStimulus.xCenter), y: CGFloat(forStimulus.yCenter))
		var transform = CGAffineTransform.identity
		transform = transform.rotated(by:CGFloat(forStimulus.rotation))
		transform = transform.scaledBy(x:CGFloat(forStimulus.scale),y:CGFloat(forStimulus.scale))
		newImageView.transform = transform
		newImageView.isHidden = true
	
	}
	
	func showStimuli(atIndex:Int){
		let thisType = Int(stimuli![atIndex].type)
		print("Showing Stimulus with type \(thisType)")
		for view in self.view.subviews{
			
			if view.isKind(of: UIStackView.self) == false{//} || view.isKind(of: MultiTouchPlayerView.self) == false{
				view.isHidden = true
			}
			if view.isKind(of: MultiTouchPlayerView.self) == true{
				view.isHidden = false
			}
			if thisType == StimulusType.kText && view.isKind(of: UITextView.self) == true{
				view.isHidden = false
				print("Currently showing Text Instructions")
			}
			else if thisType == StimulusType.kImage && view.isKind(of: UIImageView.self) == true{
				view.isHidden = false
				print("Currently showing an Image")

			}
	
		}
	
	}
	/*
	func setupStimuli(experiment: Experiment) {
		//These two lines are key, otherwise the image doesn't show up correctly
		chosenImageView.frame = self.view.frame
		chosenImageView.removeAllConstraints()
		//Keep above two lines
		//Get Image and Load it
		let stimuliArray = experiment.stimuli?.allObjects
		let stimulus = stimuliArray![0] as! Stimulus
		chosenImageView.image = UIImage(data: stimulus.imageData!)
		
		var transform2 = CGAffineTransform.identity
	
		transform2 = transform2.rotated(by:CGFloat(stimulus.rotation))
		transform2 = transform2.scaledBy(x:CGFloat(stimulus.scale),y:CGFloat(stimulus.scale))
		self.chosenImageView.transform = transform2//transformation.concatenating(scale)
		self.chosenImageView.center = CGPoint(x: CGFloat(stimulus.xCenter), y: CGFloat(stimulus.yCenter))
		print("Transform: \(chosenImageView.transform)")
		print("Scale:\(stimulus.scale) Rotation:\(stimulus.rotation) Center:\(stimulus.xCenter),\(stimulus.yCenter)")
	}
*/
	
	//MARK: - PLAYING AND PAUSING
	@IBAction func playPauseButtonPushed(_ sender:UIButton){
		if sender.image(for: .normal) == UIImage(systemName: "play.fill"){
			sender.setImage((UIImage(systemName: "pause.fill")), for: .normal)
			playbackView.isScrubbing = false
			playbackView.tapButton(isPlaying:true)
		}
		else{
			sender.setImage((UIImage(systemName: "play.fill")), for: .normal)
			playbackView.tapButton(isPlaying:false)
		}
	}
	
	@IBAction func sliderDragged(_ sender: UISlider) {
		//Stop the timer and set the button to play again
		if playbackView.timer.isValid == true{
			playbackView.timer.invalidate()
			playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
		playbackView.pointsToDraw.removeAll()
		
		//setTime Elapsed
		let totalTimeInterval = Float(playbackView.endTime)
		playbackView.timeElapsed = TimeInterval(totalTimeInterval*sender.value)
		playbackView.timeIntervalLabel!.text = playbackView.timeElapsed.stringFromTimeInterval(withFrameRate: 0.05)
		playbackView.isScrubbing = true
		playbackView.prepareLinesToDraw()
		updateViews(isPlaying: false)
	}
	
	//MARK: - DELEGATE STUFF
	//TouchPlayerDelegate Funcs
	func updateViews(isPlaying: Bool) {
		if isPlaying == false{
			playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
		//Show Appropriate Stimulus for duration
		let thisIndex = getStimuliIndexFrom(duration: playbackView.timeElapsed)
		if thisIndex != currentIndex{
			currentIndex = thisIndex
			showStimuli(atIndex: currentIndex)
		}
		
	}
	func getStimuliIndexFrom(duration:TimeInterval) -> Int{
		var finalIndex = 0
		var thisDuration:Float = 0
		var nextDuration:Float = 0
		for index in 0..<stimuli!.count{
			if index == 0{
				thisDuration = 0
				nextDuration = stimuli![index].duration
			}
			else{
				thisDuration = nextDuration
				nextDuration = stimuli![index].duration + thisDuration
			}
			if duration.isBetween(time1: Double(thisDuration), time2: Double(nextDuration)) == true{
				finalIndex = index
				break
			}
		}
		return finalIndex
	}
	
	func updateSlider(valueAsPercentage: Float) {
		let sliderMax = slider.maximumValue
		let currentValue = valueAsPercentage * sliderMax
		slider.value = currentValue
	}
	func updateImageAlpha(withAlpha:CGFloat){
		if imageView != nil{
			imageView!.alpha = withAlpha
		}
	}
	
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	
	
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
		if segue.identifier == "showPlaybackSettingsSegue"{
			let settingsVC = segue.destination as! PlaybackSettingsViewController
			settingsVC.delegate = playbackView
			settingsVC.currentImageAlpha = Float(imageView!.alpha)
		}
		else if segue.identifier == "showScreenshotsSegue"{
			let imageCollectionVC = segue.destination as! ImageCollectionViewController
			imageCollectionVC.dataSet = dataSet
		}
		
		
    }
   
	
	//MARK: - TOGGLE STUFF
	@IBAction func toggleGestures(_ sender: UIButton) {
		if sender.image(for: .normal) == UIImage(systemName: "eye"){
			sender.setImage((UIImage(systemName: "eye.slash")), for: .normal)
			playbackView.alpha = 0
		}
		else{
			sender.setImage((UIImage(systemName: "eye")), for: .normal)
			playbackView.alpha = 1
		}
	}
	
	@IBAction func takePhoto(_ sender: Any) {
		//let dateString = Helpers().getTodayString()
		let image = self.view.takeScreenshot()
		let screenShot = CoreDataHelper.shared.createScreenShot(image)
		dataSet!.addToScreenShots(screenShot)
		let alert = UIAlertController(title: "Screenshot Taken", message: "View Screenshots in Gallery", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
		photosButton.isHidden = false
	}

}
