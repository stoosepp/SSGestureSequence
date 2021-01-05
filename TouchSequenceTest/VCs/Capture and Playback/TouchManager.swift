//
//  TouchManager.swift
//  TouchSequenceTest
//
//  Created by Stoo on 1/1/21.
//  Copyright © 2021 StooSepp. All rights reserved.
//

import Foundation

struct TouchFilterParameters{
	
}

class TouchManager{
	static let sharedInstance = TouchManager()
	
	func fetchAllTouches(forExperiment:Experiment,  completion: @escaping ([Touch])->()){
		let dataSets = forExperiment.dataSets?.allObjects as! [DataSet]
		var tempArray = [Touch]()
		for thisDataSet in dataSets{
			let thisTouchArray = thisDataSet.touches?.allObjects as! [Touch]
			tempArray.append(contentsOf: thisTouchArray)
		}

		print("There are now \(tempArray.count) touches to show ")
		let sortedTouches = tempArray.sorted(by: {$0.timeInterval < $1.timeInterval})
		completion(sortedTouches)
	}

	func fetchAllTouchesSeparatedbyStimuli(forExperiment:Experiment, completion:@escaping ([[Touch]])->()){
		fetchAllTouches(forExperiment: forExperiment) { (flatArray) in
			var tempArray = [[Touch]]()
			let stimuliArray = forExperiment.stimuli!.allObjects as! [Stimulus]
			for thisStimulus in stimuliArray{
				let thisStimuliTouchArray = flatArray.filter({return $0.stimulus == thisStimulus})
				tempArray.append(thisStimuliTouchArray)
			}
			completion(tempArray)
		}
	}
}


