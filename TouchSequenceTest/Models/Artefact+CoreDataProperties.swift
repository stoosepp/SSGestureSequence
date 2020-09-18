//
//  Artefact+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 18/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension Artefact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artefact> {
        return NSFetchRequest<Artefact>(entityName: "Artefact")
    }

    @NSManaged public var rotation: Float
    @NSManaged public var scale: Float
    @NSManaged public var xCenter: Float
    @NSManaged public var yCenter: Float
    @NSManaged public var artifact: Data?
    @NSManaged public var properties: ArtefactProperties?

}

extension Artefact : Identifiable {

}
