//
//  TouchHeatmap.swift
//  TouchHeatmap
//
//  Created by Christopher Helf on 26.09.15.
//  Copyright © 2015 Christopher Helf. All rights reserved.

import Foundation
import UIKit

final class TouchHeatmap : NSObject {
    
    // A simple struct to capture Touches
    struct Touch {
        // The location
        var point: CGPoint
        // The date when the touch occurred
        var date: NSDate
        // The radius given by the UITouch object
        var majorRadius: CGFloat
        // The tolerance given by the UITouch object
        var majorRadiusTolerance: CGFloat
    }
    
    // A struct keeping count of all touches and screenshots/ViewControllers
    struct TouchTracking {
        
        // The screenshot
        var screenshot : UIImage?
        
        // All stored touches
        var storedTouches = [Touch]()
        
        // An array keeping track how we got to the current ViewController
        var from = [String : Int]()
        var start = false
        
        init() {}
        
        // Function to add a connection to another ViewController
        mutating func addFrom(name: String?) {
            
            // Check whether a name was given, if not, this controller is the starting point
            guard let n = name else {
                start = true
                return
            }
            
            // Increase the counter, or create one
            if let cnt = from[n] {
                from[n] = cnt+1
            } else {
                from[n] = 1
            }

        }
    }
    
    // Singleton class
    static let sharedInstance = TouchHeatmap()
    
    // The queue in which we operate
    let backgroundQueue = DispatchQueue.global(qos: .background)
    
    // The error message which is given (unused yet)
    let errorMessage = "Did not Set UIApplication correctly"
    
    // The current viewController
    var currentController : String? = nil
    
    // UIScreen Size
    var size : CGRect? = nil
    
    // The Array for storage, key is the name of the viewcontroller, and value is
    // the object tracking touches
    var store = [String : TouchTracking]()
    
    // Initializer
    override init() {
        super.init()
        
        // We will render the TouchHeatmap when entering into background
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name:UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Set the size
        size = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.layer.frame
    }
    
    // Main Entry Point
    class func start() {
        _ = UIApplication.shared.next
        UIApplication.shared.swizzleSendEvent()
    }
    
    // Function to keep things synchronized between threads
    private func sync(block: () -> ()) {
        objc_sync_enter(self)
        block()
        objc_sync_exit(self)
    }
    
    // Main function that is overwritten in UIApplication, tracks all touches
    func sendEvent(event: UIEvent) {
        
        // We need touches in order to continue, as well as a viewcontroller
        guard let touches = event.allTouches, let name = self.currentController else {
            return
        }
        
        // No touches, no tracking
        guard touches.count > 0 else {
            return
        }
        
        // Iterate through all touches
        for touch in touches {
            
            // Get the touch phase
            let phase = touch.phase
            
            // Right now we simply track all touches
            if (phase == UITouch.Phase.ended || true) {
                
                // Enter the sync block
                self.sync {
                    // Get the touch location in the current view
                    let point = touch.location(in: touch.window)
                    // Create our own Touch object
                    let newTouch = Touch(point: point, date: NSDate(), majorRadius: touch.majorRadius, majorRadiusTolerance: touch.majorRadiusTolerance)
                    // Store this touch
                    self.store[name]?.storedTouches.append(newTouch)
                }
            }
        }

    }
    
    // Function that is overwritten for all UIViewControllers
    func viewDidAppear(name: String) {
        
        // Check whether a screenshot is necessary
        var screenshotNecessary = true
        
        sync {
            
            guard let item = self.store[name] else {
                self.store[name] = TouchTracking()
                self.store[name]!.addFrom(name: self.currentController)
                screenshotNecessary = true
                self.currentController = name
                return
            }
            
            // Assign the current viewController
            self.currentController = name
            self.store[name]!.addFrom(name: self.currentController)
            
            guard let _ = item.screenshot else {
                screenshotNecessary = true
                return
            }
            
        }
        
        // Screenshot is necessary, make one
        if screenshotNecessary {
            backgroundQueue.async() {
                self.makeScreenshot(name: name)
            }
        }
        
    }
    
    // Function creating a screenshot, and assigning it to our store dictionary
    func makeScreenshot(name: String) {
        DispatchQueue.main.async {
			let layer = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.layer
            let scale = UIScreen.main.scale
			UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.sync {
                // Store the Screenshot
                self.store[name]?.screenshot = screenshot
            }
        }
    }
    
    // Render the touches and save to camera roll
    @objc func didEnterBackground(_ notification: NSNotification) {
    
        for (_,item) in self.store{
            let screenshot = item.screenshot
            let touches = item.storedTouches
            if let image = createImageFromTouches(image: screenshot!, touches: touches) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
 
    }
    
    // Render the touchmap and blend it with the screenshot
    func createImageFromTouches(image: UIImage, touches: [Touch]) -> UIImage? {
        
        let result = TouchHeatmapRenderer.renderTouches(image: image, touches: touches)
        let touchImage = result.0
        let success = result.1
        
        if success {
            // A touch heatmap was rendered, blend it with the screenshot
            let size = image.size
            let rect =  CGRect(origin: CGPoint(x: 0, y :0), size: CGSize(width: size.width, height: size.height))
            
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(size, false, scale);
            image.draw(in: rect)
            touchImage.draw(in: rect, blendMode: CGBlendMode.normal, alpha: 1.0)
            let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            return renderedImage
        } else {
            // This is the case when no touches were tracked, then we don't make
            // a screenshot
            return nil
        }
    }

}
