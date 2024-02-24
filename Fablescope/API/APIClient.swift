//
//  APIClient.swift
//  Fablescope
//
//  Created by Timur Guliamov on 24.02.2024.
//

import Foundation

final class APIClient {
  private enum APIError: Error {
    case unknown
  }

  static let shared = APIClient(session: .shared)

  private let session: URLSession
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  init(session: URLSession) {
    self.session = session
  }

  func getTags() async throws -> TagsResponse {
    try await self.perform(
      urlRequest: URLRequest(
        url: URL(string: "https://d5dh1m3g45o42vu4cn5h.apigw.yandexcloud.net/tags")!
      )
    )
  }

  func getStory(with ids: TagIDs) async throws -> StoryResponse {
    var request = URLRequest(
      url: URL(string: "https://d5dh1m3g45o42vu4cn5h.apigw.yandexcloud.net/story")!
    )
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    try request.httpBody = self.encoder.encode(ids)
    return try await self.perform(urlRequest: request)
  }

  private func perform<Result: Decodable>(urlRequest: URLRequest) async throws -> Result {
    let (data, response) = try await self.session.data(for: urlRequest)

    switch response {
    case let httpResponse as HTTPURLResponse:
      guard httpResponse.statusCode == 200 else { throw APIError.unknown }
    default:
      break
    }

    return try self.decoder.decode(Result.self, from: data)
  }
}
