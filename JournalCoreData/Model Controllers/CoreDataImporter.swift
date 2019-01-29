//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entryRepresentations: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        self.context.perform {
            print(Date().description)
            let coreDataEntries = self.fetchEntriesFromPersistentStore(in: self.context)
            for entryRepresentation in entryRepresentations {
                guard let identifier = entryRepresentation.identifier else { continue }
                if let matchingCoreDataEntry = coreDataEntries?.filter({ $0.identifier == identifier }), let unwrappedCoreDataEntry = matchingCoreDataEntry.first {
                    self.update(entry: unwrappedCoreDataEntry, with: entryRepresentation)
                } else if coreDataEntries?.filter({ $0.identifier == identifier }) == nil {
                    _ = Entry(entryRepresentation: entryRepresentation, context: self.context)
                }
                
//                if let entry = entry(), entry != entryRep {
//                    self.update(entry: entry, with: entryRep)
//                } else if entry == nil {
//                    _ = Entry(entryRepresentation: entryRep, context: self.context)
//                }
            }
            print(Date().description)
            completion(nil)
        }
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    private func fetchEntriesFromPersistentStore(in context: NSManagedObjectContext) -> [Entry]? {
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        var result: [Entry]? = nil
        context.performAndWait {
        do {
            result = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        }
        return result
    }
    
    let context: NSManagedObjectContext
}
