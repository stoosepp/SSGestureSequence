//
//  Project+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var details: String?
    @NSManaged public var name: String?
    @NSManaged public var expSessions: NSSet?

}

// MARK: Generated accessors for expSessions
extension Project {

    @objc(addExpSessionsObject:)
    @NSManaged public func addToExpSessions(_ value: ExperimentalSession)

    @objc(removeExpSessionsObject:)
    @NSManaged public func removeFromExpSessions(_ value: ExperimentalSession)

    @objc(addExpSessions:)
    @NSManaged public func addToExpSessions(_ values: NSSet)

    @objc(removeExpSessions:)
    @NSManaged public func removeFromExpSessions(_ values: NSSet)

}

extension Project : Identifiable {

}
