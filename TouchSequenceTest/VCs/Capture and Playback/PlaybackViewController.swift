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
	var heatmapSubviews = [UIImageView]()
	
	//Stackviews
	@IBOutlet weak var playbackStackView: UIStackView!
	
	//Buttons
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var cameraButton: UIButton!
	@IBOutlet weak var photosButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var slider: UISlider!
	
	//Touch Arrays
	var thisDataSetsTouches = [Touch]()
	var allTouchesForExperiment = [Touch]()
	var allTouchesSeparatedByStimulus = [[Touch]]()
	
	
	//Status
	var isShowingAnalysis = false
	var currentAlpha:CGFloat = 1.0
	
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
			for index in 0..<stimuliArray.count{
				setupStimuli(atIndex: index)
			}
		}
		playbackView.setupPlayerView()
		checkIndex()
		
		//Parse Touches on the outset.
		thisDataSetsTouches = dataSet?.touches?.allObjects as! [Touch]
		print("This dataSet has \(thisDataSetsTouches.count) touches")
		//checkIndex()
		
		TouchManager.sharedInstance.fetchAllTouches(forExperiment: experiment!) { (returnedTouches) in
			self.allTouchesForExperiment = returnedTouches
			print("Fetched \(self.allTouchesForExperiment.count) Touches in total for This Experiment")
			
		}
		TouchManager.sharedInstance.fetchAllTouchesSeparatedbyStimuli(forExperiment: experiment!) { (returnedTouches) in
			self.allTouchesSeparatedByStimulus = returnedTouches
			print("Fetched touches for \(self.allTouchesSeparatedByStimulus.count) stimuli")
		}

    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	//MARK: - PLAYING AND PAUSING
	@IBAction func playPauseButtonPushed(_ sender:UIButton){
		if sender.image(for: .normal) == UIImage(systemName: "play.fill"){
			print("Pressing The Play Button")
			sender.setImage((UIImage(systemName: "pause.fill")), for: .normal)
			playbackView.tapButton(isPlaying:true)
		}
		else{
			sender.setImage((UIImage(systemName: "play.fill")), for: .normal)
			print("Pressing The Pause Button")
			playbackView.tapButton(isPlaying:false)
		}
	}
	
	@IBAction func nextButtonPushed(_ sender:UIButton){
		currentIndex += 1
		let newTime = getDurationFrom(stimulusIndex: currentIndex, inStimulusArray:stimuliArray)
		if playbackView.timeElapsed < newTime || currentIndex > stimuliArray.count - 1 {
			currentIndex -= 1
		}
		let rounded = roundNumber(number: Float(newTime), toFrameRate: playbackView.frameRate)
		let percentage = Float(rounded/Float(experiment!.totalDuration))
		updateSlider(valueAsPercentage: percentage)
		playbackView.timeElapsed = TimeInterval(rounded)
		if currentIndex >= stimuliArray.count-1{
			updateSlider(valueAsPercentage: Float(100.00))
			playbackView.timeElapsed = playbackView.endTime
		}
		jumpToNextPrevious()
	}
	
	@IBAction func previousButtonPushed(_ sender:UIButton){
		checkIndex()
		currentIndex -= 1
		let newTime = getDurationFrom(stimulusIndex: currentIndex, inStimulusArray:stimuliArray)
		if playbackView.timeElapsed > newTime || currentIndex < stimuliArray.count - 1 {
			currentIndex += 1
		}
		let adjustedTime = getDurationFrom(stimulusIndex: currentIndex, inStimulusArray:stimuliArray)
		let rounded = roundNumber(number: Float(adjustedTime), toFrameRate: playbackView.frameRate)
		let percentage = Float(rounded/Float(experiment!.totalDuration))
		updateSlider(valueAsPercentage: percentage)
		playbackView.timeElapsed = TimeInterval(rounded)
		if currentIndex == 0{
			updateSlider(valueAsPercentage: Float(0))
			playbackView.timeElapsed = playbackView.startTime
		}
		jumpToNextPrevious()
		
	
	}
	func jumpToNextPrevious(){
		checkIndex()
		playbackView.timeIntervalLabel!.text = playbackView.timeElapsed.stringFromTimeInterval(withFrameRate: 0.05)
		showStimuli(atIndex: currentIndex)

		if isShowingAnalysis == true{
			showHeatmap(atIndex: currentIndex)
		}
		if playbackView.linesVisible == true{
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
		let interval = Float(totalTimeInterval) * sender.value
		let rounded = roundNumber(number: interval, toFrameRate: playbackView.frameRate)
		playbackView.timeElapsed = TimeInterval(rounded)
		playbackView.timeIntervalLabel!.text = String(format: "Timer: %.2f", playbackView.timeElapsed)
		playbackView.isScrubbing = true
		checkIndex()
		playbackView.pointsToDraw.removeAll()
		playbackView.prepareLinesToDraw()
	}
	
	func roundNumber(number: Float, toFrameRate:CGFloat) -> Float {
		return Float(toFrameRate) * Float(round(number / Float(toFrameRate)))
	}
	
	//MARK: - DELEGATE STUFF
	//TouchPlayerDelegate Funcs
	func checkIndex() {
		let thisIndex = getStimuliIndexFrom(duration: playbackView.timeElapsed, forStimuli: stimuliArray)
		if thisIndex != currentIndex{
			currentIndex = thisIndex
			print("Updating INdex to:\(currentIndex)")
			let tempTime = getDurationFrom(stimulusIndex: currentIndex, inStimulusArray: stimuliArray)
			playbackView.currentStimulusStartTime = tempTime
			showStimuli(atIndex: currentIndex)
			if isShowingAnalysis == true{
				showHeatmap(atIndex: currentIndex)
			}
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
    }
   
	
	//MARK: - TOGGLE STUFF
	
	@IBAction func testHeatMap(_ sender:UIButton){
		if isShowingAnalysis == false{
			setupHeatMaps()
			isShowingAnalysis = true
		}
		else{
			resetHeatmaps()
			isShowingAnalysis = false
		}
	}
	
	func resetHeatmaps(){
		for heatmap in heatmapSubviews{
			heatmap.removeFromSuperview()
		}
		heatmapSubviews.removeAll()
	}
	
	func prepareHeatMapFor(touchArray:[Touch]){
		let image  = TouchHeatmapRenderer.renderTouches(view: self.view, touches: touchArray)
		let newImageView = UIImageView(frame: self.playbackView.frame)
		newImageView.image = image.0
		self.view.insertSubview(newImageView, aboveSubview: self.playbackView)
		heatmapSubviews.append(newImageView)
	}
	
	func setupHeatMaps() {
		resetHeatmaps()
		if playbackView.touchesSeparatedbyStimuli == true{
			
			for touchArray in allTouchesSeparatedByStimulus{
				prepareHeatMapFor(touchArray: touchArray)
			}
			showHeatmap(atIndex: currentIndex)
			print("There are now \(heatmapSubviews.count) Heatmaps. Showing at \(currentIndex)")
		}
		else{
			prepareHeatMapFor(touchArray: allTouchesForExperiment)
			showHeatmap(atIndex: 0)
		}
	}
	
	func showHeatmap(atIndex:Int){
		print("Showing heat map at \(atIndex)")
		if heatmapSubviews.count > 1 {
			for view in heatmapSubviews{
				view.isHidden = true
			}
			heatmapSubviews[atIndex].isHidden = false
		}
		else{
			heatmapSubviews[0].isHidden = false
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
