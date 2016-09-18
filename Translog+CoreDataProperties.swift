//
//  Translog+CoreDataProperties.swift
//  ThesisTest
//
//  Created by bhliu on 16/9/18.
//  Copyright © 2016年 Katze. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Translog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Translog> {
        return NSFetchRequest<Translog>(entityName: "Translog");
    }

    @NSManaged public var id: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var action: Int16
    @NSManaged public var field: String?

}
