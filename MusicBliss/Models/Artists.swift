//
//  Artists.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 22.07.2024.
//

import Foundation

struct Artists: Codable {
  let id: String
  let name: String
  let type: String
  let external_urls: [String: String]
}
