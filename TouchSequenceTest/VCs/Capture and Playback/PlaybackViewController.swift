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

	//MARK: VIEW LIFECYCLE
//	override func viewWillAppear(_ animated: Bool) {
//		print("ViewWillAppear in Playback - The touches are \(savedTouches.count)"
//	}
    override func viewDidLoad() {
        super.viewDidLoad()
		
		playbackView.dataSet = dataSet!
		playbackView.playerDelegate = self
		
		updateSlider(valueAsPercentage: 1)
		self.navigationController?.navigationBar.isHidden = true
		playbackView.setupPlayerView()
    }

	
	//MARK: PLAYING AND PAUSING
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
		print("sliderDragged to \(sender.value)")//this is a percentage
		//Stop the timer and set the button to play again
		if playbackView.timer.isValid == true{
			playbackView.timer.invalidate()
			playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
			
		}
		print("Start:\(playbackView.startTime!)")
		print("End:\(String(describing: playbackView.endTime))")
	
		playbackView.pointsToDraw.removeAll()
		//get the redraw thing going
		//setTime Elapsed
		let totalTimeInterval = Float((playbackView.endTime?.timeIntervalSince(playbackView.startTime!))!)
		playbackView.timeElapsed = TimeInterval(totalTimeInterval*sender.value)
		playbackView.timeIntervalLabel!.text = String(format: "Timer: %.2f", playbackView.timeElapsed)
		playbackView.isScrubbing = true
		playbackView.prepareLinesToDraw()
		
	}
	
	//MARK: DELEGATE STUFF
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
	
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	
	
	@IBAction func backButtonPressed(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)

	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
		if segue.identifier == "showPlaybackSettingsSegue"{
			let settingsVC = segue.destination.children[0] as! PlaybackSettingsTableViewController
			settingsVC.delegate = playbackView
		}
    }
   
	
	//MARK: TOGGLE STUFF
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
		let dateString = Helpers().getTodayString()
		let screenShot = self.view.takeScreenshot()

		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		// choose a name for your image
		let fileName = "\(dateString).jpg"
		// create the destination file url to save your image
		let fileURL = documentsDirectory.appendingPathComponent(fileName)
		// get your UIImage jpeg dataSet representation and check if the destination file url already exists
		if let dataSet = screenShot.pngData(),
		  !FileManager.default.fileExists(atPath: fileURL.path) {
			do {
				// writes the image dataSet to disk
				try dataSet.write(to: fileURL)
				print("file saved")
			} catch {
				print("error saving file:", error)
			}
		}
		let alert = UIAlertController(title: "Screenshot Taken", message: "View Screenshots in Gallery", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}

}
