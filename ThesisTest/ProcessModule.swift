//
//  ProcessModule.swift
//  ThesisTest
//
//  Created by bhliu on 16/10/7.
//  Copyright © 2016年 XXX Oy. All rights reserved.
//

import UIKit
import CoreData

class ProcessModule: NSObject {
    static let sharedInstance = ProcessModule()
    
    func verifyTransactionFromServer(_ sTransaction:AnyObject, objectID: String, inContext:NSManagedObjectContext) -> Bool {
        let logs = fetchLogsBasedOnID(objectID, inContext: inContext)
        for log in logs {
            // process server transaction again the logs 
            // if the log in the Log table can be removed
            removeLog(log, inContext: inContext)
            return true
            // else
            updateLog(log, inContext: inContext)
            return false
        }
        return false
    }
    
    
    func fetchLogsBasedOnID(_ id: String, inContext:NSManagedObjectContext) -> [Translog] {
        let predicate = NSPredicate(format: "id == %@",id)
        let request: NSFetchRequest<Translog> = Translog.fetchRequest()
        request.predicate = predicate
        do {
            let searchResults = try inContext.fetch(request)
            return searchResults
        } catch {
            print("Error with request: \(error)")
        }
        
        return []
    }
    
    func removeLog(_ log: Translog, inContext: NSManagedObjectContext) {
        do {
            inContext.delete(log)
            try inContext.save()
        } catch  {
            print("Error with request: \(error)")
        }
    }
    
    func updateLog(_ log: Translog, inContext: NSManagedObjectContext) {
        do {
            // update log according to the rules
            try inContext.save()
        } catch {
            print("Error with request: \(error)")
        }
    }
}
