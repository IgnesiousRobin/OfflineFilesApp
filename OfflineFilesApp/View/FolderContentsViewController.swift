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
    
    private let tableView = UITableView()
    private let addFileButton = UIButton(type: .system)
    private let addImageButton = UIButton(type: .system)
    
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
        
        setupViews()
        fetchItems()
    }
    
    private func setupViews() {
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        // Add Buttons
        addFileButton.setTitle("Add File", for: .normal)
        addFileButton.addTarget(self, action: #selector(addFile), for: .touchUpInside)
        
        addImageButton.setTitle("Add Image", for: .normal)
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [addFileButton, addImageButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        
        view.addSubview(buttonStack)
        
        // Layout
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func addFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    @objc private func addImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    private func fetchItems() {
        let fetchRequest: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folder == %@", folder)
        do {
            items = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    private func saveFile(url: URL) {
        let newItem = FileEntity(context: context)
        newItem.folder = folder
        newItem.fileType = "file"
        newItem.filePath = url.path
        saveContext()
        fetchItems()
    }
    
    private func saveImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let newItem = FileEntity(context: context)
        newItem.folder = folder
        newItem.fileName = "image"
        newItem.fileType = "image"
        newItem.fileData = imageData
        saveContext()
        fetchItems()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension FolderContentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if item.fileType == "file" {
            cell.textLabel?.text = URL(fileURLWithPath: item.filePath ?? "").lastPathComponent
        } else if item.fileType == "image" {
            cell.imageView?.image = UIImage(data: item.fileData ?? Data())
            cell.textLabel?.text = "Image"
        }
        return cell
    }
}

// MARK: - Document Picker Delegate
extension FolderContentsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        saveFile(url: url)
    }
}

// MARK: - Image Picker Delegate
extension FolderContentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            saveImage(image)
        }
    }
}
