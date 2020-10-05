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
			layer.cornerRadius = CGFloat(radius) // this value vary as per your desire
			clipsToBounds =  true
		}
	}
	@IBInspectable var labelOffset:CGFloat = 0{
		didSet{
			self.centerImageAndButton(labelOffset, imageOnTop: false)
		}
	}
	
	@IBInspectable var strokeColor:CGColor = UIColor.clear.cgColor{
		didSet{
			self.layer.borderColor = strokeColor
		}
	}
	
	@IBInspectable var borderWidth:CGFloat = 0{
		didSet{
			self.layer.borderWidth = borderWidth
		}
	}
	
}

extension RoundedButton {
	
	func centerImageAndButton(_ gap: CGFloat, imageOnTop: Bool) {

		  guard let imageView = self.currentImage,
		  let titleLabel = self.titleLabel?.text else { return }

		  let sign: CGFloat = imageOnTop ? 1 : -1
		self.titleEdgeInsets = UIEdgeInsets(top: (imageView.size.height + gap) * sign, left: -imageView.size.width, bottom: 0, right: 0);

		let titleSize = titleLabel.size(withAttributes:[NSAttributedString.Key.font: self.titleLabel!.font!])
		self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + gap) * sign, left: 0, bottom: 0, right: -titleSize.width)
		}
	
}
