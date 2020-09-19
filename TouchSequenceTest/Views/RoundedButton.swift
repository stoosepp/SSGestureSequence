//
//  RoundedButton.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
	
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    /*override func draw(_ rect: CGRect) {
        // Drawing code
    }
*/

    
	@IBInspectable var radius:Int = 1{
		didSet{
			layer.cornerRadius = frame.size.height / 4; // this value vary as per your desire
			clipsToBounds =  true
		}
	}
	@IBInspectable var labelOffset:CGFloat = 0{
		didSet{
			self.centerVertically(padding:labelOffset)
		}
	}
	
	
}

extension RoundedButton {
	
	func centerVertically(padding: CGFloat = 6.0) {
		guard
			let imageViewSize = self.imageView?.frame.size,
			let titleLabelSize = self.titleLabel?.frame.size else {
			return
		}
		
		let totalHeight = imageViewSize.height + titleLabelSize.height + padding
		let totalWidth = imageViewSize.width + titleLabelSize.width
		
		self.imageEdgeInsets = UIEdgeInsets(
			top: (totalHeight - imageViewSize.height - titleLabelSize.height - padding),
			left:0,
			bottom: 0.0,
			right: -(imageViewSize.width-titleLabelSize.width)
		)
		
		self.titleEdgeInsets = UIEdgeInsets(
			top: 0.0,
			left:-imageViewSize.width,
		   bottom: totalHeight,
		   right: 0.0
		)
		
		self.contentEdgeInsets = UIEdgeInsets(
			top: titleLabelSize.height,
			left: 0.0,
			bottom: 0,
			right: 0.0
		)
	}
	
}
