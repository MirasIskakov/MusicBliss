//
//  UserProfileModel.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import Foundation

struct UserProfileModel: Codable {
  let country: String
  let display_name: String
  let email: String
  let explicit_content: [String: Int]
  let external_urls: [String: String]
  let followers: [String: String?]
  let id: String
  let product: String
  let images: [UserImage]
}

struct UserImage: Codable {
  let url: String?
}
//{
//    country = KZ;
//    "display_name" = "Miras Iskakov";
//    email = "iskakov91633@gmail.com";
//    "explicit_content" =     {
//        "filter_enabled" = 0;
//        "filter_locked" = 0;
//    };
//    "external_urls" =     {
//        spotify = "https://open.spotify.com/user/31zlzldyo3kzopar3uhvkvtf6dqy";
//    };
//    followers =     {
//        href = "<null>";
//        total = 0;
//    };
//    href = "https://api.spotify.com/v1/users/31zlzldyo3kzopar3uhvkvtf6dqy";
//    id = 31zlzldyo3kzopar3uhvkvtf6dqy;
//    images =     (
//    );
//    product = free;
//    type = user;
//    uri = "spotify:user:31zlzldyo3kzopar3uhvkvtf6dqy";
//}
