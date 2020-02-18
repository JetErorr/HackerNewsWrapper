//
//  SaveService.swift
//  HackerNewsWrapper
//
//  Created by Jeet on 06/02/20.
//  Copyright © 2020 Jeet. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SaveService {
    //swiftlint:disable force_cast
    let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    let entity = "NewsID"
    let key = "savedID"

    func checkSaved(_ itemID: Int) -> Bool {

        let savedIDs = getSavedIDs()

        // check if it contains itemID
        for IDs in savedIDs where IDs == itemID { return true }
        return false
    }

    func addToSaved(_ itemID: Int) {
        // Add itemID to the db

        let newEntry = NSEntityDescription.insertNewObject(forEntityName: entity, into: context)

        newEntry.setValue(itemID, forKey: key)

        do {
            try context.save()
        } catch {
            print("Cannot add ID into the SavedID")
        }
    }

    func removeFromSaved(_ itemID: Int) {
        // Remove itemID from db

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "\(key) == %d", itemID)

        do {
            let test = try context.fetch(fetchRequest)

            let objToDel = test[0] as! NSManagedObject

            context.delete(objToDel)

            do {
                try context.save()
            } catch {
                print("Cannot add ID into the SavedID")
            }
        } catch {
            print("Cannot find the deletion object")
        }
    }

    func getSavedIDs() -> [Int] {
        // loop through all savedIDs

        var ret: [Int] = []

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)

        do {
            let result = try context.fetch(fetchRequest)
            var IDs = 0
            for res in result as! [NSManagedObject] {

                IDs = res.value(forKey: key) as! Int

                ret.append(IDs)
            }
        } catch {
            print("Couldn't fetch saved indices")
        }
        return ret
    }
}
