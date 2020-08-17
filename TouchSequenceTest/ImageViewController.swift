//
//  ImageViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 17/8/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var selectedImage:UIImage!;
    var screenShotsCount = 0;
    var currentIndex = 0;
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    override func viewDidLoad() {
        imageView.image = selectedImage;
        imageLabel.text = "\(currentIndex) of \(screenShotsCount)";
    }
    
    
}
