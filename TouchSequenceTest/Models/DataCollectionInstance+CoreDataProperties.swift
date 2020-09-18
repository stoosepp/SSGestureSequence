//
//  DataCollectionInstance+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension DataCollectionInstance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataCollectionInstance> {
        return NSFetchRequest<DataCollectionInstance>(entityName: "DataCollectionInstance")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var participant: Participant?
    @NSManaged public var touches: NSSet?
    @NSManaged public var expermientalSession: ExperimentalSession?

}

// MARK: Generated accessors for touches
extension DataCollectionInstance {

    @objc(addTouchesObject:)
    @NSManaged public func addToTouches(_ value: Touch)

    @objc(removeTouchesObject:)
    @NSManaged public func removeFromTouches(_ value: Touch)

    @objc(addTouches:)
    @NSManaged public func addToTouches(_ values: NSSet)

    @objc(removeTouches:)
    @NSManaged public func removeFromTouches(_ values: NSSet)

}

extension DataCollectionInstance : Identifiable {

}
