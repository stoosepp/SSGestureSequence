//
//  ViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 2017-01-12.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


	@IBOutlet weak var chosenImageView: MovableImageView!
	@IBOutlet weak var importPhotoButton: UIButton!
	@IBOutlet weak var transparencyView: TouchCaptureView!//TransparencyView!
	//@IBOutlet weak var resetButton: UIBarButtonItem!
	@IBOutlet weak var toggleButton: UIBarButtonItem!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var photosButton: UIBarButtonItem!
	
	@IBOutlet weak var startDrawingButton: UIBarButtonItem!
	@IBOutlet weak var lockRotationButton: UIBarButtonItem!
	@IBOutlet weak var playButton: UIBarButtonItem!
	var isDrawing:Bool = false
	
	var imagePicker: ImagePicker!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.

		transparencyView.isHidden = true
	
		self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		chosenImageView.enableZoom()
		chosenImageView.enablePan()
		chosenImageView.enableRotate()
		
		
		//resetButton.isEnabled = true
		toggleButton.isEnabled = false
		cameraButton.isEnabled = false
		photosButton.isEnabled = false
		lockRotationButton.isEnabled = false
		playButton.isEnabled = false
		
    }
	
	func setupIfPro(){
		if Core.shared.didUpgrade() == true
		{
			//Show Buttons relevant to Pro users
			playButton.isHidden(true)
		}
	}
	
	@IBAction func startDrawing(){
	
		if isDrawing == false {
			if chosenImageView.image == nil{
				chosenImageView.isHidden = true
				importPhotoButton.isHidden = true
			}
			isDrawing = true
			transparencyView.isHidden = false
			startDrawingButton.title = "Finish"
			toggleButton.isEnabled = true
			
		}
		else{
			isDrawing = false
			//resetButton.isEnabled = false
			cameraButton.isEnabled = true
			photosButton.isEnabled = true
			playButton.isEnabled = true
			startDrawingButton.title = "Start Capture"
		}
		self.navigationController?.navigationBar.isHidden = true
		
	}
	
	@IBAction func lockRotation(_ sender: UIButton) {
	  
		if sender.titleLabel?.text == "Lock"{
			sender.setTitle("Unlock", for: .normal)
			sender.setImage(UIImage(systemName: "lock.rotation.open"), for:.normal)
			let rotateRecognizer = chosenImageView.gestureRecognizers?[2]
			chosenImageView.removeGestureRecognizer(rotateRecognizer!)
		
			let rotationTransform = CGAffineTransform(rotationAngle: 0.0)
			let scale:CGFloat = chosenImageView.transform.a
			let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
			//chosenImageView.transform = CGAffineTransform(translationX: 0, y: 0)
			let finalTransform = rotationTransform.concatenating(scaleTransform)
			chosenImageView.transform = finalTransform

		}
		else if sender.titleLabel?.text == "Unlock" {
			sender.setTitle("Lock", for: .normal)
			chosenImageView.enableRotate()
		}
				  
	}
    
//    override var prefersStatusBarHidden: Bool {
//      return true
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleGestures(_ sender: UIBarButtonItem) {
    
		if sender.title == "Show"{//transparencyView.mainImageView.isEnabled == true{
            sender.image = UIImage(systemName: "eye.slash.fill")
			sender.title = "Hide"
			
        }
        else{
			sender.image =  UIImage(systemName: "eye.fill")
			sender.title = "Show"
        }
            
    }
	
	@IBAction func chooseImage(_ sender: UIButton) {
		  //resetTransforms(forView: imageView, transformType: "all", value: 0)
		  self.imagePicker.present(from: sender)
		
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
		
		if transparencyView.isPaused == true{
			sender.image = UIImage(systemName: "pause.fill")
			//if transparencyView.timer == nil && transparencyView.savedTouches.count != 0{
				transparencyView.playPause()
			/*}
			else{
				let alert = UIAlertController(title: "No Touches Recorded", message: "No Touches present. Draw something first, then hit play", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}*/
			
		}
		else{
			
			sender.image = (UIImage(systemName: "play.fill"))
			transparencyView.timer?.invalidate()
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
		startDrawingButton.isEnabled = false
		lockRotationButton.isEnabled = false
		chosenImageView.removeAllConstraints()
	}
}

