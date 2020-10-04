//
//  ViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 2017-01-12.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UpgradeViewDelegate, RecordButtonDelegate, MultiTouchPlayerViewDelegate {
	
	
	
	//Views
	@IBOutlet weak var chosenImageView: MovableImageView!
	@IBOutlet weak var captureView: MultiTouchCaptureView!//captureView!
	@IBOutlet weak var playbackView: MultiTouchPlayerView!//captureView!
	
	
	//Buttons
	@IBOutlet weak var importPhotoButton: UIButton!
	@IBOutlet weak var toggleButton: UIButton!
	@IBOutlet weak var cameraButton: UIButton!
	@IBOutlet weak var photosButton: UIButton!
	
	@IBOutlet weak var lockRotationButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	
	@IBOutlet weak var recordButton: RecordButton!
	
	@IBOutlet weak var slider: UISlider!
	var imagePicker: ImagePicker!
	
	//MARK: VIEW LIFECYCLE
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		recordButton.delegate = self
	}

	
    override func viewDidLoad() {
        super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationController?.toolbar.clipsToBounds = true;
		
		captureView.isHidden = true
		captureView.isUserInteractionEnabled = false
		cameraButton.isHidden = true
		lockRotationButton.isHidden = true
		slider.alpha = 0
		
		lockRotationButton.isHidden = true
	
		self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		
		//Hide player to start
		playButton.isHidden = true
		playbackView.isHidden = true
		playbackView.playerDelegate = self
		
		//Deal with Pro stuf
		Core.shared.setDidUpgrade(value: false)
		setupApp(didUpgrade: true)
		
    }


	func setupApp(didUpgrade:Bool){
		//Edit this if testing pro features
		if didUpgrade == true
		{
			playButton.isHidden = true
			self.title = "Touch Capture Pro"
		}
		else{
			
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showUpgradeToPro"{
			let upgradeVC = segue.destination as! UpgradeViewController
			upgradeVC.upgradeDelegate = self
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: RECORD AND PLAYBACK

	func tapButton(isRecording: Bool) {

			if isRecording {
				print("Start recording")
				if chosenImageView.image == nil{
					chosenImageView.isHidden = true
					importPhotoButton.isHidden = true
				}
				captureView.isHidden = false
				
				captureView.isUserInteractionEnabled = true
				chosenImageView.isUserInteractionEnabled = false
				cameraButton.isHidden = true
				photosButton.isHidden = true
				self.navigationController?.navigationBar.isHidden = true
			} else {
				print("Stop recording")
				toggleButton.setImage((UIImage(systemName: "eye")), for: .normal)
				playButton.isHidden = false
				slider.alpha = 1
				slider.value = 1
				cameraButton.isHidden = false
				photosButton.isHidden = false
				
				captureView.isUserInteractionEnabled = false
				self.navigationController?.navigationBar.isHidden = false
				if playbackView.savedTouches.count == 0{
					playbackView.savedTouches = captureView.savedTouches
					print("There are \(captureView.savedTouches.count) touches to pass along")
					playbackView.isHidden = false
					captureView.isHidden = true
					playbackView.setupPlayerView()//This gets the endTime and Start Time
					sliderDragged(slider)
				}
				
				
				
			}
		}
	
	@IBAction func playPauseButtonPushed(_ sender:UIButton){
		if sender.image(for: .normal) == UIImage(systemName: "play.fill"){
			sender.setImage((UIImage(systemName: "pause.fill")), for: .normal)
		
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
		playbackView.prepareLinesToDraw(isScrubbing:true)
		
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
			importPhotoButton.isHidden = false
			
		}
		importPhotoButton.isHidden = false
		captureView.resetView()
		slider.alpha = 0
		//Playback stuff
		playButton.setImage((UIImage(systemName: "play.fill")), for: .normal)
		playbackView.timer.invalidate()
		playbackView.isHidden = true
		playbackView.timeElapsed = 0
		playButton.isHidden = true
		playbackView.savedTouches.removeAll()
		
	}
	
	
	
	//MARK: IMAGE IMPORT
	
	@IBAction func chooseImage(_ sender: UIButton) {
		  //resetTransforms(forView: imageView, transformType: "all", value: 0)
		  self.imagePicker.present(from: sender)
		
	  }
	
	
	@IBAction func lockRotation(_ sender: UIBarButtonItem) {
		if sender.tintColor == .red{
			print("Unlocking Rotation")
			sender.tintColor = .green
			chosenImageView.enableRotate()
		}
		else {
			print("Locking Rotation")
			sender.tintColor = .red
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
	
	//MARK: TOGGLE STUFF
    @IBAction func toggleGestures(_ sender: UIButton) {
		if sender.image(for: .normal) == UIImage(systemName: "eye"){
			sender.setImage((UIImage(systemName: "eye.slash")), for: .normal)
			captureView.pencilLineColor = .clear
			captureView.fingerLineColor = .clear
			captureView.setNeedsDisplay()
			
			
        }
        else{
			sender.setImage((UIImage(systemName: "eye")), for: .normal)
			captureView.pencilLineColor = .blue
			captureView.fingerLineColor = .black
			captureView.setNeedsDisplay()
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
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = screenShot.jpegData(compressionQuality:  1.0),
          !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
        let alert = UIAlertController(title: "Screenshot Taken", message: "View Screenshots in Gallery", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
	
	

	//MARK: Delegate Stuff
	//TouchPlayerDelegate Funcs
	func updateViews(isPlaying: Bool) {
		if isPlaying == false{
			playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
		}
	}
	
	func updateSlider(valueAsPercentage: Float) {
		let sliderMax = slider.maximumValue
		let currentValue = valueAsPercentage * sliderMax
		print("Slider updated to \(currentValue)")
		slider.value = currentValue
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
}

public protocol ImagePickerDelegate: class {
	func didSelect(image: UIImage?)
}

extension ViewController: ImagePickerDelegate {

	func didSelect(image: UIImage?) {
		self.chosenImageView.image = image
		print("Image Chosen")
		lockRotationButton.isHidden = false
		importPhotoButton.isHidden = true
		recordButton.isHidden = false
		lockRotationButton.isHidden = false
		chosenImageView.isHidden = false
		chosenImageView.removeAllConstraints()
		chosenImageView.enableZoom()
		chosenImageView.enablePan()
		chosenImageView.enableRotate()
	}
}

