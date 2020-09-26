//
//  ImagePageViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 23/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

protocol ImageDataDelegate {
	func updateView(withIndex: Int, andCount:Int)
}

class ImagePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	var currentIndex:Int = 0;
	var screenShotURLs = Array<URL>()
	var imageControllers = [UIViewController]()
	var containerDelegate:ImageContainerViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		print("PageController loaded with \(screenShotURLs.count) items at index \(currentIndex)")
        // Do any additional setup after loading the view.
		self.delegate = self
		self.dataSource = self
		screenShotURLs = Core.shared.fetchFileURLS()
		for (index,screenShot) in screenShotURLs.enumerated(){
			
			let newVC = UIViewController()
			let newimageView = UIImageView()
			newimageView.contentMode = .scaleAspectFit
			let imageFile = screenShot.absoluteURL
			let data = try? Data(contentsOf: imageFile)
			
			
			newimageView.image = UIImage(data: data!)!
			newVC.view.addSubview(newimageView)
			
			Core.shared.setConstraintPins(view: newimageView, parentview: newVC.view, asLeading: 5, trailing: 5, top: 5, bottom: 5)
			imageControllers.append(newVC)
		}
		containerDelegate!.updateView(withIndex: currentIndex, andCount: screenShotURLs.count)
    }
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("Image Page VC: ViewDid appear fired")
		self.presentPageVC()
	}
	
	func presentPageVC(){
		let firstVC = imageControllers[currentIndex]
		//Setup PageViews
		self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
		
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return imageControllers.count
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = imageControllers.firstIndex(of: viewController ), index > 0 else{
			return nil
		}
		let before = index - 1
		currentIndex -= 1
		return imageControllers[before]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = imageControllers.firstIndex(of: viewController ), index < imageControllers.count-1 else{
			return nil
		}
		let after = index + 1
		currentIndex += 1
		return imageControllers[after]
	}
	

	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		var viewControllerIndex:Int!
		for (index,vc) in imageControllers.enumerated(){
			if vc == pendingViewControllers.first{
				viewControllerIndex = index
				break
			}
		}
		containerDelegate!.updateView(withIndex: viewControllerIndex, andCount: screenShotURLs.count)
	}
}
