//
//  Study+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension Study {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Study> {
        return NSFetchRequest<Study>(entityName: "Study")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var details: String?
    @NSManaged public var name: String?
    @NSManaged public var expSessions: NSSet?

}

// MARK: Generated accessors for expSessions
extension Study {

    @objc(addExpSessionsObject:)
    @NSManaged public func addToExpSessions(_ value: ExperimentalSession)

    @objc(removeExpSessionsObject:)
    @NSManaged public func removeFromExpSessions(_ value: ExperimentalSession)

    @objc(addExpSessions:)
    @NSManaged public func addToExpSessions(_ values: NSSet)

    @objc(removeExpSessions:)
    @NSManaged public func removeFromExpSessions(_ values: NSSet)

}

extension Study : Identifiable {

}
