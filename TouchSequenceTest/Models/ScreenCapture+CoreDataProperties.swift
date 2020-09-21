//
//  ScreenCapture+CoreDataProperties.swift
//  TouchSequenceTest
//
//  Created by Stoo on 21/9/20.
//  Copyright © 2020 StooSepp. All rights reserved.
//
//

import Foundation
import CoreData


extension ScreenCapture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScreenCapture> {
        return NSFetchRequest<ScreenCapture>(entityName: "ScreenCapture")
    }

    @NSManaged public var timeStamp: Date?
    @NSManaged public var image: Data?
    @NSManaged public var session: ExperimentalSession?

}

extension ScreenCapture : Identifiable {

}
