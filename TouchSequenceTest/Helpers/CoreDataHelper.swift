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
	func save(_ object:NSManagedObject){
		do {
			try self.context.save()
		} catch  {
			print(error)
		}
	}
	
	func delete(_ object:NSManagedObject){
		self.context.delete(object)
	}
	
	//Deal with startup NOT PRO USER
	func startupBasic(){
		let experiment = createExperiment()
		let dataSet = createDataSet()
		experiment.addToDataSets(dataSet)
		save(experiment)
		save(dataSet)
		print("Startup Basic Completed")
	}
	
	
	//Create Objects
	func createExperiment() -> Experiment{
		let experiment = Experiment(context: context)
		experiment.title = "Sample"
		save(experiment)
		return experiment
	}
	
	func createDataSet() -> DataSet{
		let dataSet = DataSet(context: context)
		dataSet.startDate = Date()
		save(dataSet)
		return dataSet
	}
	
	func createStimulus(rotation:Float, scale:CGFloat, xCenter:CGFloat, yCenter:CGFloat, image:UIImage?, url:URL?) -> Stimulus{
		let stimulus = Stimulus(context: CoreDataHelper.shared.context)
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
		save(stimulus)
		return stimulus
	}
	
	//Add Children
	func addStimulus(stimulus:Stimulus, experiment:Experiment){
		experiment.addToStimuli(stimulus)
		save(experiment)
	}
	

}
