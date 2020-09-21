//
//  ArtefactProperties+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension ArtefactProperties {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArtefactProperties> {
        return NSFetchRequest<ArtefactProperties>(entityName: "ArtefactProperties")
    }

    @NSManaged public var countdown: Bool
    @NSManaged public var delay: Float
    @NSManaged public var delayType: String?
    @NSManaged public var displayDuration: Float
    @NSManaged public var id: UUID?
    @NSManaged public var showDuration: Bool
    @NSManaged public var artefact: Artefact?
    @NSManaged public var expertimentalSession: ExperimentalSession?

}

extension ArtefactProperties : Identifiable {

}
