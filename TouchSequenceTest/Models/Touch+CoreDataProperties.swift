//
//  Touch+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension Touch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Touch> {
        return NSFetchRequest<Touch>(entityName: "Touch")
    }

    @NSManaged public var timeStamp: Date?
    @NSManaged public var touchType: String?
    @NSManaged public var xLocation: Float
    @NSManaged public var yLocation: Float
    @NSManaged public var dataCollectionInstance: DataCollectionInstance?

}

extension Touch : Identifiable {

}
