//
//  TouchCoreViewController.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/12/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

class TouchCoreViewController: UIViewController {

	var experiment:Experiment?
	var dataSet:DataSet?
	var stimuliArray = [Stimulus]()
	
	var stimuliSubViews = [UIView]()
	var currentIndex:Int = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor(named: "customBGColour")
        // Do any additional setup after loading the view.
    }
    
	//MARK:-CORE DATA STUFF
	
	func fetchStimuli() -> [Stimulus]{
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		var tempArray = [Stimulus]()
		do {
			var fetchRequest:NSFetchRequest<Stimulus>?
			fetchRequest = Stimulus.fetchRequest()
			if experiment != nil{
				fetchRequest!.predicate = NSPredicate(format: "%K == %@",#keyPath(Stimulus.experiment), experiment!)
			}
			tempArray = try context.fetch(fetchRequest!)
			tempArray.sort {
				$0.order < $1.order
			}
		}
		catch{
			print("There was an error")
		}
		return tempArray
	}
	
	func setupStimuli(atIndex:Int){
		let thisStimulus = stimuliArray[atIndex]
		let thisType = Int(thisStimulus.type)
		if thisType == StimulusType.kText{
			setupInstructionView(withText: thisStimulus.text)
		}
		else if thisType == StimulusType.kImage{
			setupImageView(forStimulus:thisStimulus)
		}
			//ELSE VIDEO
			//ELSE WEB VIEW
	}
	func setupInstructionView(withText:String?){
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.textColor = UIColor.label
		textView.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
		if withText != nil{
			textView.text = withText
		}
		super.view.addSubview(textView)
		super.view.sendSubviewToBack(textView)
		
		//Constraints
		let margins = self.view.layoutMarginsGuide
		textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
		textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 50).isActive = true
		textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -50).isActive = true
		textView.heightAnchor.constraint(equalToConstant: 300).isActive = true
		textView.isScrollEnabled = false
		textView.textAlignment = .center
		textView.isUserInteractionEnabled = false
		textView.isHidden = true
		stimuliSubViews.append(textView)
		
	}
	func setupImageView(forStimulus:Stimulus){
		
		let image = UIImage(data: forStimulus.imageData!)
		let newImageView = UIImageView()
		newImageView.image = image
		newImageView.frame = super.view.frame
		newImageView.contentMode = UIImageView.ContentMode.scaleAspectFit
		newImageView.removeAllConstraints()
		super.view.addSubview(newImageView)
		super.view.sendSubviewToBack(newImageView)
		
		newImageView.center = CGPoint(x: CGFloat(forStimulus.xCenter), y: CGFloat(forStimulus.yCenter))
		var transform = CGAffineTransform.identity
		transform = transform.rotated(by:CGFloat(forStimulus.rotation))
		transform = transform.scaledBy(x:CGFloat(forStimulus.scale),y:CGFloat(forStimulus.scale))
		newImageView.transform = transform
		newImageView.isHidden = true
		stimuliSubViews.append(newImageView)
	}
	
	func showStimuli(atIndex:Int){
		let thisType = Int(stimuliArray[atIndex].type)
		print("Showing Stimulus with type \(thisType)")
		for view in stimuliSubViews{
			view.isHidden = true
			if thisType == StimulusType.kText && view.isKind(of: UITextView.self) == true{
				view.isHidden = false
				print("Currently showing Text Instructions")
			}
			else if thisType == StimulusType.kImage && view.isKind(of: UIImageView.self) == true{
				view.isHidden = false
				print("Currently showing an Image")
			}
		}
	}
	func getStimuliIndexFrom(duration:TimeInterval, forStimuli:[Stimulus]) -> Int{
		var finalIndex = 0
		var thisDuration:Float = 0
		var nextDuration:Float = 0
		for index in 0..<forStimuli.count{
			if index == 0{
				thisDuration = 0
				nextDuration = forStimuli[index].duration
			}
			else{
				thisDuration = nextDuration
				nextDuration = forStimuli[index].duration + thisDuration
			}
			if duration.isBetween(time1: Double(thisDuration), time2: Double(nextDuration)) == true{
				finalIndex = index
				break
			}
		}
		return finalIndex
	}
	func getDurationFrom(stimulusIndex:Int, inStimulusArray:[Stimulus]) ->TimeInterval{
		var duration:Float = 0.0
		var thisDuration:Float = 0
		var nextDuration:Float = 0
		for index in 0..<inStimulusArray.count{
			if index == 0{
				thisDuration = 0
				nextDuration = inStimulusArray[index].duration
			}
			else{
				thisDuration = nextDuration
				nextDuration = inStimulusArray[index].duration + thisDuration
			}
			if index == stimulusIndex{
				duration = thisDuration
				break
			}
		}
		
		return TimeInterval(duration)
	}



}
