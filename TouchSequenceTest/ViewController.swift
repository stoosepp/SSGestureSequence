//
//  ViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 2017-01-12.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var currentTouch = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - DRAWING CODE
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouch += 1
        swiped = false
        if touches.count != 0{
            let touch = touches.first! as UITouch
            lastPoint = touch.location(in: self.view)
            let green = UIColor.init(red: 167/255, green: 197/255, blue: 116/255, alpha: 1.0)
            addSequenceCount(atLocation: lastPoint, radius: 10, color:green)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if touches.count != 0{
            let touch = touches.first! as UITouch
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        let red = UIColor.init(red: 190/255, green: 75/255, blue: 85/255, alpha: 1.0)
        addSequenceCount(atLocation: lastPoint, radius: 10, color:red)
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tempImageView.image = nil
     
    }
    
    func addSequenceCount(atLocation:CGPoint, radius:CGFloat, color:UIColor){
      
        let circleView = CircleButton(frame: CGRect(x: atLocation.x - radius, y: atLocation.y - radius , width: radius * 2, height: radius * 2))
        circleView.showRing = true
        circleView.labelText = "\(currentTouch)"
        circleView.lineWidth = 4.0
        circleView.strokeColor = color
        circleView.backgroundColor = UIColor.clear
        tempImageView.insertSubview(circleView, at: 10)

    }
    
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        // 3
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(5.0)
        context!.setStrokeColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        context!.setBlendMode(CGBlendMode.normal)
        
        // 4
        context!.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 0.0
        
        UIGraphicsEndImageContext()
    }


}

