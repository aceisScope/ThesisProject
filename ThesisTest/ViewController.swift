//
//  ViewController.swift
//  ThesisTest
//
//  Created by bhliu on 16/9/18.
//  Copyright © 2016年 Katze. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

     @IBOutlet weak var tableView: UITableView!
    
    var persistentContainer: NSPersistentContainer {
        return ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer)!
    }
    
    var backgroundContext: NSManagedObjectContext!
    var mainContext: NSManagedObjectContext!

    var fetchedResultsController: NSFetchedResultsController<Translog>!
    
    let actions = [0,1,2] // delete, update, subscribe

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundContext = persistentContainer.newBackgroundContext()
        mainContext = persistentContainer.viewContext
        mainContext.automaticallyMergesChangesFromParent = true

        createInitialDataSet()

         let fetchRequest: NSFetchRequest<Translog> = Translog.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
         fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
         fetchedResultsController.delegate = self
         _ = try? fetchedResultsController.performFetch()


        let startTime = CACurrentMediaTime()
        for i in  1...1000 {
            removeLogBasedOnID("\(Int(i))" as String)
        }
        let endTime = CACurrentMediaTime()
        print("total run time: \(endTime - startTime)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createInitialDataSet() {
        if UserDefaults.standard.bool(forKey: "Init") {
            return  // only once
        }

        let startTime = CACurrentMediaTime()
        
        persistentContainer.performBackgroundTask { context in
            for i in 1...2000 {
                let log = NSEntityDescription.insertNewObject(forEntityName: "Translog", into: context) as! Translog
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

        let endTime = CACurrentMediaTime()
        print("total run time: \(endTime - startTime)")
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "Init")
    }
    
    func fetchLogsBasedOnID(_ id: String) -> [Translog] {
        let predicate = NSPredicate(format: "id == %@",id)
        let request: NSFetchRequest<Translog> = Translog.fetchRequest()
        request.predicate = predicate
        do {
            let searchResults = try backgroundContext.fetch(request)
            return searchResults
        } catch {
            print("Error with request: \(error)")
        }

        return []
    }
    
    func removeLog(_ log: Translog) {
        do {
            backgroundContext.delete(log)
            try backgroundContext.save()
        } catch  {
            print("Error with request: \(error)")
        }
    }

    func removeLogBasedOnID(_ id: String)  {
        let predicate = NSPredicate(format: "id == %@",id)
        let request: NSFetchRequest<Translog> = Translog.fetchRequest()
        request.predicate = predicate

        let context: NSManagedObjectContext! = backgroundContext;
        context.performAndWait {
            let searchResults = try? context.fetch(request)
            if searchResults?.count == 0 {
                return
            }
            let log:Translog = searchResults!.first!

            context.delete(log)
            _ = try? context.save()
        }
    }

    func updateLog(_ log: Translog) {
        do {
            let action = Int16(Int(arc4random_uniform(3)))
            log.action = action
            if action == 1 {
                log.field = ""
            }
            log.date = NSDate()

            try backgroundContext.save()
        } catch {
            print("Error with request: \(error)")
        }
    }

    func updateLogBasedOnID(_ id: String) {
        let predicate = NSPredicate(format: "id == %@",id)
        let request: NSFetchRequest<Translog> = Translog.fetchRequest()
        request.predicate = predicate

        let context: NSManagedObjectContext! = backgroundContext;
        context.performAndWait {
            let searchResults = try? context.fetch(request)
            if searchResults?.count == 0 {
                return
            }
            let log:Translog = searchResults!.first!

            let action = Int16(Int(arc4random_uniform(3)))
            log.action = action
            if action == 1 {
                log.field = ""
            }
            log.date = NSDate()

            _ = try? context.save()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.sections != nil {
            return fetchedResultsController.sections![0].numberOfObjects
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)

        let log = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = log.id! + " \(log.action)"

        return cell
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //print("insert into \(newIndexPath?.row)")
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .none)
            break
        case .update:
            tableView.reloadRows(at: [newIndexPath!], with: .none)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .none)
            break
        default:
            break;
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .none)
            break
        case .delete:
            tableView.deleteSections([sectionIndex], with: .none)
            break
        default:
            break
        }
    }

}

