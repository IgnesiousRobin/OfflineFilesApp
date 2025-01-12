//
//  FolderCollectionViewCell.swift
//  OfflineFilesApp
//
//  Created by Ignesious Robin on 11/01/25.
//

import UIKit

protocol FolderCollectionViewCellDelegate: AnyObject {
    func didTapFavourite(for folderID: UUID)
}

class FolderCollectionViewCell: UICollectionViewCell {
    static let identifier = "FolderCollectionViewCell"
    weak var delegate: FolderCollectionViewCellDelegate?
    private var folderID: UUID?
    private let colorView = UIView()
    private let nameLabel = UILabel()
    private let favouriteIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(colorView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(favouriteIcon)

        colorView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        favouriteIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: favouriteIcon.leadingAnchor, constant: -8),

            favouriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favouriteIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favouriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favouriteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupGestureRecognizers() {
        favouriteIcon.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFavouriteTap))
        favouriteIcon.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleFavouriteTap() {
        guard let folderID = folderID else { return }
        delegate?.didTapFavourite(for: folderID)
    }
    
    func configure(with folder: FolderEntity) {
        folderID = folder.id
        nameLabel.text = folder.name
        colorView.backgroundColor = FolderColors.colors[Int(folder.colorIndex)]
        favouriteIcon.image = UIImage(systemName: folder.isFavourite ? "star.fill" : "star")
        favouriteIcon.tintColor = folder.isFavourite ? .yellow : .gray
    }
}
