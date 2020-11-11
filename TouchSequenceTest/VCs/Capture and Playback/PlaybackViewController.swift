//
//  PlaybackViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 5/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class PlaybackViewController: UIViewController, MultiTouchPlayerViewDelegate  {
	
	//Views
	@IBOutlet weak var chosenImageView: MovableImageView!
	@IBOutlet weak var playbackView: MultiTouchPlayerView!
	
	//Buttons
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var cameraButton: UIButton!
	@IBOutlet weak var photosButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var slider: UISlider!
	
	//DataSet
	var dataSet:DataSet?
	var savedTouches = [[Touch?]?]()
	var currentOrientation:String?

	//MARK: - VIEW LIFECYCLE
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.navigationBar.isHidden = true
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		//print("ImageViewFrame:\(chosenImageView.frame)")
		print("Dataset:\(String(describing: dataSet))")
		playbackView.dataSet = dataSet!
		playbackView.playerDelegate = self
		
		updateSlider(valueAsPercentage: 1)
		if dataSet?.screenShots?.count != 0{
			photosButton.isHidden = false
		}
		
		if let theExperiment = dataSet?.experiment!{
			if theExperiment.stimuli!.count != 0{
				setupStimuli(experiment: theExperiment)
			}
			if theExperiment.dataSets!.count != 0 || theExperiment.stimuli!.count != 0{
				//UIView.setAnimationsEnabled(false)
				if theExperiment.isLandscape == true{
					print("Setting to Landscape")
					//if !currentOrientation!.contains("Landscape"){
						//UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
					//}
					
					//AppUtility.lockOrientation(.landscape)
				}
				else if theExperiment.isLandscape == false{
					print("Setting to Portrait")
					if currentOrientation!.contains("Landscape"){
						UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
					}
					
					//AppUtility.lockOrientation(.portrait)
					
				}
				//UIView.setAnimationsEnabled(true)
			}
			
			
		}
		playbackView.setupPlayerView()
		
    }
	//MARK: - SETUP STIMULI
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
		playbackView.timeIntervalLabel!.text = String(format: "Timer: %.2f", playbackView.timeElapsed)
		playbackView.isScrubbing = true
		playbackView.prepareLinesToDraw()
		
	}
	
	//MARK: - DELEGATE STUFF
	//TouchPlayerDelegate Funcs
	func updateViews(isPlaying: Bool) {
		if isPlaying == false{
			playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
	}
	
	func updateSlider(valueAsPercentage: Float) {
		let sliderMax = slider.maximumValue
		let currentValue = valueAsPercentage * sliderMax
		slider.value = currentValue
	}
	func updateImageAlpha(withAlpha:CGFloat){
		chosenImageView.alpha = withAlpha
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
			settingsVC.currentImageAlpha = Float(chosenImageView.alpha)
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
		CoreDataHelper.shared.addScreenShot(screenShot: screenShot, dataSet: dataSet!)
		let alert = UIAlertController(title: "Screenshot Taken", message: "View Screenshots in Gallery", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
		photosButton.isHidden = false
	}

}
