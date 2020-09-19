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
	@IBOutlet weak var transparencyView: TransparencyView!
	@IBOutlet weak var resetButton: RoundedButton!
	@IBOutlet weak var toggleButton: RoundedButton!
	@IBOutlet weak var cameraButton: RoundedButton!
	@IBOutlet weak var photosButton: RoundedButton!
	@IBOutlet weak var importPhotoButton: RoundedButton!
	@IBOutlet weak var startDrawingButton: RoundedButton!
	var isDrawing:Bool = false
	
	var imagePicker: ImagePicker!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
		transparencyView.velocityLabel.text = "Slow: 0%\nMedium: 0%\nFast: 0%\nAvg: 0"
		transparencyView.isHidden = true
		//transparencyView.alpha = 0.0

		//DemoFactory().fetchData()
		
		self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		chosenImageView.enableZoom()
		chosenImageView.enablePan()
		chosenImageView.enableRotate()
		
		chosenImageView.removeAllConstraints()
		resetButton.isHidden = true
		toggleButton.isHidden = true
		cameraButton.isHidden = true
		photosButton.isHidden = true
		startDrawingButton.isHidden = true
        
    }
	
	@IBAction func startDrawing(){
		if isDrawing == false {
			importPhotoButton.isHidden = true
			isDrawing = true
			transparencyView.isHidden = false
			startDrawingButton.titleLabel?.text = "Finish"
			toggleButton.isHidden = false
			
		}
		else{
			isDrawing = false
			resetButton.isHidden = false
			cameraButton.isHidden = false
			photosButton.isHidden = false
			
		}
		
	}
    
//    override var prefersStatusBarHidden: Bool {
//      return true
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleGestures(_ sender: UIButton) {
    
		if transparencyView.mainImageView.isHidden == true{
            sender.setImage(UIImage(systemName: "eye.fill"), for:.normal)
			transparencyView.mainImageView.isHidden = false
			transparencyView.tempImageView.isHidden = false
			transparencyView.velocityLabel.isHidden = false
        }
        else{
            sender.setImage(UIImage(systemName: "eye.slash.fill"), for:.normal)
			transparencyView.mainImageView.isHidden = true
			transparencyView.tempImageView.isHidden = true
			transparencyView.velocityLabel.isHidden = true
        }
            
    }
	
	@IBAction func chooseImage(_ sender: UIButton) {
		  //resetTransforms(forView: imageView, transformType: "all", value: 0)
		  self.imagePicker.present(from: sender)
		
	  }
    
    @IBAction func resetScreen(_ sender: Any) {
		transparencyView.resetView()
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
		startDrawingButton.isHidden = false
	}
}

