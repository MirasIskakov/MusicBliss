//
//  ProfileViewController.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      title = "Profile"
      APIColler.shared.getCurentUserProfile { result in
        switch result {
        case .success(let model):
          break
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    }

}
