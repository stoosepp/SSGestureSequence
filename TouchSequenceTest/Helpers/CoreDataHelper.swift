//
//  CoreDataHelper.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData


public class CoreDataHelper{
	
	static let shared = CoreDataHelper()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	//Saving and Deleting
	func saveContext(){
		do {
			if context.hasChanges == true{
				try self.context.save()
				print("COREDATA: Saved")
			}
			else{
				print("COREDATA: No changes, but save called")
			}
		} catch  {
			print(error)
		}
	}
	
	func delete(_ object:NSManagedObject){
		self.context.delete(object)
		self.saveContext()
	}
	

	
	//MARK: - FETCH{
	
	
	
	//MARK: - CREATE
	func createExperiment() -> Experiment{
		let experiment = Experiment(context: context)
		saveContext()
		return experiment
	}
	
	func createDataSet() -> DataSet{
		let dataSet = DataSet(context: context)
		dataSet.startDate = Date()
		saveContext()
		return dataSet
	}
	
	func createScreenShot(_ withImage:UIImage?) -> ScreenShot{
		let screenShot = ScreenShot(context:context)
		screenShot.imageData = withImage?.pngData()
		screenShot.timeStamp = Date()
		saveContext()
		return screenShot
	}
	
	func addBlankStimulus(toExperiment:Experiment, withDuration:Float){
		let stimulus = Stimulus(context: context)
		stimulus.duration = withDuration
		stimulus.type = 0
		let stimulusCount = toExperiment.stimuli?.count
		stimulus.order = Int16(stimulusCount!)
		toExperiment.addToStimuli(stimulus)
		stimulus.experiment = toExperiment
		saveContext()
	}
	
	/*func createStimulus(rotation:Float, scale:CGFloat, xCenter:CGFloat, yCenter:CGFloat, image:UIImage?, url:URL?) -> Stimulus{
		let stimulus = Stimulus(context: context)
		stimulus.rotation = rotation
		stimulus.scale = Float(scale)
		stimulus.xCenter = Float(xCenter)
		stimulus.yCenter = Float(yCenter)
		
		if image != nil{
			stimulus.imageData = image!.pngData()
		}
		if url != nil{
			stimulus.url = String(describing: url)
		}
		saveContext()
		return stimulus
	}*/
	
	func createTouchfromUITouchWith(dataSet:DataSet, stimulus:Stimulus, touch:UITouch, finger:Int64, isPencil:Bool, inView:UIView) -> Touch{
		let newTouch = Touch(context: context)
		newTouch.timeInterval = Date().timeIntervalSince(dataSet.startDate!)
		newTouch.finger = finger
		newTouch.isPencil = isPencil
		let location = touch.location(in: inView)
		newTouch.xLocation = Float(location.x)
		newTouch.yLocation = Float(location.y)
		newTouch.touchPhase = Int64(Int(touch.phase.rawValue))
		newTouch.dataSet = dataSet
		newTouch.stimulus = stimulus
		return newTouch
	}
	
	
}
