//
//  CircleButton.swift
//  FirebaseTest
//
//  Created by Stoo on 2016-09-22.
//  Copyright © 2016 StooSepp. All rights reserved.
//

import UIKit

@IBDesignable

class CircleView: UIView {

    @IBInspectable var labelText:String?{
        didSet{
            setNeedsDisplay()
        }
    }
 
    var lineWidth:CGFloat = 1{
        didSet{
            setNeedsDisplay()
        }
    }
    var theColor:UIColor = .black{
        didSet{
            setNeedsDisplay()
        }
    }

    
    //var imageView:UIImageView!
    var titleLabel:UILabel!
    var didDraw:Bool = false
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
       
        //backgroundColor = UIColor.clear
 
        titleLabel = UILabel()
        titleLabel.frame = self.bounds
        let adjustedFontSize = self.frame.size.height / 2
        titleLabel.font = titleLabel.font.withSize(adjustedFontSize)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        self.backgroundColor = UIColor.clear
        self.lineWidth = 4.0
        self.addSubview(titleLabel)
     
       
        //Set Text and Image, If they exist.
        if labelText != nil{
            titleLabel.text = labelText
        }

        
        // Draw the circle
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: lineWidth/2, y: lineWidth/2, width: self.bounds.size.width-lineWidth, height: self.bounds.size.width-lineWidth))
        theColor.setFill()
        ovalPath.fill()

    }

}
