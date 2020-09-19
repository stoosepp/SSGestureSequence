//
//  DemoFactory.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import UIKit
import CoreData

class DemoFactory: NSObject {
	
	var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    public func fetchData() {
		//Check to see if there is data, if not create data
		var projects:[Project]?
		do {
			projects = try context.fetch(Project.fetchRequest())
			print("There are \(projects!.count) Projects")
		} catch  {
			print("There are No Projects")
			createData()
		}
		
    }
    public func createData(){
        let newProject = Project(context: context)
		newProject.name = "Maths Tracing Study"
		newProject.details = "This study is all about exploring how kids learn geometry on an iPad"
		newProject.dateCreated = Date()
		
		
		let newSession = ExperimentalSession(context: context)
		newSession.portrait = true
		newSession.details = "This session is all about blah blah blah"
		//Set relationships
		newSession.project = newProject
		
		do {
			try self.context.save()
		} catch  {
			print("There was an error")
		}
		
	
    }
    
}
