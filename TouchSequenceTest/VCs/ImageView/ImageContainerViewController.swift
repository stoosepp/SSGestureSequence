//
//  ImageContainerViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 23/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

class ImageContainerViewController: UIViewController, ImageDataDelegate, UIPageViewControllerDelegate {


	var screenShotURLs = Array<URL>()
	var currentIndex:Int = 0;
	@IBOutlet weak var textLabel:UILabel!
	@IBOutlet weak var pageControl:UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("Containerview loaded with \(screenShotURLs.count) items at index \(currentIndex)")
		
        // Do any additional setup after loading the view
		//updateViewWithIndex(currentIndex)
		
    }
	
	func updateView(withIndex: Int, andCount:Int) {
		currentIndex = withIndex
		pageControl.numberOfPages = andCount
		pageControl.currentPage = currentIndex
		textLabel.text = "\(currentIndex+1) of \(andCount)"
		print("Delegate fired showing \(currentIndex) / \(andCount)")
		
	}
	
	//MARK: Handle Delete Image
	@IBAction func deleteImage(){
		//Delete file
	
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "imageContainer" {
			let imageContainer = segue.destination as! ImagePageViewController
			imageContainer.containerDelegate = self
			//imageContainer.screenShotURLs = screenShotURLs
			imageContainer.currentIndex = currentIndex
		}
		
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
