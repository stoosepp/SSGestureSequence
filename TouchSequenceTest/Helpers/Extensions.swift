//
//  Extensions.swift
//  ImageSelectTest
//
//  Created by Stoo on 17/9/20.
//  Copyright © 2020 Stoo. All rights reserved.
//

import UIKit

extension CGAffineTransform{
    var scale: CGFloat{
        return sqrt(CGFloat(a * a + c * c))
    }
    
}

extension UIView {
    
    public func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

extension UIView {
	 
	 func takeScreenshot() -> UIImage {
		 
		 //begin
		 UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
		 
		 // draw view in that context.
		 drawHierarchy(in: self.bounds, afterScreenUpdates: true)
		 
		 // get iamge
		 let image = UIGraphicsGetImageFromCurrentImageContext()
		 UIGraphicsEndImageContext()
		 
		 if image != nil {
			 return image!
		 }
		 
		 return UIImage()
		 
	 }
	 
 }

extension Date {
	func isBetween(_ date1: Date, and date2: Date) -> Bool {
		return (min(date1, date2) ... max(date1, date2)) ~= self
	}
}

/*
extension UIBarButtonItem{
	func isHidden(_ value:Bool)
	{
		if value == true{
			isEnabled = false
			tintColor = .clear
		}
		else{
			isEnabled = true
			tintColor = .blue
		}
	}
}
*/

