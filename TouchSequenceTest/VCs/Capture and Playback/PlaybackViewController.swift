//
//  PlaybackViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 5/10/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData
import JGProgressHUD

class PlaybackViewController: TouchCoreViewController, MultiTouchPlayerViewDelegate  {
	
	//Views
	@IBOutlet weak var playbackView: MultiTouchPlayerView!
	
	//Buttons
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var cameraButton: UIButton!
	@IBOutlet weak var photosButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var slider: UISlider!
	
	var savedTouches = [[Touch?]?]()
	var touchesForAllDataSets = [Touch]()
	var currentAlpha:CGFloat = 1.0
	
	//Stackviews
	@IBOutlet weak var playbackStackView: UIStackView!

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
			stimuliArray = fetchStimuli()
			print("There are now \(self.view.subviews.count) subviews")
			for index in 0..<stimuliArray!.count{
				setupStimuli(atIndex: index)
			}
			print("There are now \(self.view.subviews.count) subviews")
		}
		playbackView.setupPlayerView()
		updateViews(isPlaying: false)
		
		//parse all touches on load
		let dataSets = experiment!.dataSets?.allObjects as! [DataSet]
		for thisDataSet in dataSets{
			DispatchQueue.global(qos: .background).async {
				let thisTouchArray = thisDataSet.touches?.allObjects as! [Touch]
				self.touchesForAllDataSets.append(contentsOf: thisTouchArray)
			}
		}
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	//MARK: - SETUP STIMULI
	
	

	
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
	@IBAction func nextButtonPushed(_ sender:UIButton){
		if currentIndex != stimuliArray!.count-1{
			
			currentIndex += 1
			let newTime = getDurationFrom(stimulusIndex: currentIndex)
			let percentage = Float(newTime/experiment!.totalDuration)
			updateSlider(valueAsPercentage: Float(percentage))
			showStimuli(atIndex: currentIndex)
			playbackView.timeElapsed = newTime
			playbackView.timeIntervalLabel!.text = playbackView.timeElapsed.stringFromTimeInterval(withFrameRate: 0.05)
			playbackView.pointsToDraw.removeAll()
			playbackView.prepareLinesToDraw()
		}
		else if currentIndex == stimuliArray!.count-1{
			updateSlider(valueAsPercentage: Float(100.00))
			showStimuli(atIndex: currentIndex)
			playbackView.timeElapsed = playbackView.endTime
			playbackView.timeIntervalLabel!.text = playbackView.timeElapsed.stringFromTimeInterval(withFrameRate: 0.05)
			playbackView.pointsToDraw.removeAll()
			playbackView.prepareLinesToDraw()
		}
		
		
	}
	@IBAction func previousButtonPushed(_ sender:UIButton){
		if currentIndex != 0{
			let newTime = getDurationFrom(stimulusIndex: currentIndex)
			let percentage = Float(newTime/experiment!.totalDuration)
			updateSlider(valueAsPercentage: Float(percentage))
			showStimuli(atIndex: currentIndex)
			playbackView.timeElapsed = newTime
			playbackView.timeIntervalLabel!.text = playbackView.timeElapsed.stringFromTimeInterval(withFrameRate: 0.05)
			playbackView.pointsToDraw.removeAll()
			playbackView.prepareLinesToDraw()
			currentIndex -= 1
		}
		else if currentIndex == 0{
			updateSlider(valueAsPercentage: Float(0.0))
			showStimuli(atIndex: currentIndex)
			playbackView.timeElapsed = 0.0
			playbackView.timeIntervalLabel!.text = playbackView.timeElapsed.stringFromTimeInterval(withFrameRate: 0.05)
			playbackView.pointsToDraw.removeAll()
			playbackView.prepareLinesToDraw()
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
		updateViews(isPlaying: false)
	}
	
	//MARK: - DELEGATE STUFF
	//TouchPlayerDelegate Funcs
	func updateViews(isPlaying: Bool) {
		if isPlaying == false{
			playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
		else{
			playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
		}
		//Show Appropriate Stimulus for duration
		let thisIndex = getStimuliIndexFrom(duration: playbackView.timeElapsed)
		if thisIndex != currentIndex{
			currentIndex = thisIndex
			
			let tempTime = getDurationFrom(stimulusIndex: currentIndex)
			playbackView.currentStimulusStartTime = tempTime
			showStimuli(atIndex: currentIndex)
		}
		
	}

	
	func updateSlider(valueAsPercentage: Float) {
		let sliderMax = slider.maximumValue
		let currentValue = valueAsPercentage * sliderMax
		slider.value = currentValue
	}
	
	func updateViewsAlpha(withAlpha:CGFloat){
		for view in stimuliSubViews{
			view.alpha = withAlpha
		}
	}
	
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	
	
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
        // Get the new view controller using segue.destination.
		if segue.identifier == "showSettingsSegue"{
			let settingsVC = segue.destination as! PlaybackSettingsViewController
			settingsVC.delegate = playbackView
			settingsVC.currentAlpha = Float(currentAlpha)
			if sender is Bool{
				settingsVC.view.isHidden = (sender != nil)
			}
		}
		else if segue.identifier == "showScreenshotsSegue"{
			let imageCollectionVC = segue.destination as! ImageCollectionViewController
			imageCollectionVC.dataSet = dataSet
		}
//		else if segue.identifier == "showAnalysisSegue"{
//			let analysisVC = segue.destination as! AnalysisSettingsViewController
//		}
    }
   
	
	//MARK: - TOGGLE STUFF
	
	@IBAction func testHeatMap(_ sender:UIButton){
		let hud = JGProgressHUD()
		hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
		hud.textLabel.text = "Building HeatMaps"
		hud.textLabel.font = UIFont(name:"HelveticaNeue" , size: 45)
		hud.show(in: self.view)
		
		playbackStackView.isHidden = true
		playbackView.isHidden = true
		
		let start = Date()
		
		let gridSize:Int = 20
		
		let newHeatMapView = HeatMapView(frame: playbackView.frame, gradientCount: 5)
	
		
		newHeatMapView.setupMap(forView: self.playbackView, withSize: gridSize, withGradientCount: 5, withTouches: touchesForAllDataSets) { (completion) in
			//Completed map set up
			if completion == true{
				self.view.insertSubview(newHeatMapView, aboveSubview: self.playbackView)
				hud.dismiss()
				print("Completed Map Setup")
//				let blurEffectView = CustomBlurEffectView(radius: CGFloat(Double(gridSize)/4), color: nil, colorAlpha: 1.0)
//				blurEffectView.frame = newHeatMapView.frame
//				newHeatMapView.addSubview(blurEffectView)
//				newHeatMapView.alpha = 0.7
				let end = Date()
				let difference = end.timeIntervalSince(start)
				let string = String(format: "HeatMap built in %.2f s", difference)
				print(string)
			}
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
