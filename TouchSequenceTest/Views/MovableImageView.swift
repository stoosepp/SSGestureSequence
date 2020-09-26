//
//  MovableViewController.swift
//  ImageSelectTest
//
//  Created by Stoo on 17/9/20.
//  Copyright © 2020 Stoo. All rights reserved.
//

import UIKit

class MovableImageView: UIImageView, UIGestureRecognizerDelegate {
 
	func viewWillLayoutSubviews() {
		layoutMargins = .zero
		layoutMarginsDidChange()
	}
	
      func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(sender:)))
        isUserInteractionEnabled = true
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
      }
        
        func enablePan() {
           let panGesture = UIPanGestureRecognizer(target: self, action: #selector(startPanning(sender:)))
           isUserInteractionEnabled = true
             panGesture.delegate = self
           addGestureRecognizer(panGesture)
         }
        
        func enableRotate() {
            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(startRotating(sender:)))
              isUserInteractionEnabled = true
             rotateGesture.delegate = self
              addGestureRecognizer(rotateGesture)
            }

        @objc
        private func startZooming(sender: UIPinchGestureRecognizer) {
            if let view = sender.view {
                      view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
                    sender.scale = 1
                  }
        }


        @objc
        private func startPanning(sender: UIPanGestureRecognizer) {
           if sender.state == .began || sender.state == .changed {

                    let translation = sender.translation(in: superview)
                    // note: 'view' is optional and need to be unwrapped
                    sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
                    sender.setTranslation(CGPoint.zero, in: self)
                }
            print("Current Center is \(sender.view!.center.x),\(sender.view!.center.y)")
            
        }
        
        @objc
           private func startRotating(sender: UIRotationGestureRecognizer) {
          if let view = sender.view {
                      view.transform = view.transform.rotated(by: sender.rotation)
                      sender.rotation = 0
                  }
      
        }
        
       
        //MARK:- UIGestureRecognizerDelegate Methods
        public func gestureRecognizer(_: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
        }


}
