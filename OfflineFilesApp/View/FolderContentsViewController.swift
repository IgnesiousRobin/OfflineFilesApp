//
//  FolderContentsViewController.swift
//  OfflineFilesApp
//
//  Created by Ignesious Robin on 12/01/25.
//

import UIKit
import CoreData

class FolderContentsViewController: UIViewController {
    
    private var folder: FolderEntity
    private var context: NSManagedObjectContext!
    private var items: [FileEntity] = []
    
    init(folder: FolderEntity, context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.folder = folder
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = folder.name
        view.backgroundColor = .white
    }
}
