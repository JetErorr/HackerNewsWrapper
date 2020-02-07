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
//    DispatchQueue.main.async {
    let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
//    }

    func checkSaved(_ itemID: Int) -> Bool {

        let savedIDs = getSavedIDs()

        // check if it contains itemID
        for IDs in savedIDs where IDs == itemID { return true }
        return false
    }

    func addToSaved(_ itemID: Int) {
        print("Adding")
        // Add itemID to the db

        let newEntry = NSEntityDescription.insertNewObject(forEntityName: "NewsID", into: context)

        newEntry.setValue(itemID, forKey: "savedID")

        do {
            try context.save()
        } catch {
            print("Cannot add new SavedID into the SavedID")
        }
    }

    func removeFromSaved(_ itemID: Int) {
        print("Removing")
        // Remove itemID from db

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsID")
        fetchRequest.predicate = NSPredicate(format: "savedID == %d", itemID)

        do {
            let test = try context.fetch(fetchRequest)

            let objToDel = test[0] as! NSManagedObject

            context.delete(objToDel)

            do {
                try context.save()
            } catch {
                print("Cannot add new SavedID into the SavedID")
            }

        } catch {
            print("Cannot find the deletion object")
        }
    }

    func getSavedIDs() -> [Int] {
        // loop through all savedIDs
//        DispatchQueue.main.async {
            var ret: [Int] = []

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsID")

            do {
                let result = try context.fetch(fetchRequest)
                var IDs = 0
                print("Local Story Count: ", result.count)
                for res in result as! [NSManagedObject] {

                    IDs = res.value(forKey: "savedID") as! Int

                    ret.append(IDs)
                }
            } catch {
                print("Couldn't fetch saved indices")
            }
            return ret
//        }
    }
}
