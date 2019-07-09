//
//  SearchHistory+CoreDataClass.swift
//  
//
//  Created by Thanh-Nhon Nguyen on 09/07/2019.
//
//

import Foundation
import CoreData

@objc(SearchHistory)
public class SearchHistory: NSManagedObject {
    func moveToTop(withManagedContext managedContext: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: managedContext)!
        let temp = SearchHistory(entity: entity, insertInto: managedContext)
        temp.nameOrTitle = nameOrTitle
        temp.objectType = objectType
        temp.searchType = searchType
        temp.term = term
        temp.thumbnailUrlString = thumbnailUrlString
        temp.urlString = urlString
        
        managedContext.delete(self)
        
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    class func checkAndInsert(withManagedContext managedContext: NSManagedObjectContext, urlString: String, nameOrTitle: String, thumbnailUrlString: String?, objectType: SearchResultObjectType) {
        guard !moveToTopIfExist(withManagedContext: managedContext, urlString: urlString) else {
            return
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: managedContext)!
        let searchHistory = SearchHistory(entity: entity, insertInto: managedContext)
        searchHistory.nameOrTitle = nameOrTitle
        searchHistory.thumbnailUrlString = thumbnailUrlString
        searchHistory.objectType = Int16(objectType.rawValue)
        searchHistory.urlString = urlString
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private class func moveToTopIfExist(withManagedContext managedContext: NSManagedObjectContext, urlString: String) -> Bool {
        let fetchRequest = NSFetchRequest<SearchHistory>(entityName: "SearchHistory")
        fetchRequest.predicate = NSPredicate(format: "urlString == %@", urlString)
        
        var entities: [SearchHistory] = []
        
        do {
            entities = try managedContext.fetch(fetchRequest)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if entities.count == 1 {
            let searchHistory = entities[0]
            searchHistory.moveToTop(withManagedContext: managedContext)
        }
        
        return entities.count > 0
    }
}
