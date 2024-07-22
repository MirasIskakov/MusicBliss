//
//  APICaller.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import Foundation

final class APICaller {

  static let shared = APICaller()

  private init() {}

  struct Constants {
    static let baseAPIURL = "https://api.spotify.com/v1"

  }

  enum APIError {
    case faileedToGetData
  }

  public func getCurrentUserProfile(completion: @escaping (Result<UserProfileModel, Error>) -> Void) {
    createRequest(
      with: URL(string: Constants.baseAPIURL + "/me"),
      type: .GET
    ) { baseRequest in
      let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
        guard let data = data, error == nil else {
          completion(.failure(APIError.faileedToGetData as! Error))
          return
        }
        do {
          let result = try JSONDecoder().decode(UserProfileModel.self, from: data)
          completion(.success(result))
        }
        catch {
          print(error.localizedDescription)
          completion(.failure(error))
        }
      }
      task.resume()
    }
  }

  public func getNewReleases(completion: @escaping ((Result<String, Error>)) -> Void) {
    createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"),
                  type: .GET) { request in
      let task = URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data == data, error == nil else {
          completion(.failure(APIError.faileedToGetData))
          return
        } do {
          let json = JSONSerialization.jsonObject(with: data, options: .allowFragments)
          print(json)
        } catch {
          completion(.failure(error))
        }
      }
      task.resume()
    }
  }

  enum HTTPMethod: String {
    case GET
    case POST
  }

  private func createRequest(
    with url: URL?,
    type: HTTPMethod,
    completion: @escaping (URLRequest) -> Void
  ) {
    AuthManager.shared.withValidToken { token in
      guard let apiURL = url else {
        return
      }
      var request = URLRequest(url: apiURL)
      request.setValue("Bearer \(token)",
                       forHTTPHeaderField: "Authorization")
      request.httpMethod = type.rawValue
      request.timeoutInterval = 30
      completion(request)
    }
  }
}
