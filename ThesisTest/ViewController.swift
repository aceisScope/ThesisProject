//
//  ViewController.swift
//  ThesisTest
//
//  Created by bhliu on 16/9/18.
//  Copyright © 2016年 Katze. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var persistentContainer: NSPersistentContainer {
        return ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer)!
    }
    
    var backgroundContext: NSManagedObjectContext!
    var mainContext: NSManagedObjectContext!
    
    let actions = [0,1,2] // delete, update, subscribe

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundContext = persistentContainer.newBackgroundContext()
        mainContext = persistentContainer.viewContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createInitialDataSet() {
        if UserDefaults.standard.bool(forKey: "Init") {
            return  // only once
        }
        
        persistentContainer.performBackgroundTask { context in
            for i in 1...2000 {
                let log = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context) as! Translog
                log.id = "\(i)"
                let action = Int16(Int(arc4random_uniform(3)))
                log.action = action
                if action == 1 {
                    log.field = ""
                }
                log.date = NSDate()
            }
            
            _ = try? context.save()
        }
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "Init")
    }
    
    func fetchRecordsBasedOnID(_ id: NSString) {
        let predicate = NSPredicate(format: "objectID == %@",id)
        let request: NSFetchRequest<Translog> = Translog.fetchRequest()
        request.predicate = predicate
        do {
            let searchResults = try backgroundContext.fetch(request)
            print(searchResults)
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    
}

