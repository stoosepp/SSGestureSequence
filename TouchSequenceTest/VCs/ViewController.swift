//
//  ViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 2017-01-12.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UpgradeViewDelegate, TouchPlayerDelegate {
	
	

	//Views
	@IBOutlet weak var chosenImageView: MovableImageView!
	@IBOutlet weak var transparencyView: TouchCaptureView!//TransparencyView!
	@IBOutlet weak var playbackView: TouchPlayerView!//TransparencyView!
	
	
	//Buttons
	@IBOutlet weak var importPhotoButton: UIButton!
	@IBOutlet weak var toggleButton: UIBarButtonItem!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var photosButton: UIBarButtonItem!
	
	@IBOutlet weak var startDrawingButton: UIBarButtonItem!
	@IBOutlet weak var lockRotationButton: UIBarButtonItem!
	@IBOutlet weak var playButton: UIBarButtonItem!
	
	var imagePicker: ImagePicker!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		transparencyView.isHidden = true
		transparencyView.isUserInteractionEnabled = false
		toggleButton.isEnabled = false
		cameraButton.isEnabled = false
		lockRotationButton.isEnabled = false
	
		self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		
		//Hide player to start
		playButton.isHidden(true)
		playbackView.isHidden = true
		playbackView.playerDelgate = self
		
		//Deal with Pro stuf
		Core.shared.setDidUpgrade(value: false)
		setupApp(didUpgrade: true)
		
    }


	func setupApp(didUpgrade:Bool){
		//Edit this if testing pro features
		if didUpgrade == true
		{
			playButton.isHidden(false)
			playButton.isEnabled = false
			self.title = "Touch Capture Pro"
		}
		else{
			
		}
	}
	
	@IBAction func toggleDrawing(_ sender: UIBarButtonItem){
		if sender.title == "Start Capture"{
			updateItems(forDrawing: true)
		}
		else if sender.title == "Stop Capture"{
			updateItems(forDrawing: false)
		}
		else if sender.title == "Reset View"{
			//Reset View
			resetDrawing()
		}
	}
	
	func updateItems(forDrawing:Bool){
		
		if forDrawing == true{
			if chosenImageView.image == nil{
				chosenImageView.isHidden = true
				importPhotoButton.isHidden = true
			}
			transparencyView.isHidden = false
			toggleButton.isEnabled = true
			cameraButton.isEnabled = false
			photosButton.isEnabled = false
			transparencyView.isUserInteractionEnabled = true
			chosenImageView.isUserInteractionEnabled = false
			self.navigationController?.navigationBar.isHidden = true
			startDrawingButton.title = "Stop Capture"
			
		}
		else{
			toggleButton.isEnabled = false
			photosButton.isEnabled = true
			cameraButton.isEnabled = true
			startDrawingButton.title = "Reset View"
			playButton.isEnabled = true
			self.navigationController?.navigationBar.isHidden = false
		}


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
	
	func resetDrawing(){
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
		
		startDrawingButton.title = "Start Capture"
		importPhotoButton.isHidden = false
		transparencyView.savedTouches.removeAll()
		transparencyView.setNeedsDisplay()
		
		//Playback stuff
		playButton.image = (UIImage(systemName: "play.fill"))
		playbackView.timer?.invalidate()
		playbackView.isHidden = true
		playbackView.isPaused = true
		playbackView.timeElapsed = 0
		playButton.isEnabled = false
		playbackView.savedTouches.removeAll()
		
	}
    
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleGestures(_ sender: UIBarButtonItem) {
    
		if sender.image == UIImage(systemName: "eye.fill"){//transparencyView.mainImageView.isEnabled == true{
            sender.image = UIImage(systemName: "eye.slash.fill")
			transparencyView.lineColor = .clear
			transparencyView.setNeedsDisplay()
			
			
        }
        else{
			sender.image =  UIImage(systemName: "eye.fill")
			transparencyView.lineColor = .black
			transparencyView.setNeedsDisplay()
        }
            
    }
	
	@IBAction func chooseImage(_ sender: UIButton) {
		  //resetTransforms(forView: imageView, transformType: "all", value: 0)
		  self.imagePicker.present(from: sender)
		
	  }
	

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showUpgradeToPro"{
			let upgradeVC = segue.destination as! UpgradeViewController
			upgradeVC.upgradeDelegate = self
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
	
	
	@IBAction func playPauseButtonPushed(_ sender:UIBarButtonItem){
		if sender.image == UIImage(systemName: "play.fill"){
			sender.image = UIImage(systemName: "pause.fill")
			if playbackView.savedTouches.count == 0{
				playbackView.savedTouches = transparencyView.savedTouches
				playbackView.isHidden = false
				transparencyView.isHidden = true
			}
			playbackView.playPause()
		}
		else{
			sender.image = (UIImage(systemName: "play.fill"))
			playbackView.playPause()
		}
	}
	//MARK: Delegate Stuff
	//TouchPlayerDelegate Funcs
	func updateViews(isPlaying: Bool) {
		if isPlaying == false{
			playButton.image = UIImage(systemName: "play.fill")
		}
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
		importPhotoButton.isHidden = true
		startDrawingButton.isEnabled = true
		lockRotationButton.isEnabled = true
		chosenImageView.isHidden = false
		chosenImageView.removeAllConstraints()
		chosenImageView.enableZoom()
		chosenImageView.enablePan()
		chosenImageView.enableRotate()
	}
}

