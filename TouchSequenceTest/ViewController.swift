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
    
    //Last Touch
    var lastTouch = UITouch()
    var maxVelocity:Double = 0.0
    var minVelocity:Double = 0.0

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
            lastTouch = touch
            lastPoint = touch.location(in: view)
            let green = UIColor.init(red: 167/255, green: 197/255, blue: 116/255, alpha: 1.0)
            addSequenceCount(atLocation: lastPoint, radius: 10, color:green)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if touches.count != 0{
            let touch = touches.first! as UITouch
            let currentPoint = touch.location(in: view)
            //Try Velocity
            let distanceBetween = distance(a: lastPoint, b: currentPoint)
            let timeBetween = touch.timestamp - lastTouch.timestamp
            //print(touch.timestamp)
            //print(lastTouch.timestamp)
            let velocity = Double(distanceBetween)/timeBetween
            //print("Distance:\(distanceBetween) Time:\(timeBetween) Velocity: \(velocity)")
            drawLineFrom(lastPoint, toPoint: currentPoint, withDistance: Double(distanceBetween))
            lastPoint = currentPoint
            lastTouch = touch
            
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint, withDistance: 0.0)
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
    
    func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
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
    
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint, withDistance:Double) {
        
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
        //context!.setStrokeColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)//Gray
        //context!.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)//Black

        //Record Velocity
        //Flat Yellow 247,203,87
        //Flat Red 229,77,66

        let redDiff = (withDistance/50) * (247-229)
        let greenDiff = (withDistance/50) * (203-77)
        let blueDiff = (withDistance/50) * (87-66)
        let redValue = CGFloat(247 - redDiff)/255
        let greenValue = CGFloat(203 - greenDiff)/255
        let blueValue = CGFloat(87 - blueDiff)/255
        
        context!.setStrokeColor(red: redValue, green:greenValue , blue: blueValue, alpha: 1.0)

        context!.setBlendMode(CGBlendMode.normal)
        
        // 4
        context!.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        //tempImageView.alpha = 0.0//Unhide this for production
        
        UIGraphicsEndImageContext()
    }


}

