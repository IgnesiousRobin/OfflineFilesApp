//
//  FolderViewModel.swift
//  OfflineFilesApp
//
//  Created by Ignesious Robin on 11/01/25.
//
import CoreData
import UIKit

class FolderViewModel {
    private let context = CoreDataStack.shared.context
    var folders: [FolderEntity] = []
    
    init() {
        fetchFolders()
    }
    
    // Add a folder
    func addFolder(name: String) {
        let folder = FolderEntity(context: context)
        folder.id = UUID()
        folder.name = name
        folder.isFavourite = false
        folder.colorIndex = 0
        folder.creationDate = Date()
        saveContext()
        fetchFolders()
    }
    
    // Add file to a folder
    func addFile(to folderID: UUID, fileName: String, fileData: Data) {
        if let folder = fetchFolder(by: folderID) {
            let folderFile = FileEntity(context: context)
            folderFile.id = UUID()
            folderFile.fileName = fileName
            folderFile.fileData = fileData
            folderFile.folder = folder
            
            saveContext()
        }
    }
    
    // Change folder color
    func changeFolderColor(folderID: UUID, to colorIndex: Int) {
        if let folder = fetchFolder(by: folderID) {
            folder.colorIndex = Int16(colorIndex)
            saveContext()
        }
    }
    
    // Toggle favorite
    func toggleFavourite(for folderID: UUID) {
        if let folder = fetchFolder(by: folderID) {
            folder.isFavourite.toggle()
            saveContext()
        }
    }
    
    // Sort folders
    func sortFolders(by option: SortOption) {
        switch option {
        case .name:
            folders.sort { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" }
        case .creationDate:
            folders.sort { $0.creationDate ?? Date() < $1.creationDate ?? Date() }
        }
    }
    
    // Fetch folders from Core Data
    private func fetchFolders() {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        
        do {
            folders = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch folders: \(error)")
        }
    }
    
    // Fetch a specific folder by ID
    private func fetchFolder(by id: UUID) -> FolderEntity? {
        let fetchRequest: NSFetchRequest<FolderEntity> = FolderEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch folder by ID: \(error)")
            return nil
        }
    }
    
    // Save context
    private func saveContext() {
        CoreDataStack.shared.saveContext()
    }
}

enum SortOption {
    case name
    case creationDate
}
