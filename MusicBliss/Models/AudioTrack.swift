//
//  AudioTrack.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import Foundation

struct AudioTrack: Codable {
  let album: Album
  let artists: [Artists]
  let available_markets: [String]
  let disc_number: Int
  let duration_ms: Int
  let explicit: Bool
  let external_ids: [String:String]
  let id: String
  let popularity: Int
}
