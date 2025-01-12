//
//  ViewController.swift
//  OfflineFilesApp
//
//  Created by Ignesious Robin on 10/01/25.
//

import UIKit

class ViewController: UIViewController {
    private var viewModel = FolderViewModel()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 80)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Date", "Name"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let createFolderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Folder", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Folders"
        view.backgroundColor = .white
        
        setupViews()
        setupActions()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(createFolderButton)
        view.addSubview(collectionView)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        createFolderButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Segmented Control Constraints
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Create Folder Button Constraints
            createFolderButton.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            createFolderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createFolderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createFolderButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Collection View Constraints
            collectionView.topAnchor.constraint(equalTo: createFolderButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(FolderCollectionViewCell.self, forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupActions() {
        createFolderButton.addTarget(self, action: #selector(addFolder), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(sortFolders), for: .valueChanged)
    }
    
    func presentColorPicker(for folderID: UUID) {
        let alert = UIAlertController(title: "Choose a Color", message: nil, preferredStyle: .actionSheet)
        let colorNames = ["Default", "Red", "Green", "Yellow", "Purple"]
        
        for (index, name) in colorNames.enumerated() {
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                self.viewModel.changeFolderColor(folderID: folderID, to: index)
                self.collectionView.reloadData()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func addFolder() {
        let alert = UIAlertController(title: "Add New Folder", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Folder Name" }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self?.viewModel.addFolder(name: name)
            self?.collectionView.reloadData()
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func sortFolders() {
        let option: SortOption = segmentedControl.selectedSegmentIndex == 0 ? .creationDate : .name
        viewModel.sortFolders(by: option)
        collectionView.reloadData()
    }
    
    @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            let folder = viewModel.folders[indexPath.item]
            if let id = folder.id {
                presentColorPicker(for: id)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        cell.configure(with: viewModel.folders[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let folder = viewModel.folders[indexPath.item]
        let folderContentsVC = FolderContentsViewController(folder: folder)
        
        if let navController = navigationController {
            navController.pushViewController(folderContentsVC, animated: true)
        } else {
            print("Navigation controller is nil")
        }
    }
}

extension ViewController: FolderCollectionViewCellDelegate {
    func didTapFavourite(for folderID: UUID) {
        viewModel.toggleFavourite(for: folderID)
        collectionView.reloadData()
    }
}
