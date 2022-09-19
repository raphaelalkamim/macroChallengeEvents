//
//  RoadmapLocal+CoreDataClass.swift
//  
//
//  Created by Carolina Ortega on 13/09/22.
//
//

import Foundation
import CoreData

@objc(RoadmapLocal)
public class RoadmapLocal: NSManagedObject {
    static let shared: RoadmapLocal = RoadmapLocal()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "macroChallengeApp")
        container.loadPersistentStores { _, error in
            if let erro = error {
                preconditionFailure(erro.localizedDescription)
            }
            
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Problema de contexto: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createRoadmap(roadmap: Roadmaps, user: User) -> RoadmapLocal {
        guard let newRoadmap = NSEntityDescription.insertNewObject(forEntityName: "RoadmapLocal", into: context) as? RoadmapLocal else { preconditionFailure() }
        
        newRoadmap.id = roadmap.id
        newRoadmap.name = roadmap.name
        newRoadmap.location = roadmap.location
        newRoadmap.budget = roadmap.budget
        newRoadmap.dayCount = roadmap.dayCount
        newRoadmap.peopleCount = roadmap.peopleCount
        newRoadmap.imageId = roadmap.imageId
        newRoadmap.category = roadmap.category
        newRoadmap.isShared = roadmap.isShared
        newRoadmap.isPublic = roadmap.isPublic
        newRoadmap.shareKey = roadmap.shareKey
        newRoadmap.addToUser(user)
        
        self.saveContext()
        return newRoadmap
    }
    
    func getRoadmap() -> [RoadmapLocal] {
        let fr = NSFetchRequest<Devocionais>(entityName: "RoadmapLocal")
        do {
            return try self.persistentContainer.viewContext.fetch(fr)
        } catch {
            print(error)
        }
        return []
    }
    
    func deleteRoadmap(roadmap: RoadmapLocal) throws {
        self.persistentContainer.viewContext.delete(roadmap)
        self.saveContext()
    }
    
}
