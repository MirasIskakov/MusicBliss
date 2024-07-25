//
//  HomeViewController.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import UIKit
//Featured Playlist, Recommendation Tracks, New Releases
enum BrowseSectionType {
  case newReleases(viewModel: [NewReleasesCellViewModel])
  case featuredPlaylist(viewModel: [NewReleasesCellViewModel])
  case recommendationTracks(viewModel: [NewReleasesCellViewModel])
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

  private var sections = [BrowseSectionType]()

  // MARK: - viewDidLoad
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
    collectionView.register(NewReleasesCollectionViewCell.self, forCellWithReuseIdentifier: NewReleasesCollectionViewCell.identifier)
    collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
    collectionView.register(RecommendationTracksCollectionViewCell.self, forCellWithReuseIdentifier: RecommendationTracksCollectionViewCell.identifier)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .systemBackground
  }

  //MARK: - fetchData
  private func fetchData() {
    let group = DispatchGroup()
    group.enter()
    group.enter()
    group.enter()

    var newReleases: NewReleasesResponse?
    var featuredPlaylists: FeaturedPlaylistResponse?
    var recommendations: RecommendationsResponse?

    //New Releases
    APICaller.shared.getNewReleases { result in
      defer {
        group.leave()
      }
      switch result {
      case .success(let model):
        newReleases = model
      case .failure(let error):
        print(error.localizedDescription)
      }
    }

    //Featured Playlist,
    APICaller.shared.getFeaturedPlaylists { result in
      defer {
        group.leave()
      }
      switch result {
      case .success(let model): 
        featuredPlaylists = model
      case .failure(let error):
        print(error.localizedDescription)
      }
    }

    //Recommendation Tracks
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

        APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
          defer {
            group.leave()
          }
          switch recommendedResult {
            case .success(let model):
            recommendations = model
            case .failure(let error):
            print(error.localizedDescription)
            }

        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }

    group.notify(queue: .main) {
      guard let newAlbums = newReleases?.albums.items,
            let playlist = featuredPlaylists?.playlists.items,
            let tracks = recommendations?.tracks else {
        return
      }
      self.configureModels(
        newAlbums: newAlbums,
        playlist: playlist,
        tracks: tracks
      )
    }
  }

  //MARK: - configureModels
  private func configureModels(
    newAlbums: [Album],
    playlist: [Playlist],
    tracks: [AudioTrack]
  ) {
    // Configure Model
    sections.append(.newReleases(viewModel: newAlbums.compactMap({
      return NewReleasesCellViewModel(
        name: $0.name,
        artworkURL: URL(string: $0.images.first?.url ?? ""),
        numberOfTracks: $0.total_tracks,
        artistName: $0.artists.first?.name ?? "")
    })))
    sections.append(.featuredPlaylist(viewModel: []))
    sections.append(.recommendationTracks(viewModel: []))
    collectionView.reloadData()
  }

  @objc func didTapSettings() {
    let vc = SettingsViewController()
    vc.title = "Profile"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

//MARK: - extension
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let type = sections[section]
    switch type {
    case .newReleases(let viewModel):
      return viewModel.count
    case .featuredPlaylist(let viewModel):
      return viewModel.count
    case .recommendationTracks(let viewModel):
      return viewModel.count
    }
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sections.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let type = sections[indexPath.section]
    switch type {
    case .newReleases(let viewModels):
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: NewReleasesCollectionViewCell.identifier,
        for: indexPath
      ) as? NewReleasesCollectionViewCell else {
        return UICollectionViewCell()
      }
      let viewModel = viewModels[indexPath.row]
      cell.backgroundColor = .red
      cell.configure(with: viewModel)
      return cell
    case .featuredPlaylist(let viewModels):
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
        for: indexPath
      ) as? FeaturedPlaylistCollectionViewCell else {
        return UICollectionViewCell()
      }
      let viewModel = viewModels[indexPath.row]
      cell.backgroundColor = .blue
      return cell
    case .recommendationTracks(let viewModels):
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: RecommendationTracksCollectionViewCell.identifier,
        for: indexPath
      ) as? RecommendationTracksCollectionViewCell else {
        return UICollectionViewCell()
      }
      let viewModel = viewModels[indexPath.row]
      cell.backgroundColor = .green
      return cell
    }


  }

  func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
    switch section {
    case 0:
      //Item
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(2.0),
          heightDimension: .fractionalHeight(2.0)
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
        count: 2
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
      section.orthogonalScrollingBehavior = .continuous
      return section


    case 1:
      //Item
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(200),
          heightDimension: .absolute(200)
        )
      )
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      // verticalGroup
      let verticalGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(200),
          heightDimension: .absolute(400)
        ),
        subitem: item,
        count: 2
      )

      //horizontalGroup
      let horizontalGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(200),
          heightDimension: .absolute(400)
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
}
