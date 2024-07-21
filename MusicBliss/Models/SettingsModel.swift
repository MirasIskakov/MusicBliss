//
//  SettingsModel.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 21.07.2024.
//

import Foundation

struct Section {
  let title: String
  let options: [Option]
}

struct Option {
  let title: String
  let handler: () -> Void
}
