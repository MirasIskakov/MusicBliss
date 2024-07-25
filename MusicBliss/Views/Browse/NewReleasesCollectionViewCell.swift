//
//  NewReleasesCollectionViewCell.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 23.07.2024.
//

import UIKit
import SDWebImage

class NewReleasesCollectionViewCell: UICollectionViewCell {
  static let identifier = "NewReleasesCollectionViewCell"

  private let albumCoverImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "photo")
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private var albumNameLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.font = .systemFont(ofSize: 22, weight: .semibold)
    return label
  }()

  private var numberOfTracksLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 18, weight: .light)
    return label
  }()

  private var artistNameLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 18, weight: .regular)
    return label
  }()


  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = .secondarySystemBackground
    contentView.addSubview(albumCoverImageView)
    contentView.addSubview(albumNameLabel)
    contentView.addSubview(numberOfTracksLabel)
    contentView.addSubview(artistNameLabel)

  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let imageSize: CGFloat = contentView.height-10
    let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width-imageSize-10, height: contentView.height-10))
    artistNameLabel.sizeToFit()
    numberOfTracksLabel.sizeToFit()

    albumCoverImageView.frame = CGRect(
      x: 5,
      y: 5,
      width: imageSize,
      height: imageSize)

    albumNameLabel.frame = CGRect(
      x: albumCoverImageView.right+10,
      y: 5,
      width: albumLabelSize.width,
      height: min(80, albumLabelSize.height)
    )

    artistNameLabel.frame = CGRect(
      x: albumCoverImageView.right+10,
      y: albumNameLabel.bottom+5,
      width: albumLabelSize.width,
      height: min(80, albumLabelSize.height)
    )

    numberOfTracksLabel.frame = CGRect(
      x: albumCoverImageView.right+10,
      y: albumCoverImageView.bottom-50,
      width: numberOfTracksLabel.width,
      height: 50)
  }


  override func prepareForReuse() {
    super.prepareForReuse()
    albumNameLabel.text = nil
    artistNameLabel.text = nil
    numberOfTracksLabel.text = nil
    albumCoverImageView.image = nil
  }

  func configure(with viewModel: NewReleasesCellViewModel) {
    albumNameLabel.text = viewModel.name
    artistNameLabel.text = viewModel.artistName
    numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
    albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
  }

}
