//
//  ImageViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 17/8/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    //var selectedImage:UIImage!;
    //var screenShotsCount = 0;
    var currentIndex:Int = 0;
    var screenShots = Array<UIImage>()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    override func viewDidLoad() {
        let imageToView = screenShots[currentIndex] as UIImage;
        imageView.image = imageToView;
        imageLabel.text = "\(currentIndex + 1) of \(screenShots.count)";
        if currentIndex == 0{
            prevButton.isHidden = true;
        }
		
		
    }
    
    @IBAction func tappedNextPrevButton(_ sender: UIButton) {
        if sender == nextButton{
            currentIndex+=1;
        }
        else if sender == prevButton{
            currentIndex-=1;
        }
        if currentIndex == 0{
                   prevButton.isHidden = true;
        }
        else{
            prevButton.isHidden = false;
        }
        
        if currentIndex == screenShots.count-1{
            nextButton.isHidden = true;
        }
        else{
            nextButton.isHidden = false;
        }
        let imageToView = screenShots[currentIndex] as UIImage;
        imageView.image = imageToView;
        imageLabel.text = "\(currentIndex + 1) of \(screenShots.count)";
    }
    
}
