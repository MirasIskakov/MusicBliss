//
//  AuthManager.swift
//  MusicBliss
//
//  Created by Miras Iskakov on 27.06.2024.
//

import Foundation
import Moya

final class AuthManager {
  static let shared = AuthManager()

  private let provider = MoyaProvider<AuthTarget>()

  private var refreshingToken = false

  struct Constants {
    static let clientId = "873a51705c544578bdb474bb7157792b"
    static let clientSecret = "0bdc30a6cee1466d89038fdb5d401207"
    static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    static let redirectUri = "spotify-ios-quick-start://spotify-login-callback"
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
//"https://open.spotify.com/"
  }

  public var signInURL: URL? {
    let baseURL = "https://accounts.spotify.com/authorize"

    var components = URLComponents(string: baseURL)

    components?.queryItems = [
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "client_id", value: Constants.clientId),
      URLQueryItem(name: "scope", value: Constants.scopes),
      URLQueryItem(name: "redirect_uri", value: Constants.redirectUri),
      URLQueryItem(name: "show_dialog", value: "TRUE"),
    ]

    return components?.url
  }

  var isSingedIn: Bool {
    return accessToken != nil
  }

  private init() {}

  private var accessToken: String? {
    return UserDefaults.standard.string(forKey: "accessToken")
  }

  private var refreshToken: String? {
    return UserDefaults.standard.string(forKey: "refreshToken")
  }

  private var tokenExpirationDate: Date? {
    return UserDefaults.standard.object(forKey: "expirationDate") as? Date
  }

  private var shouldRefreshToken: Bool {
    guard let tokenExpirationDate else { return false }
    let currentDate = Date()
    let fiveMinutes: TimeInterval = 300
    return currentDate.addingTimeInterval(fiveMinutes) >= tokenExpirationDate
  }

  public func exchangeCodeForToken(
    code: String,
    completion: @escaping ((Bool) -> Void)
  ) { // get token
    provider.request(.getAccessToken(code: code)) { [weak self] result in
      switch result {
      case .success(let response):
        guard let result = try? response.map(AuthResponse.self) else {
          completion(false)
          return
        }

        self?.cacheToken(result: result)
        completion(true)
      case .failure(let error):
        completion(false)
      }
    }
  }

  private var onRefreshBlocks = [((String) -> Void)]()

  public func withValidToken(completion: @escaping (String) -> Void) {
    guard !refreshingToken else {
      onRefreshBlocks.append(completion)
      return
    }
    if shouldRefreshToken {
      refreshIfNeeded { [weak self] success in
        if let token = self?.accessToken, success {
          completion(token)
        }
      }
    } else if let token = accessToken {
      completion(token)
    }
  }

  public func refreshIfNeeded(completion: @escaping (Bool) -> Void) {
    guard !refreshingToken else {
      return
    }

    guard shouldRefreshToken else {
      completion(true)
      return
    }

    guard let refreshToken = self.refreshToken else {
      return
    }

    guard let url = URL(string: Constants.tokenAPIURL) else {
      return
    }

    refreshingToken = true

    var components = URLComponents()
    components.queryItems = [
      URLQueryItem(name: "grant_type",
                   value: "refresh_token"),
      URLQueryItem(name: "refresh_token",
                   value: refreshToken)
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded ",
                     forHTTPHeaderField: "Content-Type")
    request.httpBody = components.query?.data(using: .utf8)

    let basicToken = Constants.clientId+":"+Constants.clientSecret
    let data = basicToken.data(using: .utf8)
    guard let base64String = data?.base64EncodedString() else {
      print("Failure to get base64")
      completion(false)
      return
    }

    request.setValue("Basic \(base64String)",
                     forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
      self?.refreshingToken = false
      guard let data = data,
              error == nil else {
        completion(false)
        return
      }
      do {
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        self?.onRefreshBlocks.forEach { $0(result.accessToken) }
        self?.onRefreshBlocks.removeAll()
        self?.cacheToken(result: result)
        completion(true)
      } catch {
        print(error.localizedDescription)
        completion(false)
      }
    }
    task.resume()
    

  }

  private func cacheToken(result: AuthResponse) {
    UserDefaults.standard.setValue(result.accessToken, 
                                   forKey: "accessToken")
    if let refreshToken = result.refreshToken {
      UserDefaults.standard.setValue(refreshToken, 
                                     forKey: "refreshToken")
    }
    UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expiresIn)),
                                   forKey: "expirationDate"
    )
  }
}
