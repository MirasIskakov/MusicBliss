//
//  HomeViewController.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import UIKit
//Featured Playlist, Recommendation Tracks, New Releases
enum BrowseSectionType {
  case newReleases
  case featuredPlaylist
  case recommendationTracks
}

class HomeViewController: UIViewController {

  private lazy var collectionView: UICollectionView = {
          let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
              return self?.createSectionLayout(section: sectionIndex)
          }
          let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

          return collectionView
      }()

  private let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView()
    spinner.tintColor = .label
    spinner.hidesWhenStopped = true
    return spinner
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Browse"
    view.backgroundColor = .systemBackground
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(didTapSettings))


    configureCollectionView()
    view.addSubview(spinner)
    fetchData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }

  private func configureCollectionView() {
    view.addSubview(collectionView)
    collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .systemBackground
  }

  private func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
    switch section {
    case 0:
      //Item
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)
        )
      )
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      // verticalGroup
      let verticalGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(390)
        ),
        subitem: item,
        count: 3
      )

      //horizontalGroup
      let horizontalGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(0.9),
          heightDimension: .absolute(390)
        ),
        subitem: verticalGroup,
        count: 1
      )

      //Section
      let section = NSCollectionLayoutSection(group: horizontalGroup)
      section.orthogonalScrollingBehavior = .groupPaging
      return section


    case 1:
      //Item
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(250),
          heightDimension: .absolute(250)
        )
      )
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      // verticalGroup
      let verticalGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(200),
          heightDimension: .absolute(300)
        ),
        subitem: item,
        count: 2
      )

      //horizontalGroup
      let horizontalGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(200),
          heightDimension: .absolute(300)
        ),
        subitem: verticalGroup,
        count: 1
      )

      //Section
      let section = NSCollectionLayoutSection(group: horizontalGroup)
      section.orthogonalScrollingBehavior = .continuous
      return section


    case 2:
      //Item
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)
        )
      )
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      // verticalGroup
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(80)
        ),
        subitem: item,
        count: 1
      )

      //Section
      let section = NSCollectionLayoutSection(group: group)
      return section


    default:
      //Item
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(1.0)
        )
      )
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      // verticalGroup
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(390)
        ),
        subitem: item,
        count: 1
      )
      //Section
      let section = NSCollectionLayoutSection(group: group)
            return section

    }
  }

  private func fetchData() {
    //Featured Playlist, Recommendation Tracks, New Releases
    APICaller.shared.getRecommendedGenres { result in
      switch result {
      case .success(let model):
        let genres = model.genres
        var seeds = Set<String>()
        while seeds.count < 5 {
          if let random = genres.randomElement() {
            seeds.insert(random)
          }
        }

        APICaller.shared.getRecommendations(genres: seeds) { _ in
          
        }
      case .failure(let error): break
      }

    }
  }

  @objc func didTapSettings() {
    let vc = SettingsViewController()
    vc.title = "Profile"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 6
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 3
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    if indexPath.section == 0 {
      cell.backgroundColor = .systemGreen
    }
    else if indexPath.section == 1 {
      cell.backgroundColor = .systemPink
    }
    else if indexPath.section == 2 {
      cell.backgroundColor = .systemBlue
    }
    return cell
  }
}
