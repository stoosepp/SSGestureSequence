//
//  CoreDataHelper.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//

import CoreData
import UIKit

public class CoreDataHelper{
	
	static let shared = CoreDataHelper()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	
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
}
