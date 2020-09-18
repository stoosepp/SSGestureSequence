//
//  ExperimentalSession+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension ExperimentalSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExperimentalSession> {
        return NSFetchRequest<ExperimentalSession>(entityName: "ExperimentalSession")
    }

    @NSManaged public var details: String?
    @NSManaged public var portrait: Bool
    @NSManaged public var artefactSequence: NSObject?
    @NSManaged public var artefactProperties: NSSet?
    @NSManaged public var dataCollections: NSSet?
    @NSManaged public var project: Project?

}

// MARK: Generated accessors for artefactProperties
extension ExperimentalSession {

    @objc(addArtefactPropertiesObject:)
    @NSManaged public func addToArtefactProperties(_ value: ArtefactProperties)

    @objc(removeArtefactPropertiesObject:)
    @NSManaged public func removeFromArtefactProperties(_ value: ArtefactProperties)

    @objc(addArtefactProperties:)
    @NSManaged public func addToArtefactProperties(_ values: NSSet)

    @objc(removeArtefactProperties:)
    @NSManaged public func removeFromArtefactProperties(_ values: NSSet)

}

// MARK: Generated accessors for dataCollections
extension ExperimentalSession {

    @objc(addDataCollectionsObject:)
    @NSManaged public func addToDataCollections(_ value: DataCollectionInstance)

    @objc(removeDataCollectionsObject:)
    @NSManaged public func removeFromDataCollections(_ value: DataCollectionInstance)

    @objc(addDataCollections:)
    @NSManaged public func addToDataCollections(_ values: NSSet)

    @objc(removeDataCollections:)
    @NSManaged public func removeFromDataCollections(_ values: NSSet)

}

extension ExperimentalSession : Identifiable {

}
