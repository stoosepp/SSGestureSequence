//
//  CircleButton.swift
//  FirebaseTest
//
//  Created by Stoo on 2016-09-22.
//  Copyright © 2016 StooSepp. All rights reserved.
//

import UIKit

protocol CircleButtonDelegate {
    func circleTapped(_ sender:CircleButton)
}

@IBDesignable

class CircleButton: UIView {

    @IBInspectable var showRing:Bool = true
    @IBInspectable var isnumberButton:Bool = false
    @IBInspectable var image:UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }

    @IBInspectable var labelText:String?{
        didSet{
            setNeedsDisplay()
        }
    }
 
    @IBInspectable var text:String?
    
    var selected:Bool = false
    var highlighted:Bool = false
    var index:Int = 0
    var lineWidth:CGFloat = 1{
        didSet{
            setNeedsDisplay()
        }
    }
    var strokeColor:UIColor = .black{
        didSet{
            setNeedsDisplay()
        }
    }

    
    //var imageView:UIImageView!
    var titleLabel:UILabel!
    var didDraw:Bool = false

    
    var delegate:CircleButtonDelegate?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
       
        backgroundColor = UIColor.clear
        
        if didDraw == false{
            titleLabel = UILabel()
            titleLabel.frame = self.bounds
            let adjustedFontSize = self.frame.size.height / 2
            titleLabel.font = titleLabel.font.withSize(adjustedFontSize)
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.black
            self.addSubview(titleLabel)
            if image != nil{
                let imageView = UIImageView()
                imageView.frame = self.bounds.insetBy(dx: 10, dy: 10)
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                imageView.image = image!
                self.addSubview(imageView)
            }
            didDraw = true
        }
       
        //Set Text and Imag, If they exist.
         if labelText != nil{
            titleLabel.text = labelText
        }
//        if image != nil{
//            imageView.image = image!
//        }
        
        // Drawing code
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: lineWidth/2, y: lineWidth/2, width: self.bounds.size.width-lineWidth, height: self.bounds.size.width-lineWidth))
        
        if showRing{
            strokeColor.setStroke()
            ovalPath.lineWidth = lineWidth
            ovalPath.stroke()
            if selected || highlighted{
                if image == nil{
                    UIColor.black.setFill()
                    ovalPath.fill()
                }
                else{
                    UIColor.lightGray.setFill()
                    ovalPath.fill()
                }
                
                titleLabel.textColor = UIColor.white
            }
            else{
                titleLabel.textColor = UIColor.black
                UIColor.white.setFill()
                ovalPath.fill()
            }
        }
        else{
            titleLabel.textColor = UIColor.black
        }
        //self.backgroundColor = UIColor.clearColor()
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlighted = true
        setNeedsDisplay()
        if delegate != nil{
            updateDelegate()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlighted = false
        
        if isnumberButton == false{
            if selected == true{
                selected = false
            }
            else{
                selected = true
            }
            
        }
        if delegate != nil{
            updateDelegate()
        }
        setNeedsDisplay()
    }
 
    func updateDelegate(){
        delegate?.circleTapped(self)
    }
 

}
