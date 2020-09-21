//
//  Participant+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension Participant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Participant> {
        return NSFetchRequest<Participant>(entityName: "Participant")
    }

    @NSManaged public var participantID: String?
    @NSManaged public var dataCollection: DataCollectionInstance?

}

extension Participant : Identifiable {

}
