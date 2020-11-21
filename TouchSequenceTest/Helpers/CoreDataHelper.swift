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
			try self.context.save()
		} catch  {
			print(error)
		}
	}
	
	func delete(_ object:NSManagedObject){
		self.context.delete(object)
		saveContext()
	}
	
	//Deal with startup NOT PRO USER
	func startupBasic(){
		let experiment = createExperiment()
		let dataSet = createDataSet()
		experiment.addToDataSets(dataSet)
		saveContext()
		print("Startup Basic Completed")
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
		saveContext()
	}
	
	func createStimulus(rotation:Float, scale:CGFloat, xCenter:CGFloat, yCenter:CGFloat, image:UIImage?, url:URL?) -> Stimulus{
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
	}
	
	func createTouchfromUITouchWithFinger(dataSet:DataSet, touch:UITouch, finger:Int64, isPencil:Bool, inView:UIView) -> Touch{
		let newTouch = Touch(context: context)
		newTouch.timeInterval = Date().timeIntervalSince(dataSet.startDate!)
		newTouch.finger = finger
		newTouch.isPencil = isPencil
		let location = touch.location(in: inView)
		newTouch.xLocation = Float(location.x)
		newTouch.yLocation = Float(location.y)
		newTouch.touchType = Int64(Int(touch.phase.rawValue))
		
		return newTouch
	}
	
	
	
	
	//MARK: - ADD CHILDREN
	func addStimulus(stimulus:Stimulus, experiment:Experiment){
		experiment.addToStimuli(stimulus)
		saveContext()
	}
	
	func addScreenShot(screenShot:ScreenShot, dataSet:DataSet){
		dataSet.addToScreenShots(screenShot)
		saveContext()
	}
	


	

}
